/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the tools applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "configureapp.h"
#include "environment.h"
#ifdef COMMERCIAL_VERSION
#  include "tools.h"
#endif

#include <QDate>
#include <qdir.h>
#include <qdiriterator.h>
#include <qtemporaryfile.h>
#include <qstack.h>
#include <qdebug.h>
#include <qfileinfo.h>
#include <qtextstream.h>
#include <qregexp.h>
#include <qhash.h>

#include <iostream>
#include <windows.h>
#include <conio.h>

QT_BEGIN_NAMESPACE

enum Platforms {
    WINDOWS,
    WINDOWS_CE,
    QNX,
    BLACKBERRY,
    SYMBIAN
};

std::ostream &operator<<(std::ostream &s, const QString &val) {
    s << val.toLocal8Bit().data();
    return s;
}


using namespace std;

// Macros to simplify options marking
#define MARK_OPTION(x,y) ( dictionary[ #x ] == #y ? "*" : " " )


bool writeToFile(const char* text, const QString &filename)
{
    QByteArray symFile(text);
    QFile file(filename);
    QDir dir(QFileInfo(file).absoluteDir());
    if (!dir.exists())
        dir.mkpath(dir.absolutePath());
    if (!file.open(QFile::WriteOnly)) {
        cout << "Couldn't write to " << qPrintable(filename) << ": " << qPrintable(file.errorString())
             << endl;
        return false;
    }
    file.write(symFile);
    return true;
}

Configure::Configure(int& argc, char** argv)
{
    useUnixSeparators = false;
    // Default values for indentation
    optionIndent = 4;
    descIndent   = 25;
    outputWidth  = 0;
    // Get console buffer output width
    CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    if (GetConsoleScreenBufferInfo(hStdout, &info))
        outputWidth = info.dwSize.X - 1;
    outputWidth = qMin(outputWidth, 79); // Anything wider gets unreadable
    if (outputWidth < 35) // Insanely small, just use 79
        outputWidth = 79;
    int i;

    /*
    ** Set up the initial state, the default
    */
    dictionary[ "CONFIGCMD" ] = argv[ 0 ];

    for (i = 1; i < argc; i++)
        configCmdLine += argv[ i ];


    // Get the path to the executable
    wchar_t module_name[MAX_PATH];
    GetModuleFileName(0, module_name, sizeof(module_name) / sizeof(wchar_t));
    QFileInfo sourcePathInfo = QString::fromWCharArray(module_name);
    sourcePath = sourcePathInfo.absolutePath();
    sourceDir = sourcePathInfo.dir();
    buildPath = QDir::currentPath();
#if 0
    const QString installPath = QString("C:\\Qt\\%1").arg(QT_VERSION_STR);
#else
    const QString installPath = buildPath;
#endif
    if (sourceDir != buildDir) { //shadow builds!
        if (!findFile("perl") && !findFile("perl.exe")) {
            cout << "Error: Creating a shadow build of Qt requires" << endl
                 << "perl to be in the PATH environment";
            exit(0); // Exit cleanly for Ctrl+C
        }

        cout << "Preparing build tree..." << endl;
        QDir(buildPath).mkpath("bin");

        { //duplicate qmake
            QStack<QString> qmake_dirs;
            qmake_dirs.push("qmake");
            while (!qmake_dirs.isEmpty()) {
                QString dir = qmake_dirs.pop();
                QString od(buildPath + "/" + dir);
                QString id(sourcePath + "/" + dir);
                QFileInfoList entries = QDir(id).entryInfoList(QDir::NoDotAndDotDot|QDir::AllEntries);
                for (int i = 0; i < entries.size(); ++i) {
                    QFileInfo fi(entries.at(i));
                    if (fi.isDir()) {
                        qmake_dirs.push(dir + "/" + fi.fileName());
                        QDir().mkpath(od + "/" + fi.fileName());
                    } else {
                        QDir().mkpath(od);
                        bool justCopy = true;
                        const QString fname = fi.fileName();
                        const QString outFile(od + "/" + fname), inFile(id + "/" + fname);
                        if (fi.fileName() == "Makefile") { //ignore
                        } else if (fi.suffix() == "h" || fi.suffix() == "cpp") {
                            QTemporaryFile tmpFile;
                            if (tmpFile.open()) {
                                QTextStream stream(&tmpFile);
                                stream << "#include \"" << inFile << "\"" << endl;
                                justCopy = false;
                                stream.flush();
                                tmpFile.flush();
                                if (filesDiffer(tmpFile.fileName(), outFile)) {
                                    QFile::remove(outFile);
                                    tmpFile.copy(outFile);
                                }
                            }
                        }
                        if (justCopy && filesDiffer(inFile, outFile))
                            QFile::copy(inFile, outFile);
                    }
                }
            }
        }

        { //make a syncqt script(s) that can be used in the shadow
            QFile syncqt(buildPath + "/bin/syncqt");
            if (syncqt.open(QFile::WriteOnly)) {
                QTextStream stream(&syncqt);
                stream << "#!/usr/bin/perl -w" << endl
                       << "require \"" << sourcePath + "/bin/syncqt\";" << endl;
            }
            QFile syncqt_bat(buildPath + "/bin/syncqt.bat");
            if (syncqt_bat.open(QFile::WriteOnly)) {
                QTextStream stream(&syncqt_bat);
                stream << "@echo off" << endl
                       << "set QTDIR=" << QDir::toNativeSeparators(sourcePath) << endl
                       << "call " << fixSeparators(sourcePath) << fixSeparators("/bin/syncqt.bat -outdir \"") << fixSeparators(buildPath) << "\"" << endl
                       << "set QTDIR=" << QDir::toNativeSeparators(buildPath) << endl;
                syncqt_bat.close();
            }
        }

        // make patch_capabilities and createpackage scripts for Symbian that can be used from the shadow build
        QFile patch_capabilities(buildPath + "/bin/patch_capabilities");
        if (patch_capabilities.open(QFile::WriteOnly)) {
            QTextStream stream(&patch_capabilities);
            stream << "#!/usr/bin/perl -w" << endl
                   << "require \"" << sourcePath + "/bin/patch_capabilities\";" << endl;
        }
        QFile patch_capabilities_bat(buildPath + "/bin/patch_capabilities.bat");
        if (patch_capabilities_bat.open(QFile::WriteOnly)) {
            QTextStream stream(&patch_capabilities_bat);
            stream << "@echo off" << endl
                   << "call " << fixSeparators(sourcePath) << fixSeparators("/bin/patch_capabilities.bat %*") << endl;
            patch_capabilities_bat.close();
        }
        QFile createpackage(buildPath + "/bin/createpackage");
        if (createpackage.open(QFile::WriteOnly)) {
            QTextStream stream(&createpackage);
            stream << "#!/usr/bin/perl -w" << endl
                   << "require \"" << sourcePath + "/bin/createpackage\";" << endl;
        }
        QFile createpackage_bat(buildPath + "/bin/createpackage.bat");
        if (createpackage_bat.open(QFile::WriteOnly)) {
            QTextStream stream(&createpackage_bat);
            stream << "@echo off" << endl
                   << "call " << fixSeparators(sourcePath) << fixSeparators("/bin/createpackage.bat %*") << endl;
            createpackage_bat.close();
        }

        // For Windows CE and shadow builds we need to copy these to the
        // build directory.
        QFile::copy(sourcePath + "/bin/setcepaths.bat" , buildPath + "/bin/setcepaths.bat");
        //copy the mkspecs
        buildDir.mkpath("mkspecs");
        if (!Environment::cpdir(sourcePath + "/mkspecs", buildPath + "/mkspecs")){
            cout << "Couldn't copy mkspecs!" << sourcePath << " " << buildPath << endl;
            dictionary["DONE"] = "error";
            return;
        }
    }

    dictionary[ "QT_SOURCE_TREE" ]    = fixSeparators(sourcePath);
    dictionary[ "QT_BUILD_TREE" ]     = fixSeparators(buildPath);
    dictionary[ "QT_INSTALL_PREFIX" ] = fixSeparators(installPath);

    dictionary[ "QMAKESPEC" ] = getenv("QMAKESPEC");
    if (dictionary[ "QMAKESPEC" ].size() == 0) {
        dictionary[ "QMAKESPEC" ] = Environment::detectQMakeSpec();
        dictionary[ "QMAKESPEC_FROM" ] = "detected";
    } else {
        dictionary[ "QMAKESPEC_FROM" ] = "env";
    }

    dictionary[ "ARCHITECTURE" ]    = "windows";
    dictionary[ "QCONFIG" ]         = "full";
    dictionary[ "EMBEDDED" ]        = "no";
    dictionary[ "BUILD_QMAKE" ]     = "yes";
    dictionary[ "DSPFILES" ]        = "yes";
    dictionary[ "VCPROJFILES" ]     = "yes";
    dictionary[ "QMAKE_INTERNAL" ]  = "no";
    dictionary[ "FAST" ]            = "no";
    dictionary[ "NOPROCESS" ]       = "no";
    dictionary[ "STL" ]             = "yes";
    dictionary[ "EXCEPTIONS" ]      = "yes";
    dictionary[ "RTTI" ]            = "yes";
    dictionary[ "MMX" ]             = "auto";
    dictionary[ "3DNOW" ]           = "auto";
    dictionary[ "SSE" ]             = "auto";
    dictionary[ "SSE2" ]            = "auto";
    dictionary[ "IWMMXT" ]          = "auto";
    dictionary[ "SYNCQT" ]          = "auto";
    dictionary[ "CE_CRT" ]          = "no";
    dictionary[ "CETEST" ]          = "auto";
    dictionary[ "CE_SIGNATURE" ]    = "no";
    dictionary[ "SCRIPT" ]          = "auto";
    dictionary[ "SCRIPTTOOLS" ]     = "auto";
    dictionary[ "XMLPATTERNS" ]     = "auto";
    dictionary[ "PHONON" ]          = "auto";
    dictionary[ "PHONON_BACKEND" ]  = "yes";
    dictionary[ "MULTIMEDIA" ]      = "yes";
    dictionary[ "AUDIO_BACKEND" ]   = "auto";
    dictionary[ "WMSDK" ]           = "auto";
    dictionary[ "DIRECTSHOW" ]      = "no";
    dictionary[ "WEBKIT" ]          = "auto";
    dictionary[ "DECLARATIVE" ]     = "auto";
    dictionary[ "DECLARATIVE_DEBUG" ]= "yes";
    dictionary[ "PLUGIN_MANIFESTS" ] = "yes";
    dictionary[ "DIRECTWRITE" ]     = "no";
    dictionary[ "QPA" ]             = "no";
    dictionary[ "NIS" ]             = "no";
    dictionary[ "NEON" ]            = "no";
    dictionary[ "LARGE_FILE" ]      = "yes";
    dictionary[ "LITTLE_ENDIAN" ]   = "yes";
    dictionary[ "FONT_CONFIG" ]     = "no";
    dictionary[ "POSIX_IPC" ]       = "no";
    dictionary[ "QT_INOTIFY" ]      = "no";

    QString version;
    QFile qglobal_h(sourcePath + "/src/corelib/global/qglobal.h");
    if (qglobal_h.open(QFile::ReadOnly)) {
        QTextStream read(&qglobal_h);
        QRegExp version_regexp("^# *define *QT_VERSION_STR *\"([^\"]*)\"");
        QString line;
        while (!read.atEnd()) {
            line = read.readLine();
            if (version_regexp.exactMatch(line)) {
                version = version_regexp.cap(1).trimmed();
                if (!version.isEmpty())
                    break;
            }
        }
        qglobal_h.close();
    }

    if (version.isEmpty())
        version = QString("%1.%2.%3").arg(QT_VERSION>>16).arg(((QT_VERSION>>8)&0xff)).arg(QT_VERSION&0xff);

    dictionary[ "VERSION" ]         = version;
    {
        QRegExp version_re("([0-9]*)\\.([0-9]*)\\.([0-9]*)(|-.*)");
        if (version_re.exactMatch(version)) {
            dictionary[ "VERSION_MAJOR" ] = version_re.cap(1);
            dictionary[ "VERSION_MINOR" ] = version_re.cap(2);
            dictionary[ "VERSION_PATCH" ] = version_re.cap(3);
        }
    }

    dictionary[ "REDO" ]            = "no";
    dictionary[ "DEPENDENCIES" ]    = "no";

    dictionary[ "BUILD" ]           = "debug";
    dictionary[ "BUILDALL" ]        = "auto"; // Means yes, but not explicitly

    dictionary[ "BUILDTYPE" ]      = "none";

    dictionary[ "BUILDDEV" ]        = "no";
    dictionary[ "BUILDNOKIA" ]      = "no";

    dictionary[ "SHARED" ]          = "yes";

    dictionary[ "ZLIB" ]            = "auto";

    dictionary[ "GIF" ]             = "auto";
    dictionary[ "TIFF" ]            = "auto";
    dictionary[ "JPEG" ]            = "auto";
    dictionary[ "PNG" ]             = "auto";
    dictionary[ "MNG" ]             = "auto";
    dictionary[ "LIBTIFF" ]         = "auto";
    dictionary[ "LIBJPEG" ]         = "auto";
    dictionary[ "LIBPNG" ]          = "auto";
    dictionary[ "LIBMNG" ]          = "auto";
    dictionary[ "FREETYPE" ]        = "no";

    dictionary[ "QT3SUPPORT" ]      = "yes";
    dictionary[ "ACCESSIBILITY" ]   = "yes";
    dictionary[ "OPENGL" ]          = "yes";
    dictionary[ "OPENVG" ]          = "no";
    dictionary[ "IPV6" ]            = "yes"; // Always, dynamically loaded
    dictionary[ "OPENSSL" ]         = "auto";
    dictionary[ "DBUS" ]            = "auto";
    dictionary[ "S60" ]             = "yes";

    dictionary[ "STYLE_WINDOWS" ]   = "yes";
    dictionary[ "STYLE_WINDOWSXP" ] = "auto";
    dictionary[ "STYLE_WINDOWSVISTA" ] = "auto";
    dictionary[ "STYLE_PLASTIQUE" ] = "yes";
    dictionary[ "STYLE_CLEANLOOKS" ]= "yes";
    dictionary[ "STYLE_WINDOWSCE" ] = "no";
    dictionary[ "STYLE_WINDOWSMOBILE" ] = "no";
    dictionary[ "STYLE_MOTIF" ]     = "yes";
    dictionary[ "STYLE_CDE" ]       = "yes";
    dictionary[ "STYLE_S60" ]       = "no";
    dictionary[ "STYLE_GTK" ]       = "no";

    dictionary[ "SQL_MYSQL" ]       = "no";
    dictionary[ "SQL_ODBC" ]        = "no";
    dictionary[ "SQL_OCI" ]         = "no";
    dictionary[ "SQL_PSQL" ]        = "no";
    dictionary[ "SQL_TDS" ]         = "no";
    dictionary[ "SQL_DB2" ]         = "no";
    dictionary[ "SQL_SQLITE" ]      = "auto";
    dictionary[ "SQL_SQLITE_LIB" ]  = "qt";
    dictionary[ "SQL_SQLITE2" ]     = "no";
    dictionary[ "SQL_IBASE" ]       = "no";
    dictionary[ "GRAPHICS_SYSTEM" ] = "raster";

    QString tmp = dictionary[ "QMAKESPEC" ];
    if (tmp.contains("\\")) {
        tmp = tmp.mid(tmp.lastIndexOf("\\") + 1);
    } else {
        tmp = tmp.mid(tmp.lastIndexOf("/") + 1);
    }
    dictionary[ "QMAKESPEC" ] = tmp;

    dictionary[ "INCREDIBUILD_XGE" ] = "auto";
    dictionary[ "LTCG" ]            = "no";
    dictionary[ "NATIVE_GESTURES" ] = "yes";
    dictionary[ "MSVC_MP" ] = "no";
    dictionary[ "SYSTEM_PROXIES" ]  = "no";
    dictionary[ "SLOG2" ]           = "no";
}

Configure::~Configure()
{
    for (int i=0; i<3; ++i) {
        QList<MakeItem*> items = makeList[i];
        for (int j=0; j<items.size(); ++j)
            delete items[j];
    }
}

QString Configure::fixSeparators(const QString &somePath, bool escape)
{
    if (useUnixSeparators)
        return QDir::fromNativeSeparators(somePath);
    QString ret = QDir::toNativeSeparators(somePath);
    return escape ? escapeSeparators(ret) : ret;
}

QString Configure::escapeSeparators(const QString &somePath)
{
    QString out = somePath;
    out.replace(QLatin1Char('\\'), QLatin1String("\\\\"));
    return out;
}

// We could use QDir::homePath() + "/.qt-license", but
// that will only look in the first of $HOME,$USERPROFILE
// or $HOMEDRIVE$HOMEPATH. So, here we try'em all to be
// more forgiving for the end user..
QString Configure::firstLicensePath()
{
    QStringList allPaths;
    allPaths << "./.qt-license"
             << QString::fromLocal8Bit(getenv("HOME")) + "/.qt-license"
             << QString::fromLocal8Bit(getenv("USERPROFILE")) + "/.qt-license"
             << QString::fromLocal8Bit(getenv("HOMEDRIVE")) + QString::fromLocal8Bit(getenv("HOMEPATH")) + "/.qt-license";
    for (int i = 0; i< allPaths.count(); ++i)
        if (QFile::exists(allPaths.at(i)))
            return allPaths.at(i);
    return QString();
}

// #### somehow I get a compiler error about vc++ reaching the nesting limit without
// undefining the ansi for scoping.
#ifdef for
#undef for
#endif

void Configure::parseCmdLine()
{
    int argCount = configCmdLine.size();
    int i = 0;
    const QStringList imageFormats = QStringList() << "gif" << "png" << "mng" << "jpeg" << "tiff";

#if !defined(EVAL)
    if (argCount < 1) // skip rest if no arguments
        ;
    else if (configCmdLine.at(i) == "-redo") {
        dictionary[ "REDO" ] = "yes";
        configCmdLine.clear();
        reloadCmdLine();
    }
    else if (configCmdLine.at(i) == "-loadconfig") {
        ++i;
        if (i != argCount) {
            dictionary[ "REDO" ] = "yes";
            dictionary[ "CUSTOMCONFIG" ] = "_" + configCmdLine.at(i);
            configCmdLine.clear();
            reloadCmdLine();
        } else {
            dictionary[ "HELP" ] = "yes";
        }
        i = 0;
    }
    argCount = configCmdLine.size();
#endif

    // Look first for XQMAKESPEC
    for (int j = 0 ; j < argCount; ++j)
    {
        if (configCmdLine.at(j) == "-xplatform") {
            ++j;
            if (j == argCount)
                break;
            dictionary["XQMAKESPEC"] = configCmdLine.at(j);
            if (!dictionary[ "XQMAKESPEC" ].isEmpty())
                applySpecSpecifics();
        }
    }

    for (; i<configCmdLine.size(); ++i) {
        bool continueElse[] = {false, false};
        if (configCmdLine.at(i) == "-help"
            || configCmdLine.at(i) == "-h"
            || configCmdLine.at(i) == "-?")
            dictionary[ "HELP" ] = "yes";

#if !defined(EVAL)
        else if (configCmdLine.at(i) == "-qconfig") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QCONFIG" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-buildkey") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "USER_BUILD_KEY" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-release") {
            dictionary[ "BUILD" ] = "release";
            if (dictionary[ "BUILDALL" ] == "auto")
                dictionary[ "BUILDALL" ] = "no";
        } else if (configCmdLine.at(i) == "-debug") {
            dictionary[ "BUILD" ] = "debug";
            if (dictionary[ "BUILDALL" ] == "auto")
                dictionary[ "BUILDALL" ] = "no";
        } else if (configCmdLine.at(i) == "-debug-and-release")
            dictionary[ "BUILDALL" ] = "yes";

        else if (configCmdLine.at(i) == "-shared")
            dictionary[ "SHARED" ] = "yes";
        else if (configCmdLine.at(i) == "-static")
            dictionary[ "SHARED" ] = "no";
        else if (configCmdLine.at(i) == "-developer-build")
            dictionary[ "BUILDDEV" ] = "yes";
        else if (configCmdLine.at(i) == "-nokia-developer") {
            cout << "Detected -nokia-developer option" << endl;
            cout << "Digia employees and agents are allowed to use this software under" << endl;
            cout << "the authority of Digia Plc and/or its subsidiary(-ies)" << endl;
            dictionary[ "BUILDNOKIA" ] = "yes";
            dictionary[ "BUILDDEV" ] = "yes";
            dictionary["LICENSE_CONFIRMED"] = "yes";
            if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian")) {
                dictionary[ "SYMBIAN_DEFFILES" ] = "no";
            }
        }
        else if (configCmdLine.at(i) == "-opensource") {
            dictionary[ "BUILDTYPE" ] = "opensource";
        }
        else if (configCmdLine.at(i) == "-commercial") {
            dictionary[ "BUILDTYPE" ] = "commercial";
        }
        else if (configCmdLine.at(i) == "-ltcg") {
            dictionary[ "LTCG" ] = "yes";
        }
        else if (configCmdLine.at(i) == "-no-ltcg") {
            dictionary[ "LTCG" ] = "no";
        }
        else if (configCmdLine.at(i) == "-mp") {
            dictionary[ "MSVC_MP" ] = "yes";
        }
        else if (configCmdLine.at(i) == "-no-mp") {
            dictionary[ "MSVC_MP" ] = "no";
        }

#endif

        else if (configCmdLine.at(i) == "-platform") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QMAKESPEC" ] = configCmdLine.at(i);
        dictionary[ "QMAKESPEC_FROM" ] = "commandline";
        } else if (configCmdLine.at(i) == "-arch") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "ARCHITECTURE" ] = configCmdLine.at(i);
            if (configCmdLine.at(i) == "boundschecker") {
                dictionary[ "ARCHITECTURE" ] = "generic";   // Boundschecker uses the generic arch,
                qtConfig += "boundschecker";                // but also needs this CONFIG option
            }
        } else if (configCmdLine.at(i) == "-embedded") {
            dictionary[ "EMBEDDED" ] = "yes";
        } else if (configCmdLine.at(i) == "-xplatform") {
            ++i;
            // do nothing
        }


#if !defined(EVAL)
        else if (configCmdLine.at(i) == "-no-zlib") {
            // No longer supported since Qt 4.4.0
            // But save the information for later so that we can print a warning
            //
            // If you REALLY really need no zlib support, you can still disable
            // it by doing the following:
            //   add "no-zlib" to mkspecs/qconfig.pri
            //   #define QT_NO_COMPRESS (probably by adding to src/corelib/global/qconfig.h)
            //
            // There's no guarantee that Qt will build under those conditions

            dictionary[ "ZLIB_FORCED" ] = "yes";
        } else if (configCmdLine.at(i) == "-qt-zlib") {
            dictionary[ "ZLIB" ] = "qt";
        } else if (configCmdLine.at(i) == "-system-zlib") {
            dictionary[ "ZLIB" ] = "system";
        }

        // Image formats --------------------------------------------
        else if (configCmdLine.at(i) == "-no-gif")
            dictionary[ "GIF" ] = "no";

        else if (configCmdLine.at(i) == "-no-libtiff") {
            dictionary[ "TIFF"] = "no";
            dictionary[ "LIBTIFF" ] = "no";
        } else if (configCmdLine.at(i) == "-qt-libtiff") {
            dictionary[ "LIBTIFF" ] = "qt";
        } else if (configCmdLine.at(i) == "-system-libtiff") {
            dictionary[ "LIBTIFF" ] = "system";
        }

        else if (configCmdLine.at(i) == "-no-libjpeg") {
            dictionary[ "JPEG" ] = "no";
            dictionary[ "LIBJPEG" ] = "no";
        } else if (configCmdLine.at(i) == "-qt-libjpeg") {
            dictionary[ "LIBJPEG" ] = "qt";
        } else if (configCmdLine.at(i) == "-system-libjpeg") {
            dictionary[ "LIBJPEG" ] = "system";
        }

        else if (configCmdLine.at(i) == "-no-libpng") {
            dictionary[ "PNG" ] = "no";
            dictionary[ "LIBPNG" ] = "no";
        } else if (configCmdLine.at(i) == "-qt-libpng") {
            dictionary[ "LIBPNG" ] = "qt";
        } else if (configCmdLine.at(i) == "-system-libpng") {
            dictionary[ "LIBPNG" ] = "system";
        }

        else if (configCmdLine.at(i) == "-no-libmng") {
            dictionary[ "MNG" ] = "no";
            dictionary[ "LIBMNG" ] = "no";
        } else if (configCmdLine.at(i) == "-qt-libmng") {
            dictionary[ "LIBMNG" ] = "qt";
        } else if (configCmdLine.at(i) == "-system-libmng") {
            dictionary[ "LIBMNG" ] = "system";
        }

        // Text Rendering --------------------------------------------
        else if (configCmdLine.at(i) == "-no-freetype")
            dictionary[ "FREETYPE" ] = "no";
        else if (configCmdLine.at(i) == "-qt-freetype")
            dictionary[ "FREETYPE" ] = "yes";
        else if (configCmdLine.at(i) == "-system-freetype")
            dictionary[ "FREETYPE" ] = "system";

        // CE- C runtime --------------------------------------------
        else if (configCmdLine.at(i) == "-crt") {
            ++i;
            if (i == argCount)
                break;
            QDir cDir(configCmdLine.at(i));
            if (!cDir.exists())
                cout << "WARNING: Could not find directory (" << qPrintable(configCmdLine.at(i)) << ")for C runtime deployment" << endl;
            else
                dictionary[ "CE_CRT" ] = QDir::toNativeSeparators(cDir.absolutePath());
        } else if (configCmdLine.at(i) == "-qt-crt") {
            dictionary[ "CE_CRT" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-crt") {
            dictionary[ "CE_CRT" ] = "no";
        }
        // cetest ---------------------------------------------------
        else if (configCmdLine.at(i) == "-no-cetest") {
            dictionary[ "CETEST" ] = "no";
            dictionary[ "CETEST_REQUESTED" ] = "no";
        } else if (configCmdLine.at(i) == "-cetest") {
            // although specified to use it, we stay at "auto" state
            // this is because checkAvailability() adds variables
            // we need for crosscompilation; but remember if we asked
            // for it.
            dictionary[ "CETEST_REQUESTED" ] = "yes";
        }
        // Qt/CE - signing tool -------------------------------------
        else if (configCmdLine.at(i) == "-signature") {
            ++i;
            if (i == argCount)
                break;
            QFileInfo info(configCmdLine.at(i));
            if (!info.exists())
                cout << "WARNING: Could not find signature file (" << qPrintable(configCmdLine.at(i)) << ")" << endl;
            else
                dictionary[ "CE_SIGNATURE" ] = QDir::toNativeSeparators(info.absoluteFilePath());
        }
        // Styles ---------------------------------------------------
        else if (configCmdLine.at(i) == "-qt-style-windows")
            dictionary[ "STYLE_WINDOWS" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-windows")
            dictionary[ "STYLE_WINDOWS" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-windowsce")
            dictionary[ "STYLE_WINDOWSCE" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-windowsce")
            dictionary[ "STYLE_WINDOWSCE" ] = "no";
        else if (configCmdLine.at(i) == "-qt-style-windowsmobile")
            dictionary[ "STYLE_WINDOWSMOBILE" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-windowsmobile")
            dictionary[ "STYLE_WINDOWSMOBILE" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-windowsxp")
            dictionary[ "STYLE_WINDOWSXP" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-windowsxp")
            dictionary[ "STYLE_WINDOWSXP" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-windowsvista")
            dictionary[ "STYLE_WINDOWSVISTA" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-windowsvista")
            dictionary[ "STYLE_WINDOWSVISTA" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-plastique")
            dictionary[ "STYLE_PLASTIQUE" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-plastique")
            dictionary[ "STYLE_PLASTIQUE" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-cleanlooks")
            dictionary[ "STYLE_CLEANLOOKS" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-cleanlooks")
            dictionary[ "STYLE_CLEANLOOKS" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-motif")
            dictionary[ "STYLE_MOTIF" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-motif")
            dictionary[ "STYLE_MOTIF" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-cde")
            dictionary[ "STYLE_CDE" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-cde")
            dictionary[ "STYLE_CDE" ] = "no";

        else if (configCmdLine.at(i) == "-qt-style-s60")
            dictionary[ "STYLE_S60" ] = "yes";
        else if (configCmdLine.at(i) == "-no-style-s60")
            dictionary[ "STYLE_S60" ] = "no";

        // Qt 3 Support ---------------------------------------------
        else if (configCmdLine.at(i) == "-no-qt3support")
            dictionary[ "QT3SUPPORT" ] = "no";

        // Work around compiler nesting limitation
        else
            continueElse[1] = true;
        if (!continueElse[1]) {
        }

        // OpenGL Support -------------------------------------------
        else if (configCmdLine.at(i) == "-no-opengl") {
            dictionary[ "OPENGL" ]    = "no";
        } else if (configCmdLine.at(i) == "-opengl-es-cm") {
            dictionary[ "OPENGL" ]          = "yes";
            dictionary[ "OPENGL_ES_CM" ]    = "yes";
        } else if (configCmdLine.at(i) == "-opengl-es-2") {
            dictionary[ "OPENGL" ]          = "yes";
            dictionary[ "OPENGL_ES_2" ]     = "yes";
        } else if (configCmdLine.at(i) == "-opengl") {
            dictionary[ "OPENGL" ]          = "yes";
            i++;
            if (i == argCount)
                break;

            if (configCmdLine.at(i) == "es1") {
                dictionary[ "OPENGL_ES_CM" ]    = "yes";
            } else if ( configCmdLine.at(i) == "es2" ) {
                dictionary[ "OPENGL_ES_2" ]     = "yes";
            } else if ( configCmdLine.at(i) == "desktop" ) {
                // OPENGL=yes suffices
            } else {
                cout << "Argument passed to -opengl option is not valid." << endl;
                dictionary[ "DONE" ] = "error";
                break;
            }
        }

        // OpenVG Support -------------------------------------------
        else if (configCmdLine.at(i) == "-openvg") {
            dictionary[ "OPENVG" ]    = "yes";
        } else if (configCmdLine.at(i) == "-no-openvg") {
            dictionary[ "OPENVG" ]    = "no";
        }

        // Databases ------------------------------------------------
        else if (configCmdLine.at(i) == "-qt-sql-mysql")
            dictionary[ "SQL_MYSQL" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-mysql")
            dictionary[ "SQL_MYSQL" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-mysql")
            dictionary[ "SQL_MYSQL" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-odbc")
            dictionary[ "SQL_ODBC" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-odbc")
            dictionary[ "SQL_ODBC" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-odbc")
            dictionary[ "SQL_ODBC" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-oci")
            dictionary[ "SQL_OCI" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-oci")
            dictionary[ "SQL_OCI" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-oci")
            dictionary[ "SQL_OCI" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-psql")
            dictionary[ "SQL_PSQL" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-psql")
            dictionary[ "SQL_PSQL" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-psql")
            dictionary[ "SQL_PSQL" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-tds")
            dictionary[ "SQL_TDS" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-tds")
            dictionary[ "SQL_TDS" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-tds")
            dictionary[ "SQL_TDS" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-db2")
            dictionary[ "SQL_DB2" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-db2")
            dictionary[ "SQL_DB2" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-db2")
            dictionary[ "SQL_DB2" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-sqlite")
            dictionary[ "SQL_SQLITE" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-sqlite")
            dictionary[ "SQL_SQLITE" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-sqlite")
            dictionary[ "SQL_SQLITE" ] = "no";
        else if (configCmdLine.at(i) == "-system-sqlite")
            dictionary[ "SQL_SQLITE_LIB" ] = "system";
        else if (configCmdLine.at(i) == "-qt-sql-sqlite2")
            dictionary[ "SQL_SQLITE2" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-sqlite2")
            dictionary[ "SQL_SQLITE2" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-sqlite2")
            dictionary[ "SQL_SQLITE2" ] = "no";

        else if (configCmdLine.at(i) == "-qt-sql-ibase")
            dictionary[ "SQL_IBASE" ] = "yes";
        else if (configCmdLine.at(i) == "-plugin-sql-ibase")
            dictionary[ "SQL_IBASE" ] = "plugin";
        else if (configCmdLine.at(i) == "-no-sql-ibase")
            dictionary[ "SQL_IBASE" ] = "no";

        // Image formats --------------------------------------------
        else if (configCmdLine.at(i).startsWith("-qt-imageformat-") &&
                 imageFormats.contains(configCmdLine.at(i).section('-', 3)))
            dictionary[ configCmdLine.at(i).section('-', 3).toUpper() ] = "yes";
        else if (configCmdLine.at(i).startsWith("-plugin-imageformat-") &&
                 imageFormats.contains(configCmdLine.at(i).section('-', 3)))
            dictionary[ configCmdLine.at(i).section('-', 3).toUpper() ] = "plugin";
        else if (configCmdLine.at(i).startsWith("-no-imageformat-") &&
                 imageFormats.contains(configCmdLine.at(i).section('-', 3)))
            dictionary[ configCmdLine.at(i).section('-', 3).toUpper() ] = "no";
#endif
        // IDE project generation -----------------------------------
        else if (configCmdLine.at(i) == "-no-dsp")
            dictionary[ "DSPFILES" ] = "no";
        else if (configCmdLine.at(i) == "-dsp")
            dictionary[ "DSPFILES" ] = "yes";

        else if (configCmdLine.at(i) == "-no-vcp")
            dictionary[ "VCPFILES" ] = "no";
        else if (configCmdLine.at(i) == "-vcp")
            dictionary[ "VCPFILES" ] = "yes";

        else if (configCmdLine.at(i) == "-no-vcproj")
            dictionary[ "VCPROJFILES" ] = "no";
        else if (configCmdLine.at(i) == "-vcproj")
            dictionary[ "VCPROJFILES" ] = "yes";

        else if (configCmdLine.at(i) == "-no-incredibuild-xge")
            dictionary[ "INCREDIBUILD_XGE" ] = "no";
        else if (configCmdLine.at(i) == "-incredibuild-xge")
            dictionary[ "INCREDIBUILD_XGE" ] = "yes";
        else if (configCmdLine.at(i) == "-native-gestures")
            dictionary[ "NATIVE_GESTURES" ] = "yes";
        else if (configCmdLine.at(i) == "-no-native-gestures")
            dictionary[ "NATIVE_GESTURES" ] = "no";
#if !defined(EVAL)
        // Symbian Support -------------------------------------------
        else if (configCmdLine.at(i) == "-fpu")
        {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "ARM_FPU_TYPE" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-s60")
            dictionary[ "S60" ]    = "yes";
        else if (configCmdLine.at(i) == "-no-s60")
            dictionary[ "S60" ]    = "no";

        else if (configCmdLine.at(i) == "-usedeffiles")
            dictionary[ "SYMBIAN_DEFFILES" ] = "yes";
        else if (configCmdLine.at(i) == "-no-usedeffiles")
            dictionary[ "SYMBIAN_DEFFILES" ] = "no";

        // Others ---------------------------------------------------
        else if (configCmdLine.at(i) == "-fast")
            dictionary[ "FAST" ] = "yes";
        else if (configCmdLine.at(i) == "-no-fast")
            dictionary[ "FAST" ] = "no";

        else if (configCmdLine.at(i) == "-stl")
            dictionary[ "STL" ] = "yes";
        else if (configCmdLine.at(i) == "-no-stl")
            dictionary[ "STL" ] = "no";

        else if (configCmdLine.at(i) == "-exceptions")
            dictionary[ "EXCEPTIONS" ] = "yes";
        else if (configCmdLine.at(i) == "-no-exceptions")
            dictionary[ "EXCEPTIONS" ] = "no";

        else if (configCmdLine.at(i) == "-rtti")
            dictionary[ "RTTI" ] = "yes";
        else if (configCmdLine.at(i) == "-no-rtti")
            dictionary[ "RTTI" ] = "no";

        else if (configCmdLine.at(i) == "-accessibility")
            dictionary[ "ACCESSIBILITY" ] = "yes";
        else if (configCmdLine.at(i) == "-no-accessibility") {
            dictionary[ "ACCESSIBILITY" ] = "no";
            cout << "Setting accessibility to NO" << endl;
        }

        else if (configCmdLine.at(i) == "-no-mmx")
            dictionary[ "MMX" ] = "no";
        else if (configCmdLine.at(i) == "-mmx")
            dictionary[ "MMX" ] = "yes";
        else if (configCmdLine.at(i) == "-no-3dnow")
            dictionary[ "3DNOW" ] = "no";
        else if (configCmdLine.at(i) == "-3dnow")
            dictionary[ "3DNOW" ] = "yes";
        else if (configCmdLine.at(i) == "-no-sse")
            dictionary[ "SSE" ] = "no";
        else if (configCmdLine.at(i) == "-sse")
            dictionary[ "SSE" ] = "yes";
        else if (configCmdLine.at(i) == "-no-sse2")
            dictionary[ "SSE2" ] = "no";
        else if (configCmdLine.at(i) == "-sse2")
            dictionary[ "SSE2" ] = "yes";
        else if (configCmdLine.at(i) == "-no-iwmmxt")
            dictionary[ "IWMMXT" ] = "no";
        else if (configCmdLine.at(i) == "-iwmmxt")
            dictionary[ "IWMMXT" ] = "yes";

        else if (configCmdLine.at(i) == "-no-openssl") {
              dictionary[ "OPENSSL"] = "no";
        } else if (configCmdLine.at(i) == "-openssl") {
              dictionary[ "OPENSSL" ] = "yes";
        } else if (configCmdLine.at(i) == "-openssl-linked") {
              dictionary[ "OPENSSL" ] = "linked";
        } else if (configCmdLine.at(i) == "-no-qdbus") {
            dictionary[ "DBUS" ] = "no";
        } else if (configCmdLine.at(i) == "-qdbus") {
            dictionary[ "DBUS" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-dbus") {
            dictionary[ "DBUS" ] = "no";
        } else if (configCmdLine.at(i) == "-dbus") {
            dictionary[ "DBUS" ] = "yes";
        } else if (configCmdLine.at(i) == "-dbus-linked") {
            dictionary[ "DBUS" ] = "linked";
        } else if (configCmdLine.at(i) == "-no-script") {
            dictionary[ "SCRIPT" ] = "no";
        } else if (configCmdLine.at(i) == "-script") {
            dictionary[ "SCRIPT" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-scripttools") {
            dictionary[ "SCRIPTTOOLS" ] = "no";
        } else if (configCmdLine.at(i) == "-scripttools") {
            dictionary[ "SCRIPTTOOLS" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-xmlpatterns") {
            dictionary[ "XMLPATTERNS" ] = "no";
        } else if (configCmdLine.at(i) == "-xmlpatterns") {
            dictionary[ "XMLPATTERNS" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-multimedia") {
            dictionary[ "MULTIMEDIA" ] = "no";
        } else if (configCmdLine.at(i) == "-multimedia") {
            dictionary[ "MULTIMEDIA" ] = "yes";
        } else if (configCmdLine.at(i) == "-audio-backend") {
            dictionary[ "AUDIO_BACKEND" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-audio-backend") {
            dictionary[ "AUDIO_BACKEND" ] = "no";
        } else if (configCmdLine.at(i) == "-no-phonon") {
            dictionary[ "PHONON" ] = "no";
        } else if (configCmdLine.at(i) == "-phonon") {
            dictionary[ "PHONON" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-phonon-backend") {
            dictionary[ "PHONON_BACKEND" ] = "no";
        } else if (configCmdLine.at(i) == "-phonon-backend") {
            dictionary[ "PHONON_BACKEND" ] = "yes";
        } else if (configCmdLine.at(i) == "-phonon-wince-ds9") {
            dictionary[ "DIRECTSHOW" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-webkit") {
            dictionary[ "WEBKIT" ] = "no";
        } else if (configCmdLine.at(i) == "-webkit") {
            dictionary[ "WEBKIT" ] = "yes";
        } else if (configCmdLine.at(i) == "-webkit-debug") {
            dictionary[ "WEBKIT" ] = "debug";
        } else if (configCmdLine.at(i) == "-no-declarative") {
            dictionary[ "DECLARATIVE" ] = "no";
        } else if (configCmdLine.at(i) == "-declarative") {
            dictionary[ "DECLARATIVE" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-declarative-debug") {
            dictionary[ "DECLARATIVE_DEBUG" ] = "no";
        } else if (configCmdLine.at(i) == "-declarative-debug") {
            dictionary[ "DECLARATIVE_DEBUG" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-plugin-manifests") {
            dictionary[ "PLUGIN_MANIFESTS" ] = "no";
        } else if (configCmdLine.at(i) == "-plugin-manifests") {
            dictionary[ "PLUGIN_MANIFESTS" ] = "yes";
        } else if (configCmdLine.at(i) == "-no-slog2") {
            dictionary[ "SLOG2" ] = "no";
        } else if (configCmdLine.at(i) == "-slog2") {
            dictionary[ "SLOG2" ] = "yes";
        }

        // Work around compiler nesting limitation
        else
            continueElse[0] = true;
        if (!continueElse[0]) {
        }

        else if (configCmdLine.at(i) == "-internal")
            dictionary[ "QMAKE_INTERNAL" ] = "yes";

        else if (configCmdLine.at(i) == "-no-qmake")
            dictionary[ "BUILD_QMAKE" ] = "no";
        else if (configCmdLine.at(i) == "-qmake")
            dictionary[ "BUILD_QMAKE" ] = "yes";

        else if (configCmdLine.at(i) == "-dont-process")
            dictionary[ "NOPROCESS" ] = "yes";
        else if (configCmdLine.at(i) == "-process")
            dictionary[ "NOPROCESS" ] = "no";

        else if (configCmdLine.at(i) == "-no-qmake-deps")
            dictionary[ "DEPENDENCIES" ] = "no";
        else if (configCmdLine.at(i) == "-qmake-deps")
            dictionary[ "DEPENDENCIES" ] = "yes";


        else if (configCmdLine.at(i) == "-qtnamespace") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_NAMESPACE" ] = configCmdLine.at(i);
        } else if (configCmdLine.at(i) == "-qtlibinfix") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_LIBINFIX" ] = configCmdLine.at(i);
            if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian")) {
                dictionary[ "QT_INSTALL_PLUGINS" ] =
                    QString("\\resource\\qt%1\\plugins").arg(dictionary[ "QT_LIBINFIX" ]);
                dictionary[ "QT_INSTALL_IMPORTS" ] =
                    QString("\\resource\\qt%1\\imports").arg(dictionary[ "QT_LIBINFIX" ]);
                dictionary[ "QT_INSTALL_TRANSLATIONS" ] =
                    QString("\\resource\\qt%1\\translations").arg(dictionary[ "QT_LIBINFIX" ]);
            }
        } else if (configCmdLine.at(i) == "-D") {
            ++i;
            if (i == argCount)
                break;
            qmakeDefines += configCmdLine.at(i);
        } else if (configCmdLine.at(i) == "-I") {
            ++i;
            if (i == argCount)
                break;
            qmakeIncludes += configCmdLine.at(i);
        } else if (configCmdLine.at(i) == "-L") {
            ++i;
            if (i == argCount)
                break;
            QFileInfo check(configCmdLine.at(i));
            if (!check.isDir()) {
                cout << "Argument passed to -L option is not a directory path. Did you mean the -l option?" << endl;
                dictionary[ "DONE" ] = "error";
                break;
            }
            qmakeLibs += QString("-L" + configCmdLine.at(i));
        } else if (configCmdLine.at(i) == "-l") {
            ++i;
            if (i == argCount)
                break;
            qmakeLibs += QString("-l" + configCmdLine.at(i));
        } else if (configCmdLine.at(i).startsWith("OPENSSL_LIBS=")) {
            opensslLibs = configCmdLine.at(i);
        } else if (configCmdLine.at(i).startsWith("OPENSSL_LIBS_DEBUG=")) {
            opensslLibsDebug = configCmdLine.at(i);
        } else if (configCmdLine.at(i).startsWith("OPENSSL_LIBS_RELEASE=")) {
            opensslLibsRelease = configCmdLine.at(i);
        } else if (configCmdLine.at(i).startsWith("PSQL_LIBS=")) {
            psqlLibs = configCmdLine.at(i);
        } else if (configCmdLine.at(i).startsWith("SYBASE=")) {
            sybase = configCmdLine.at(i);
        } else if (configCmdLine.at(i).startsWith("SYBASE_LIBS=")) {
            sybaseLibs = configCmdLine.at(i);
        }

        else if ((configCmdLine.at(i) == "-override-version") || (configCmdLine.at(i) == "-version-override")){
            ++i;
            if (i == argCount)
                break;
            dictionary[ "VERSION" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-saveconfig") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "CUSTOMCONFIG" ] = "_" + configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-confirm-license") {
            dictionary["LICENSE_CONFIRMED"] = "yes";
        }

        else if (configCmdLine.at(i) == "-nomake") {
            ++i;
            if (i == argCount)
                break;
            disabledBuildParts += configCmdLine.at(i);
        }

        // Directories ----------------------------------------------
        else if (configCmdLine.at(i) == "-prefix") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_PREFIX" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-bindir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_BINS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-libdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_LIBS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-docdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_DOCS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-headerdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_HEADERS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-plugindir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_PLUGINS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-importdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_IMPORTS" ] = configCmdLine.at(i);
        }
        else if (configCmdLine.at(i) == "-datadir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_DATA" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-translationdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_TRANSLATIONS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-examplesdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_EXAMPLES" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-demosdir") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_INSTALL_DEMOS" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-hostprefix") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "QT_HOST_PREFIX" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-make") {
            ++i;
            if (i == argCount)
                break;
            dictionary[ "MAKE" ] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-graphicssystem") {
            ++i;
            if (i == argCount)
                break;
            QString system = configCmdLine.at(i);
            if (system == QLatin1String("raster")
                || system == QLatin1String("opengl")
                || system == QLatin1String("openvg")
                || system == QLatin1String("runtime"))
                dictionary["GRAPHICS_SYSTEM"] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i) == "-runtimegraphicssystem") {
            ++i;
            if (i == argCount)
                break;
            dictionary["RUNTIME_SYSTEM"] = configCmdLine.at(i);
        }

        else if (configCmdLine.at(i).indexOf(QRegExp("^-(en|dis)able-")) != -1) {
            // Scan to see if any specific modules and drivers are enabled or disabled
            for (QStringList::Iterator module = modules.begin(); module != modules.end(); ++module) {
                if (configCmdLine.at(i) == QString("-enable-") + (*module)) {
                    enabledModules += (*module);
                    break;
                }
                else if (configCmdLine.at(i) == QString("-disable-") + (*module)) {
                    disabledModules += (*module);
                    break;
                }
            }
        }

        else if (configCmdLine.at(i) == "-directwrite") {
            dictionary["DIRECTWRITE"] = "yes";
        } else if (configCmdLine.at(i) == "-no-directwrite") {
            dictionary["DIRECTWRITE"] = "no";
        }

        else if (configCmdLine.at(i) == "-nis") {
            dictionary["NIS"] = "yes";
        } else if (configCmdLine.at(i) == "-no-nis") {
            dictionary["NIS"] = "no";
        }

        else if (configCmdLine.at(i) == "-qpa") {
            dictionary["QPA"] = "yes";
        }

        else if (configCmdLine.at(i) == "-cups") {
            dictionary["QT_CUPS"] = "yes";
        } else if (configCmdLine.at(i) == "-no-cups") {
            dictionary["QT_CUPS"] = "no";
        }

        else if (configCmdLine.at(i) == "-iconv") {
            dictionary["QT_ICONV"] = "yes";
        } else if (configCmdLine.at(i) == "-no-iconv") {
            dictionary["QT_ICONV"] = "no";
        }

        else if (configCmdLine.at(i) == "-inotify") {
            dictionary["QT_INOTIFY"] = "yes";
        } else if (configCmdLine.at(i) == "-no-inotify") {
            dictionary["QT_INOTIFY"] = "no";
        }

        else if (configCmdLine.at(i) == "-neon") {
            dictionary["NEON"] = "yes";
        } else if (configCmdLine.at(i) == "-no-neon") {
            dictionary["NEON"] = "no";
        }

        else if (configCmdLine.at(i) == "-largefile") {
            dictionary["LARGE_FILE"] = "yes";
        }

        else if (configCmdLine.at(i) == "-little-endian") {
            dictionary["LITTLE_ENDIAN"] = "yes";
        }

        else if (configCmdLine.at(i) == "-big-endian") {
            dictionary["LITTLE_ENDIAN"] = "no";
        }

        else if (configCmdLine.at(i) == "-fontconfig") {
            dictionary["FONT_CONFIG"] = "yes";
        }

        else if (configCmdLine.at(i) == "-no-fontconfig") {
            dictionary["FONT_CONFIG"] = "no";
        }

        else if (configCmdLine.at(i) == "-posix-ipc") {
            dictionary["POSIX_IPC"] = "yes";
        }

        else if (configCmdLine.at(i) == "-no-system-proxies") {
            dictionary[ "SYSTEM_PROXIES" ] = "no";
        }

        else if (configCmdLine.at(i) == "-system-proxies") {
            dictionary[ "SYSTEM_PROXIES" ] = "yes";
        }

        else {
            dictionary[ "HELP" ] = "yes";
            cout << "Unknown option " << configCmdLine.at(i) << endl;
            break;
        }

#endif
    }

    // Ensure that QMAKESPEC exists in the mkspecs folder
    const QString mkspecPath = fixSeparators(sourcePath + "/mkspecs");
    QDirIterator itMkspecs(mkspecPath, QDir::AllDirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    QStringList mkspecs;

    while (itMkspecs.hasNext()) {
        QString mkspec = itMkspecs.next();
        // Remove base PATH
        mkspec.remove(0, mkspecPath.length() + 1);
        mkspecs << mkspec;
    }

    if (dictionary["QMAKESPEC"].toLower() == "features"
        || !mkspecs.contains(dictionary["QMAKESPEC"], Qt::CaseInsensitive)) {
        dictionary[ "HELP" ] = "yes";
        if (dictionary ["QMAKESPEC_FROM"] == "commandline") {
            cout << "Invalid option \"" << dictionary["QMAKESPEC"] << "\" for -platform." << endl;
        } else if (dictionary ["QMAKESPEC_FROM"] == "env") {
            cout << "QMAKESPEC environment variable is set to \"" << dictionary["QMAKESPEC"]
                 << "\" which is not a supported platform" << endl;
        } else { // was autodetected from environment
            cout << "Unable to detect the platform from environment. Use -platform command line"
                    "argument or set the QMAKESPEC environment variable and run configure again" << endl;
        }
        cout << "See the README file for a list of supported operating systems and compilers." << endl;
    } else {
        const QString qmakeSpec = dictionary[ "QMAKESPEC" ];
        if (qmakeSpec.endsWith("-icc") ||
            qmakeSpec.endsWith("-msvc") ||
            qmakeSpec.endsWith("-msvc.net") ||
            qmakeSpec.endsWith("-msvc2002") ||
            qmakeSpec.endsWith("-msvc2003") ||
            qmakeSpec.endsWith("-msvc2005") ||
            qmakeSpec.endsWith("-msvc2008") ||
            qmakeSpec.endsWith("-msvc2010") ||
            qmakeSpec.endsWith("-msvc2012") ||
            qmakeSpec.endsWith("-msvc2013") ||
            qmakeSpec.endsWith("-msvc2015") ||
            qmakeSpec.endsWith("-msvc2017")) {
            if (dictionary[ "MAKE" ].isEmpty()) dictionary[ "MAKE" ] = "nmake";
            dictionary[ "QMAKEMAKEFILE" ] = "Makefile.win32";
        } else if (qmakeSpec.contains("win32-g++")) {
            if (dictionary[ "MAKE" ].isEmpty()) dictionary[ "MAKE" ] = "mingw32-make";
            if (Environment::detectExecutable("sh.exe")) {
                dictionary[ "QMAKEMAKEFILE" ] = "Makefile.win32-g++-sh";
            } else {
                dictionary[ "QMAKEMAKEFILE" ] = "Makefile.win32-g++";
            }
        } else {
            if (dictionary[ "MAKE" ].isEmpty()) dictionary[ "MAKE" ] = "make";
            dictionary[ "QMAKEMAKEFILE" ] = "Makefile.win32";
        }
    }

    // Tell the user how to proceed building Qt after configure finished its job
    dictionary["QTBUILDINSTRUCTION"] = dictionary["MAKE"];
    if (dictionary.contains("XQMAKESPEC")) {
        if (dictionary["XQMAKESPEC"].startsWith("symbian")) {
            dictionary["QTBUILDINSTRUCTION"] = QString("make debug-winscw|debug-armv5|release-armv5");
        } else if (dictionary["XQMAKESPEC"].startsWith("wince")) {
            dictionary["QTBUILDINSTRUCTION"] =
                QString("setcepaths.bat ") + dictionary["XQMAKESPEC"] + QString(" && ") + dictionary["MAKE"];
        }
    }

    // Tell the user how to confclean before the next configure
    dictionary["CONFCLEANINSTRUCTION"] = dictionary["MAKE"] + QString(" confclean");

    // Ensure that -spec (XQMAKESPEC) exists in the mkspecs folder as well
    if (dictionary.contains("XQMAKESPEC") &&
        !mkspecs.contains(dictionary["XQMAKESPEC"], Qt::CaseInsensitive)) {
            dictionary["HELP"] = "yes";
            cout << "Invalid option \"" << dictionary["XQMAKESPEC"] << "\" for -xplatform." << endl;
    }

    // Ensure that the crt to be deployed can be found
    if (dictionary["CE_CRT"] != QLatin1String("yes") && dictionary["CE_CRT"] != QLatin1String("no")) {
        QDir cDir(dictionary["CE_CRT"]);
        QStringList entries = cDir.entryList();
        bool hasDebug = entries.contains("msvcr80.dll");
        bool hasRelease = entries.contains("msvcr80d.dll");
        if ((dictionary["BUILDALL"] == "auto") && (!hasDebug || !hasRelease)) {
            cout << "Could not find debug and release c-runtime." << endl;
            cout << "You need to have msvcr80.dll and msvcr80d.dll in" << endl;
            cout << "the path specified. Setting to -no-crt";
            dictionary[ "CE_CRT" ] = "no";
        } else if ((dictionary["BUILD"] == "debug") && !hasDebug) {
            cout << "Could not find debug c-runtime (msvcr80d.dll) in the directory specified." << endl;
            cout << "Setting c-runtime automatic deployment to -no-crt" << endl;
            dictionary[ "CE_CRT" ] = "no";
        } else if ((dictionary["BUILD"] == "release") && !hasRelease) {
            cout << "Could not find release c-runtime (msvcr80.dll) in the directory specified." << endl;
            cout << "Setting c-runtime automatic deployment to -no-crt" << endl;
            dictionary[ "CE_CRT" ] = "no";
        }
    }

    useUnixSeparators = dictionary["QMAKESPEC"].contains("win32-g++");

    // Allow tests for private classes to be compiled against internal builds
    if (dictionary["BUILDDEV"] == "yes")
        qtConfig += "private_tests";


#if !defined(EVAL)
    for (QStringList::Iterator dis = disabledModules.begin(); dis != disabledModules.end(); ++dis) {
        modules.removeAll((*dis));
    }
    for (QStringList::Iterator ena = enabledModules.begin(); ena != enabledModules.end(); ++ena) {
        if (modules.indexOf((*ena)) == -1)
            modules += (*ena);
    }
    qtConfig += modules;

    for (QStringList::Iterator it = disabledModules.begin(); it != disabledModules.end(); ++it)
        qtConfig.removeAll(*it);

    if ((dictionary[ "REDO" ] != "yes") && (dictionary[ "HELP" ] != "yes"))
        saveCmdLine();
#endif
}

#if !defined(EVAL)
void Configure::validateArgs()
{
    // Validate the specified config

    // Get all possible configurations from the file system.
    QDir dir;
    QStringList filters;
    filters << "qconfig-*.h";
    dir.setNameFilters(filters);
    dir.setPath(sourcePath + "/src/corelib/global/");

    QStringList stringList =  dir.entryList();

    QStringList::Iterator it;
    for (it = stringList.begin(); it != stringList.end(); ++it)
        allConfigs << it->remove("qconfig-").remove(".h");
    allConfigs << "full";

    // Try internal configurations first.
    QStringList possible_configs = QStringList()
        << "minimal"
        << "small"
        << "medium"
        << "large"
        << "full";
    int index = possible_configs.indexOf(dictionary["QCONFIG"]);
    if (index >= 0) {
        for (int c = 0; c <= index; c++) {
            qmakeConfig += possible_configs[c] + "-config";
        }
        return;
    }

    // If the internal configurations failed, try others.
    QStringList::Iterator config;
    for (config = allConfigs.begin(); config != allConfigs.end(); ++config) {
        if ((*config) == dictionary[ "QCONFIG" ])
            break;
    }
    if (config == allConfigs.end()) {
        dictionary[ "HELP" ] = "yes";
        cout << "No such configuration \"" << qPrintable(dictionary[ "QCONFIG" ]) << "\"" << endl ;
    }
    else
        qmakeConfig += (*config) + "-config";
}
#endif


// Output helper functions --------------------------------[ Start ]-
/*!
    Determines the length of a string token.
*/
static int tokenLength(const char *str)
{
    if (*str == 0)
        return 0;

    const char *nextToken = strpbrk(str, " _/\n\r");
    if (nextToken == str || !nextToken)
        return 1;

    return int(nextToken - str);
}

/*!
    Prints out a string which starts at position \a startingAt, and
    indents each wrapped line with \a wrapIndent characters.
    The wrap point is set to the console width, unless that width
    cannot be determined, or is too small.
*/
void Configure::desc(const char *description, int startingAt, int wrapIndent)
{
    int linePos = startingAt;

    bool firstLine = true;
    const char *nextToken = description;
    while (*nextToken) {
        int nextTokenLen = tokenLength(nextToken);
        if (*nextToken == '\n'                         // Wrap on newline, duh
            || (linePos + nextTokenLen > outputWidth)) // Wrap at outputWidth
        {
            printf("\n");
            linePos = 0;
            firstLine = false;
            if (*nextToken == '\n')
                ++nextToken;
            continue;
        }
        if (!firstLine && linePos < wrapIndent) {  // Indent to wrapIndent
            printf("%*s", wrapIndent , "");
            linePos = wrapIndent;
            if (*nextToken == ' ') {
                ++nextToken;
                continue;
            }
        }
        printf("%.*s", nextTokenLen, nextToken);
        linePos += nextTokenLen;
        nextToken += nextTokenLen;
    }
}

/*!
    Prints out an option with its description wrapped at the
    description starting point. If \a skipIndent is true, the
    indentation to the option is not outputted (used by marked option
    version of desc()). Extra spaces between option and its
    description is filled with\a fillChar, if there's available
    space.
*/
void Configure::desc(const char *option, const char *description, bool skipIndent, char fillChar)
{
    if (!skipIndent)
        printf("%*s", optionIndent, "");

    int remaining  = descIndent - optionIndent - strlen(option);
    int wrapIndent = descIndent + qMax(0, 1 - remaining);
    printf("%s", option);

    if (remaining > 2) {
        printf(" "); // Space in front
        for (int i = remaining; i > 2; --i)
            printf("%c", fillChar); // Fill, if available space
    }
    printf(" "); // Space between option and description

    desc(description, wrapIndent, wrapIndent);
    printf("\n");
}

/*!
    Same as above, except it also marks an option with an '*', if
    the option is default action.
*/
void Configure::desc(const char *mark_option, const char *mark, const char *option, const char *description, char fillChar)
{
    const QString markedAs = dictionary.value(mark_option);
    if (markedAs == "auto" && markedAs == mark) // both "auto", always => +
        printf(" +  ");
    else if (markedAs == "auto")                // setting marked as "auto" and option is default => +
        printf(" %c  " , (defaultTo(mark_option) == QLatin1String(mark))? '+' : ' ');
    else if (QLatin1String(mark) == "auto" && markedAs != "no")     // description marked as "auto" and option is available => +
        printf(" %c  " , checkAvailability(mark_option) ? '+' : ' ');
    else                                        // None are "auto", (markedAs == mark) => *
        printf(" %c  " , markedAs == QLatin1String(mark) ? '*' : ' ');

    desc(option, description, true, fillChar);
}

/*!
    Modifies the default configuration based on given -platform option.
    Eg. switches to different default styles for Windows CE.
*/
void Configure::applySpecSpecifics()
{
    if (!dictionary[ "XQMAKESPEC" ].isEmpty()) {
        //Disable building tools, docs and translations when cross compiling.
        disabledBuildParts << "docs" << "translations" << "tools";
    }

    if (dictionary[ "XQMAKESPEC" ].startsWith("wince")) {
        dictionary[ "STYLE_WINDOWSXP" ]     = "no";
        dictionary[ "STYLE_WINDOWSVISTA" ]  = "no";
        dictionary[ "STYLE_PLASTIQUE" ]     = "no";
        dictionary[ "STYLE_CLEANLOOKS" ]    = "no";
        dictionary[ "STYLE_WINDOWSCE" ]     = "yes";
        dictionary[ "STYLE_WINDOWSMOBILE" ] = "yes";
        dictionary[ "STYLE_MOTIF" ]         = "no";
        dictionary[ "STYLE_CDE" ]           = "no";
        dictionary[ "STYLE_S60" ]           = "no";
        dictionary[ "FREETYPE" ]            = "no";
        dictionary[ "QT3SUPPORT" ]          = "no";
        dictionary[ "OPENGL" ]              = "no";
        dictionary[ "OPENSSL" ]             = "no";
        dictionary[ "STL" ]                 = "no";
        dictionary[ "EXCEPTIONS" ]          = "no";
        dictionary[ "RTTI" ]                = "no";
        dictionary[ "ARCHITECTURE" ]        = "windowsce";
        dictionary[ "3DNOW" ]               = "no";
        dictionary[ "SSE" ]                 = "no";
        dictionary[ "SSE2" ]                = "no";
        dictionary[ "MMX" ]                 = "no";
        dictionary[ "IWMMXT" ]              = "no";
        dictionary[ "CE_CRT" ]              = "yes";
        dictionary[ "WEBKIT" ]              = "no";
        dictionary[ "PHONON" ]              = "yes";
        dictionary[ "DIRECTSHOW" ]          = "no";
        dictionary[ "LARGE_FILE" ]          = "no";
        // We only apply MMX/IWMMXT for mkspecs we know they work
        if (dictionary[ "XQMAKESPEC" ].startsWith("wincewm")) {
            dictionary[ "MMX" ]    = "yes";
            dictionary[ "IWMMXT" ] = "yes";
            dictionary[ "DIRECTSHOW" ] = "yes";
        }
        dictionary[ "QT_HOST_PREFIX" ]      = dictionary[ "QT_INSTALL_PREFIX" ];
        dictionary[ "QT_INSTALL_PREFIX" ]   = "";

    } else if (dictionary[ "XQMAKESPEC" ].startsWith("symbian")) {
        dictionary[ "ACCESSIBILITY" ]       = "no";
        dictionary[ "STYLE_WINDOWSXP" ]     = "no";
        dictionary[ "STYLE_WINDOWSVISTA" ]  = "no";
        dictionary[ "STYLE_PLASTIQUE" ]     = "no";
        dictionary[ "STYLE_CLEANLOOKS" ]    = "no";
        dictionary[ "STYLE_WINDOWSCE" ]     = "no";
        dictionary[ "STYLE_WINDOWSMOBILE" ] = "no";
        dictionary[ "STYLE_MOTIF" ]         = "no";
        dictionary[ "STYLE_CDE" ]           = "no";
        dictionary[ "STYLE_S60" ]           = "yes";
        dictionary[ "FREETYPE" ]            = "no";
        dictionary[ "QT3SUPPORT" ]          = "no";
        dictionary[ "OPENGL" ]              = "no";
        dictionary[ "OPENSSL" ]             = "yes";
        // On Symbian we now always will have IPv6 with no chance to disable it
        dictionary[ "IPV6" ]                = "yes";
        dictionary[ "STL" ]                 = "yes";
        dictionary[ "EXCEPTIONS" ]          = "yes";
        dictionary[ "RTTI" ]                = "yes";
        dictionary[ "ARCHITECTURE" ]        = "symbian";
        dictionary[ "3DNOW" ]               = "no";
        dictionary[ "SSE" ]                 = "no";
        dictionary[ "SSE2" ]                = "no";
        dictionary[ "MMX" ]                 = "no";
        dictionary[ "IWMMXT" ]              = "no";
        dictionary[ "CE_CRT" ]              = "no";
        dictionary[ "DIRECT3D" ]            = "no";
        dictionary[ "WEBKIT" ]              = "yes";
        dictionary[ "ASSISTANT_WEBKIT" ]    = "no";
        dictionary[ "PHONON" ]              = "yes";
        dictionary[ "XMLPATTERNS" ]         = "yes";
        dictionary[ "QT_GLIB" ]             = "no";
        dictionary[ "S60" ]                 = "yes";
        dictionary[ "SYMBIAN_DEFFILES" ]    = "yes";
        // iconv makes makes apps start and run ridiculously slowly in symbian emulator (HW not tested)
        // iconv_open seems to return -1 always, so something is probably missing from the platform.
        dictionary[ "QT_ICONV" ]            = "no";
        dictionary[ "SCRIPTTOOLS" ]         = "no";
        dictionary[ "QT_HOST_PREFIX" ]      = dictionary[ "QT_INSTALL_PREFIX" ];
        dictionary[ "QT_INSTALL_PREFIX" ]   = "";
        dictionary[ "QT_INSTALL_PLUGINS" ]  = "\\resource\\qt\\plugins";
        dictionary[ "QT_INSTALL_IMPORTS" ]  = "\\resource\\qt\\imports";
        dictionary[ "QT_INSTALL_TRANSLATIONS" ]  = "\\resource\\qt\\translations";
        dictionary[ "ARM_FPU_TYPE" ]        = "softvfp";
        dictionary[ "SQL_SQLITE" ]          = "yes";
        dictionary[ "SQL_SQLITE_LIB" ]      = "system";

        // Disable building docs and translations for now
        disabledBuildParts << "docs" << "translations";

    } else if (dictionary[ "XQMAKESPEC" ].startsWith("linux")) { //TODO actually wrong.
      //TODO
        dictionary[ "STYLE_WINDOWSXP" ]     = "no";
        dictionary[ "STYLE_WINDOWSVISTA" ]  = "no";
        dictionary[ "KBD_DRIVERS" ]         = "tty";
        dictionary[ "GFX_DRIVERS" ]         = "linuxfb vnc";
        dictionary[ "MOUSE_DRIVERS" ]       = "pc linuxtp";
        dictionary[ "QT3SUPPORT" ]          = "no";
        dictionary[ "OPENGL" ]              = "no";
        dictionary[ "EXCEPTIONS" ]          = "no";
        dictionary[ "DBUS"]                 = "no";
        dictionary[ "QT_QWS_DEPTH" ]        = "4 8 16 24 32";
        dictionary[ "QT_SXE" ]              = "no";
        dictionary[ "QT_INOTIFY" ]          = "no";
        dictionary[ "QT_LPR" ]              = "no";
        dictionary[ "QT_CUPS" ]             = "no";
        dictionary[ "QT_GLIB" ]             = "no";
        dictionary[ "QT_ICONV" ]            = "no";

        dictionary["DECORATIONS"]           = "default windows styled";
    } else if (platform() == QNX || platform() == BLACKBERRY) {
        dictionary[ "STYLE_WINDOWSXP" ]     = "no";
        dictionary[ "STYLE_WINDOWSVISTA" ]  = "no";
        dictionary[ "STYLE_WINDOWSCE" ]     = "no";
        dictionary[ "STYLE_WINDOWSMOBILE" ] = "no";
        dictionary[ "STYLE_S60" ]           = "no";
        dictionary[ "3DNOW" ]               = "no";
        dictionary[ "SSE" ]                 = "no";
        dictionary[ "SSE2" ]                = "no";
        dictionary[ "MMX" ]                 = "no";
        dictionary[ "IWMMXT" ]              = "no";
        dictionary[ "CE_CRT" ]              = "no";
        dictionary[ "PHONON" ]              = "no";
        dictionary[ "NIS" ]                 = "no";
        dictionary[ "QT_CUPS" ]             = "no";
        dictionary[ "WEBKIT" ]              = "no";
        dictionary[ "ACCESSIBILITY" ]       = "no";
        dictionary[ "POSIX_IPC" ]           = "yes";
        dictionary[ "QPA" ]                 = "yes";
        dictionary[ "QT_ICONV" ]            = "yes";
        dictionary[ "LITTLE_ENDIAN" ]       = "yes";
        dictionary[ "LARGE_FILE" ]          = "yes";
        dictionary[ "XMLPATTERNS" ]         = "yes";
        dictionary[ "FONT_CONFIG" ]         = "yes";
        dictionary[ "FONT_CONFIG" ]         = "yes";
        dictionary[ "FREETYPE" ]            = "system";
        dictionary[ "STACK_PROTECTOR_STRONG" ] = "auto";
        dictionary[ "SLOG2" ]                 = "auto";
        dictionary[ "QT_INOTIFY" ]          = "yes";
    }
}

QString Configure::locateFileInPaths(const QString &fileName, const QStringList &paths)
{
    QDir d;
    for (QStringList::ConstIterator it = paths.begin(); it != paths.end(); ++it) {
        // Remove any leading or trailing ", this is commonly used in the environment
        // variables
        QString path = (*it);
        if (path.startsWith("\""))
            path = path.right(path.length() - 1);
        if (path.endsWith("\""))
            path = path.left(path.length() - 1);
        if (d.exists(path + QDir::separator() + fileName)) {
            return (path);
        }
    }
    return QString();
}

QString Configure::locateFile(const QString &fileName)
{
    QString file = fileName.toLower();
    QStringList paths;
#if defined(Q_OS_WIN32)
    QRegExp splitReg("[;,]");
#else
    QRegExp splitReg("[:]");
#endif
    if (file.endsWith(".h"))
        paths = QString::fromLocal8Bit(getenv("INCLUDE")).split(splitReg, QString::SkipEmptyParts);
    else if (file.endsWith(".lib"))
        paths = QString::fromLocal8Bit(getenv("LIB")).split(splitReg, QString::SkipEmptyParts);
    else
        paths = QString::fromLocal8Bit(getenv("PATH")).split(splitReg, QString::SkipEmptyParts);
    return locateFileInPaths(file, paths);
}

// Output helper functions ---------------------------------[ Stop ]-


bool Configure::displayHelp()
{
    if (dictionary[ "HELP" ] == "yes") {
        desc("Usage: configure [-buildkey <key>]\n"
//      desc("Usage: configure [-prefix dir] [-bindir <dir>] [-libdir <dir>]\n"
//                  "[-docdir <dir>] [-headerdir <dir>] [-plugindir <dir>]\n"
//                  "[-importdir <dir>] [-datadir <dir>] [-translationdir <dir>]\n"
//                  "[-examplesdir <dir>] [-demosdir <dir>][-buildkey <key>]\n"
                    "[-release] [-debug] [-debug-and-release] [-shared] [-static]\n"
                    "[-no-fast] [-fast] [-no-exceptions] [-exceptions]\n"
                    "[-no-accessibility] [-accessibility] [-no-rtti] [-rtti]\n"
                    "[-no-stl] [-stl] [-no-sql-<driver>] [-qt-sql-<driver>]\n"
                    "[-plugin-sql-<driver>] [-system-sqlite] [-arch <arch>]\n"
                    "[-D <define>] [-I <includepath>] [-L <librarypath>]\n"
                    "[-help] [-no-dsp] [-dsp] [-no-vcproj] [-vcproj]\n"
                    "[-no-qmake] [-qmake] [-dont-process] [-process]\n"
                    "[-no-style-<style>] [-qt-style-<style>] [-redo]\n"
                    "[-saveconfig <config>] [-loadconfig <config>]\n"
                    "[-qt-zlib] [-system-zlib] [-no-gif] [-no-libpng]\n"
                    "[-qt-libpng] [-system-libpng] [-no-libtiff] [-qt-libtiff]\n"
                    "[-system-libtiff] [-no-libjpeg] [-qt-libjpeg] [-system-libjpeg]\n"
                    "[-no-libmng] [-qt-libmng] [-system-libmng] [-no-qt3support] [-mmx]\n"
                    "[-no-mmx] [-3dnow] [-no-3dnow] [-sse] [-no-sse] [-sse2] [-no-sse2]\n"
                    "[-no-iwmmxt] [-iwmmxt] [-openssl] [-openssl-linked]\n"
                    "[-no-openssl] [-no-dbus] [-dbus] [-dbus-linked] [-platform <spec>]\n"
                    "[-qtnamespace <namespace>] [-qtlibinfix <infix>] [-no-phonon]\n"
                    "[-phonon] [-no-phonon-backend] [-phonon-backend]\n"
                    "[-no-multimedia] [-multimedia] [-no-audio-backend] [-audio-backend]\n"
                    "[-no-script] [-script] [-no-scripttools] [-scripttools]\n"
                    "[-no-webkit] [-webkit] [-webkit-debug]\n"
                    "[-graphicssystem raster|opengl|openvg]\n"
                    "[-no-directwrite] [-directwrite] [-no-nis] [-nis] [-qpa]\n"
                    "[-no-cups] [-cups] [-no-iconv] [-iconv] [-sun-iconv] [-gnu-iconv]\n"
                    "[-neon] [-no-neon] [-largefile] [-little-endian] [-big-endian]\n"
                    "[-font-config] [-no-fontconfig] [-posix-ipc]\n\n", 0, 7);

        desc("Installation options:\n\n");

#if !defined(EVAL)
/*
        desc(" These are optional, but you may specify install directories.\n\n", 0, 1);

        desc(                   "-prefix dir",          "This will install everything relative to dir\n(default $QT_INSTALL_PREFIX)\n");

        desc(" You may use these to separate different parts of the install:\n\n", 0, 1);

        desc(                   "-bindir <dir>",        "Executables will be installed to dir\n(default PREFIX/bin)");
        desc(                   "-libdir <dir>",        "Libraries will be installed to dir\n(default PREFIX/lib)");
        desc(                   "-docdir <dir>",        "Documentation will be installed to dir\n(default PREFIX/doc)");
        desc(                   "-headerdir <dir>",     "Headers will be installed to dir\n(default PREFIX/include)");
        desc(                   "-plugindir <dir>",     "Plugins will be installed to dir\n(default PREFIX/plugins)");
        desc(                   "-importdir <dir>",     "Imports for QML will be installed to dir\n(default PREFIX/imports)");
        desc(                   "-datadir <dir>",       "Data used by Qt programs will be installed to dir\n(default PREFIX)");
        desc(                   "-translationdir <dir>","Translations of Qt programs will be installed to dir\n(default PREFIX/translations)\n");
        desc(                   "-examplesdir <dir>",   "Examples will be installed to dir\n(default PREFIX/examples)");
        desc(                   "-demosdir <dir>",      "Demos will be installed to dir\n(default PREFIX/demos)");
*/
        desc(" You may use these options to turn on strict plugin loading:\n\n", 0, 1);

        desc(                   "-buildkey <key>",      "Build the Qt library and plugins using the specified <key>.  "
                                                        "When the library loads plugins, it will only load those that have a matching <key>.\n");

        desc("Configure options:\n\n");

        desc(" The defaults (*) are usually acceptable. A plus (+) denotes a default value"
             " that needs to be evaluated. If the evaluation succeeds, the feature is"
             " included. Here is a short explanation of each option:\n\n", 0, 1);

        desc("BUILD", "release","-release",             "Compile and link Qt with debugging turned off.");
        desc("BUILD", "debug",  "-debug",               "Compile and link Qt with debugging turned on.");
        desc("BUILDALL", "yes", "-debug-and-release",   "Compile and link two Qt libraries, with and without debugging turned on.\n");

        desc("OPENSOURCE", "opensource", "-opensource",   "Compile and link the Open-Source Edition of Qt.");
        desc("COMMERCIAL", "commercial", "-commercial",   "Compile and link the Commercial Edition of Qt.\n");

        desc("BUILDDEV", "yes", "-developer-build",      "Compile and link Qt with Qt developer options (including auto-tests exporting)\n");

        desc("SHARED", "yes",   "-shared",              "Create and use shared Qt libraries.");
        desc("SHARED", "no",    "-static",              "Create and use static Qt libraries.\n");

        desc("LTCG", "yes",   "-ltcg",                  "Use Link Time Code Generation. (Release builds only)");
        desc("LTCG", "no",    "-no-ltcg",               "Do not use Link Time Code Generation.\n");

        desc("FAST", "no",      "-no-fast",             "Configure Qt normally by generating Makefiles for all project files.");
        desc("FAST", "yes",     "-fast",                "Configure Qt quickly by generating Makefiles only for library and "
                                                        "subdirectory targets.  All other Makefiles are created as wrappers "
                                                        "which will in turn run qmake\n");

        desc("EXCEPTIONS", "no", "-no-exceptions",      "Disable exceptions on platforms that support it.");
        desc("EXCEPTIONS", "yes","-exceptions",         "Enable exceptions on platforms that support it.\n");

        desc("ACCESSIBILITY", "no",  "-no-accessibility", "Do not compile Windows Active Accessibility support.");
        desc("ACCESSIBILITY", "yes", "-accessibility",    "Compile Windows Active Accessibility support.\n");

        desc("STL", "no",       "-no-stl",              "Do not compile STL support.");
        desc("STL", "yes",      "-stl",                 "Compile STL support.\n");

        desc(                   "-no-sql-<driver>",     "Disable SQL <driver> entirely, by default none are turned on.");
        desc(                   "-qt-sql-<driver>",     "Enable a SQL <driver> in the Qt Library.");
        desc(                   "-plugin-sql-<driver>", "Enable SQL <driver> as a plugin to be linked to at run time.\n"
                                                        "Available values for <driver>:");
        desc("SQL_MYSQL", "auto", "",                   "  mysql", ' ');
        desc("SQL_PSQL", "auto", "",                    "  psql", ' ');
        desc("SQL_OCI", "auto", "",                     "  oci", ' ');
        desc("SQL_ODBC", "auto", "",                    "  odbc", ' ');
        desc("SQL_TDS", "auto", "",                     "  tds", ' ');
        desc("SQL_DB2", "auto", "",                     "  db2", ' ');
        desc("SQL_SQLITE", "auto", "",                  "  sqlite", ' ');
        desc("SQL_SQLITE2", "auto", "",                 "  sqlite2", ' ');
        desc("SQL_IBASE", "auto", "",                   "  ibase", ' ');
        desc(                   "",                     "(drivers marked with a '+' have been detected as available on this system)\n", false, ' ');

        desc(                   "-system-sqlite",       "Use sqlite from the operating system.\n");

        desc("QT3SUPPORT", "no","-no-qt3support",       "Disables the Qt 3 support functionality.\n");
        desc("OPENGL", "no","-no-opengl",               "Disables OpenGL functionality\n");
        desc("OPENGL", "no","-opengl <api>",            "Enable OpenGL support with specified API version.\n"
                                                        "Available values for <api>:");
        desc("", "", "",                                "  desktop - Enable support for Desktop OpenGL", ' ');
        desc("OPENGL_ES_CM", "no", "",                  "  es1 - Enable support for OpenGL ES Common Profile", ' ');
        desc("OPENGL_ES_2",  "no", "",                  "  es2 - Enable support for OpenGL ES 2.0", ' ');

        desc("OPENVG", "no","-no-openvg",               "Disables OpenVG functionality\n");
        desc("OPENVG", "yes","-openvg",                 "Enables OpenVG functionality");
        desc(                   "",                     "Requires EGL support, typically supplied by an OpenGL", false, ' ');
        desc(                   "",                     "or other graphics implementation\n", false, ' ');

#endif
        desc(                   "-platform <spec>",     "The operating system and compiler you are building on.\n(default %QMAKESPEC%)\n");
        desc(                   "-xplatform <spec>",    "The operating system and compiler you are cross compiling to.\n");
        desc(                   "",                     "See the README file for a list of supported operating systems and compilers.\n", false, ' ');

        desc("NIS",           "no",      "-no-nis",     "Do not build NIS support.");
        desc("NIS",           "yes",     "-nis",        "Build NIS support.");

        desc("QPA",           "yes",     "-qpa",        "Enable the QPA build. QPA is a window system agnostic implementation of Qt.");

        desc("NEON",          "yes",     "-neon",       "Enable the use of NEON instructions.");
        desc("NEON",          "no",      "-no-neon",    "Do not enable the use of NEON instructions.");

        desc("QT_ICONV",      "disable", "-no-iconv",   "Do not enable support for iconv(3).");
        desc("QT_ICONV",      "yes",     "-iconv",      "Enable support for iconv(3).");
        desc("QT_ICONV",      "yes",     "-sun-iconv",  "Enable support for iconv(3) using sun-iconv.");
        desc("QT_ICONV",      "yes",     "-gnu-iconv",  "Enable support for iconv(3) using gnu-libiconv");

        desc("QT_INOTIFY",    "yes",     "-inotify",    "Enable Qt inotify(7) support.\n");
        desc("QT_INOTIFY",    "no",      "-no-inotify", "Disable Qt inotify(7) support.\n");

        desc("LARGE_FILE",    "yes",   "-largefile",    "Enables Qt to access files larger than 4 GB.");

        desc("LITTLE_ENDIAN", "yes",   "-little-endian","Target platform is little endian (LSB first).");
        desc("LITTLE_ENDIAN", "no",    "-big-endian",   "Target platform is big endian (MSB first).");

        desc("FONT_CONFIG",   "yes",   "-fontconfig",   "Build with FontConfig support.");
        desc("FONT_CONFIG",   "no",    "-no-fontconfig","Do not build with FontConfig support.");

        desc("POSIX_IPC",     "yes",   "-posix-ipc",    "Enable POSIX IPC.");

        desc("SYSTEM_PROXIES", "yes",  "-system-proxies",    "Use system network proxies by default.");
        desc("SYSTEM_PROXIES", "no",   "-no-system-proxies", "Do not use system network proxies by default.");

#if !defined(EVAL)
        desc(                   "-qtnamespace <namespace>", "Wraps all Qt library code in 'namespace name {...}");
        desc(                   "-qtlibinfix <infix>",  "Renames all Qt* libs to Qt*<infix>\n");
        desc(                   "-D <define>",          "Add an explicit define to the preprocessor.");
        desc(                   "-I <includepath>",     "Add an explicit include path.");
        desc(                   "-L <librarypath>",     "Add an explicit library path.");
        desc(                   "-l <libraryname>",     "Add an explicit library name, residing in a librarypath.\n");
#endif
        desc(                   "-graphicssystem <sys>",   "Specify which graphicssystem should be used.\n"
                                "Available values for <sys>:");
        desc("GRAPHICS_SYSTEM", "raster", "",  "  raster - Software rasterizer", ' ');
        desc("GRAPHICS_SYSTEM", "opengl", "",  "  opengl - Using OpenGL acceleration, experimental!", ' ');
        desc("GRAPHICS_SYSTEM", "openvg", "",  "  openvg - Using OpenVG acceleration, experimental!\n", ' ');

        desc(                   "-help, -h, -?",        "Display this information.\n");

#if !defined(EVAL)
        // 3rd party stuff options go below here --------------------------------------------------------------------------------
        desc("Third Party Libraries:\n\n");

        desc("ZLIB", "qt",      "-qt-zlib",             "Use the zlib bundled with Qt.");
        desc("ZLIB", "system",  "-system-zlib",         "Use zlib from the operating system.\nSee http://www.gzip.org/zlib\n");

        desc("GIF", "no",       "-no-gif",              "Do not compile GIF reading support.");

        desc("LIBPNG", "no",    "-no-libpng",           "Do not compile PNG support.");
        desc("LIBPNG", "qt",    "-qt-libpng",           "Use the libpng bundled with Qt.");
        desc("LIBPNG", "system","-system-libpng",       "Use libpng from the operating system.\nSee http://www.libpng.org/pub/png\n");

        desc("LIBMNG", "no",    "-no-libmng",           "Do not compile MNG support.");
        desc("LIBMNG", "qt",    "-qt-libmng",           "Use the libmng bundled with Qt.");
        desc("LIBMNG", "system","-system-libmng",       "Use libmng from the operating system.\nSee See http://www.libmng.com\n");

        desc("LIBTIFF", "no",    "-no-libtiff",         "Do not compile TIFF support.");
        desc("LIBTIFF", "qt",    "-qt-libtiff",         "Use the libtiff bundled with Qt.");
        desc("LIBTIFF", "system","-system-libtiff",     "Use libtiff from the operating system.\nSee http://www.libtiff.org\n");

        desc("LIBJPEG", "no",    "-no-libjpeg",         "Do not compile JPEG support.");
        desc("LIBJPEG", "qt",    "-qt-libjpeg",         "Use the libjpeg bundled with Qt.");
        desc("LIBJPEG", "system","-system-libjpeg",     "Use libjpeg from the operating system.\nSee http://www.ijg.org\n");

        if (platform() == QNX || platform() == BLACKBERRY) {
            desc("SLOG2", "yes",  "-slog2",             "Compile with slog2 support.");
            desc("SLOG2", "no",  "-no-slog2",           "Do not compile with slog2 support.");
        }

#endif
        // Qt\Windows only options go below here --------------------------------------------------------------------------------
        desc("Qt for Windows only:\n\n");

        desc("DSPFILES", "no",  "-no-dsp",              "Do not generate VC++ .dsp files.");
        desc("DSPFILES", "yes", "-dsp",                 "Generate VC++ .dsp files, only if spec \"win32-msvc\".\n");

        desc("VCPROJFILES", "no", "-no-vcproj",         "Do not generate VC++ .vcproj files.");
        desc("VCPROJFILES", "yes", "-vcproj",           "Generate VC++ .vcproj files, only if platform \"win32-msvc.net\".\n");

        desc("INCREDIBUILD_XGE", "no", "-no-incredibuild-xge", "Do not add IncrediBuild XGE distribution commands to custom build steps.");
        desc("INCREDIBUILD_XGE", "yes", "-incredibuild-xge",   "Add IncrediBuild XGE distribution commands to custom build steps. This will distribute MOC and UIC steps, and other custom buildsteps which are added to the INCREDIBUILD_XGE variable.\n(The IncrediBuild distribution commands are only added to Visual Studio projects)\n");

        desc("PLUGIN_MANIFESTS", "no", "-no-plugin-manifests", "Do not embed manifests in plugins.");
        desc("PLUGIN_MANIFESTS", "yes", "-plugin-manifests",   "Embed manifests in plugins.\n");

#if !defined(EVAL)
        desc("BUILD_QMAKE", "no", "-no-qmake",          "Do not compile qmake.");
        desc("BUILD_QMAKE", "yes", "-qmake",            "Compile qmake.\n");

        desc("NOPROCESS", "yes", "-dont-process",       "Do not generate Makefiles/Project files. This will override -no-fast if specified.");
        desc("NOPROCESS", "no",  "-process",            "Generate Makefiles/Project files.\n");

        desc("RTTI", "no",      "-no-rtti",             "Do not compile runtime type information.");
        desc("RTTI", "yes",     "-rtti",                "Compile runtime type information.\n");
        desc("MMX", "no",       "-no-mmx",              "Do not compile with use of MMX instructions");
        desc("MMX", "yes",      "-mmx",                 "Compile with use of MMX instructions");
        desc("3DNOW", "no",     "-no-3dnow",            "Do not compile with use of 3DNOW instructions");
        desc("3DNOW", "yes",    "-3dnow",               "Compile with use of 3DNOW instructions");
        desc("SSE", "no",       "-no-sse",              "Do not compile with use of SSE instructions");
        desc("SSE", "yes",      "-sse",                 "Compile with use of SSE instructions");
        desc("SSE2", "no",      "-no-sse2",             "Do not compile with use of SSE2 instructions");
        desc("SSE2", "yes",      "-sse2",               "Compile with use of SSE2 instructions");
        desc("OPENSSL", "no",    "-no-openssl",         "Do not compile in OpenSSL support");
        desc("OPENSSL", "yes",   "-openssl",            "Compile in run-time OpenSSL support");
        desc("OPENSSL", "linked","-openssl-linked",     "Compile in linked OpenSSL support");
        desc("DBUS", "no",       "-no-dbus",            "Do not compile in D-Bus support");
        desc("DBUS", "yes",      "-dbus",               "Compile in D-Bus support and load libdbus-1 dynamically");
        desc("DBUS", "linked",   "-dbus-linked",        "Compile in D-Bus support and link to libdbus-1");
        desc("PHONON", "no",    "-no-phonon",           "Do not compile in the Phonon module");
        desc("PHONON", "yes",   "-phonon",              "Compile the Phonon module (Phonon is built if a decent C++ compiler is used.)");
        desc("PHONON_BACKEND","no", "-no-phonon-backend","Do not compile the platform-specific Phonon backend-plugin");
        desc("PHONON_BACKEND","yes","-phonon-backend",  "Compile in the platform-specific Phonon backend-plugin");
        desc("MULTIMEDIA", "no", "-no-multimedia",      "Do not compile the multimedia module");
        desc("MULTIMEDIA", "yes","-multimedia",         "Compile in multimedia module");
        desc("AUDIO_BACKEND", "no","-no-audio-backend", "Do not compile in the platform audio backend into QtMultimedia");
        desc("AUDIO_BACKEND", "yes","-audio-backend",   "Compile in the platform audio backend into QtMultimedia");
        desc("WEBKIT", "no",    "-no-webkit",           "Do not compile in the WebKit module");
        desc("WEBKIT", "yes",   "-webkit",              "Compile in the WebKit module (WebKit is built if a decent C++ compiler is used.)");
        desc("WEBKIT", "debug", "-webkit-debug",        "Compile in the WebKit module with debug symbols.");
        desc("SCRIPT", "no",    "-no-script",           "Do not build the QtScript module.");
        desc("SCRIPT", "yes",   "-script",              "Build the QtScript module.");
        desc("SCRIPTTOOLS", "no", "-no-scripttools",    "Do not build the QtScriptTools module.");
        desc("SCRIPTTOOLS", "yes", "-scripttools",      "Build the QtScriptTools module.");
        desc("DECLARATIVE", "no",    "-no-declarative", "Do not build the declarative module");
        desc("DECLARATIVE", "yes",   "-declarative",    "Build the declarative module");
        desc("DECLARATIVE_DEBUG", "no",    "-no-declarative-debug", "Do not build the declarative debugging support");
        desc("DECLARATIVE_DEBUG", "yes",   "-declarative-debug",    "Build the declarative debugging support");
        desc("DIRECTWRITE", "no", "-no-directwrite", "Do not build support for DirectWrite font rendering");
        desc("DIRECTWRITE", "yes", "-directwrite", "Build support for DirectWrite font rendering (experimental, requires DirectWrite availability on target systems, e.g. Windows Vista with Platform Update, Windows 7, etc.)");

        desc(                   "-arch <arch>",         "Specify an architecture.\n"
                                                        "Available values for <arch>:");
        desc("ARCHITECTURE","windows",       "",        "  windows", ' ');
        desc("ARCHITECTURE","windowsce",     "",        "  windowsce", ' ');
        desc("ARCHITECTURE","symbian",     "",          "  symbian", ' ');
        desc("ARCHITECTURE","boundschecker",     "",    "  boundschecker", ' ');
        desc("ARCHITECTURE","generic", "",              "  generic\n", ' ');

        desc(                   "-no-style-<style>",    "Disable <style> entirely.");
        desc(                   "-qt-style-<style>",    "Enable <style> in the Qt Library.\nAvailable styles: ");

        desc("STYLE_WINDOWS", "yes", "",                "  windows", ' ');
        desc("STYLE_WINDOWSXP", "auto", "",             "  windowsxp", ' ');
        desc("STYLE_WINDOWSVISTA", "auto", "",          "  windowsvista", ' ');
        desc("STYLE_PLASTIQUE", "yes", "",              "  plastique", ' ');
        desc("STYLE_CLEANLOOKS", "yes", "",             "  cleanlooks", ' ');
        desc("STYLE_MOTIF", "yes", "",                  "  motif", ' ');
        desc("STYLE_CDE", "yes", "",                    "  cde", ' ');
        desc("STYLE_WINDOWSCE", "yes", "",              "  windowsce", ' ');
        desc("STYLE_WINDOWSMOBILE" , "yes", "",         "  windowsmobile", ' ');
        desc("STYLE_S60" , "yes", "",                   "  s60\n", ' ');
        desc("NATIVE_GESTURES", "no", "-no-native-gestures", "Do not use native gestures on Windows 7.");
        desc("NATIVE_GESTURES", "yes", "-native-gestures", "Use native gestures on Windows 7.");
        desc("MSVC_MP", "no", "-no-mp",                 "Do not use multiple processors for compiling with MSVC");
        desc("MSVC_MP", "yes", "-mp",                   "Use multiple processors for compiling with MSVC (-MP)");

/*      We do not support -qconfig on Windows yet

        desc(                   "-qconfig <local>",     "Use src/tools/qconfig-local.h rather than the default.\nPossible values for local:");
        for (int i=0; i<allConfigs.size(); ++i)
            desc(               "",                     qPrintable(QString("  %1").arg(allConfigs.at(i))), false, ' ');
        printf("\n");
*/
#endif
        desc(                   "-loadconfig <config>", "Run configure with the parameters from file configure_<config>.cache.");
        desc(                   "-saveconfig <config>", "Run configure and save the parameters in file configure_<config>.cache.");
        desc(                   "-redo",                "Run configure with the same parameters as last time.\n");

        // Qt\Windows CE only options go below here -----------------------------------------------------------------------------
        desc("Qt for Windows CE only:\n\n");
        desc("IWMMXT", "no",       "-no-iwmmxt",           "Do not compile with use of IWMMXT instructions");
        desc("IWMMXT", "yes",      "-iwmmxt",              "Do compile with use of IWMMXT instructions (Qt for Windows CE on Arm only)");
        desc("CE_CRT", "no",       "-no-crt" ,             "Do not add the C runtime to default deployment rules");
        desc("CE_CRT", "yes",      "-qt-crt",              "Qt identifies C runtime during project generation");
        desc(                      "-crt <path>",          "Specify path to C runtime used for project generation.");
        desc("CETEST", "no",       "-no-cetest",           "Do not compile Windows CE remote test application");
        desc("CETEST", "yes",      "-cetest",              "Compile Windows CE remote test application");
        desc(                      "-signature <file>",    "Use file for signing the target project");

        desc("DIRECTSHOW", "no",   "-phonon-wince-ds9",    "Enable Phonon Direct Show 9 backend for Windows CE");

        // Qt\Symbian only options go below here -----------------------------------------------------------------------------
        desc("Qt for Symbian OS only:\n\n");
        desc("FREETYPE", "no",     "-no-freetype",         "Do not compile in Freetype2 support.");
        desc("FREETYPE", "yes",    "-qt-freetype",         "Use the libfreetype bundled with Qt.");
        desc("FREETYPE", "yes",    "-system-freetype",     "Use the libfreetype provided by the system.");
        desc(                      "-fpu <flags>",         "VFP type on ARM, supported options: softvfp(default) | vfpv2 | softvfp+vfpv2");
        desc("S60", "no",          "-no-s60",              "Do not compile in S60 support.");
        desc("S60", "yes",         "-s60",                 "Compile with support for the S60 UI Framework");
        desc("SYMBIAN_DEFFILES", "no",  "-no-usedeffiles",  "Disable the usage of DEF files.");
        desc("SYMBIAN_DEFFILES", "yes", "-usedeffiles",     "Enable the usage of DEF files.\n");
        return true;
    }
    return false;
}

QString Configure::findFileInPaths(const QString &fileName, const QString &paths)
{
#if defined(Q_OS_WIN32)
    QRegExp splitReg("[;,]");
#else
    QRegExp splitReg("[:]");
#endif
    QStringList pathList = paths.split(splitReg, QString::SkipEmptyParts);
    QDir d;
    for (QStringList::ConstIterator it = pathList.begin(); it != pathList.end(); ++it) {
        // Remove any leading or trailing ", this is commonly used in the environment
        // variables
        QString path = (*it);
        if (path.startsWith('\"'))
            path = path.right(path.length() - 1);
        if (path.endsWith('\"'))
            path = path.left(path.length() - 1);
        if (d.exists(path + QDir::separator() + fileName))
            return path;
    }
    return QString();
}

static QString mingwPaths(const QString &mingwPath, const QString &pathName)
{
    QString ret;
    QDir mingwDir = QFileInfo(mingwPath).dir();
    const QFileInfoList subdirs = mingwDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (int i = 0 ;i < subdirs.length(); ++i) {
        const QFileInfo &fi = subdirs.at(i);
        const QString name = fi.fileName();
        if (name == pathName)
            ret += fi.absoluteFilePath() + ';';
        else if (name.contains("mingw"))
            ret += fi.absoluteFilePath() + QDir::separator() + pathName + ';';
    }
    return ret;
}

bool Configure::findFile(const QString &fileName)
{
    const QString file = fileName.toLower();
    const QString pathEnvVar = QString::fromLocal8Bit(getenv("PATH"));
    const QString mingwPath = dictionary["QMAKESPEC"].endsWith("-g++") ?
        findFileInPaths("g++.exe", pathEnvVar) : QString();

    QString paths;
    if (file.endsWith(".h")) {
        if (!mingwPath.isNull()) {
            if (!findFileInPaths(file, mingwPaths(mingwPath, "include")).isNull())
                return true;
            //now let's try the additional compiler path

            const QFileInfoList mingwConfigs = QDir(mingwPath + QLatin1String("/../lib/gcc")).entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (int i = 0; i < mingwConfigs.length(); ++i) {
                const QDir mingwLibDir = mingwConfigs.at(i).absoluteFilePath();
                foreach(const QFileInfo &version, mingwLibDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)) {
                    if (!findFileInPaths(file, version.absoluteFilePath() + QLatin1String("/include")).isNull())
                        return true;
                }
            }
        }
        paths = QString::fromLocal8Bit(getenv("INCLUDE"));
    } else if (file.endsWith(".lib") ||  file.endsWith(".a")) {
        if (!mingwPath.isNull() && !findFileInPaths(file, mingwPaths(mingwPath, "lib")).isNull())
            return true;
        paths = QString::fromLocal8Bit(getenv("LIB"));
    } else {
        paths = pathEnvVar;
    }
    return !findFileInPaths(file, paths).isNull();
}

/*!
    Default value for options marked as "auto" if the test passes.
    (Used both by the autoDetection() below, and the desc() function
    to mark (+) the default option of autodetecting options.
*/
QString Configure::defaultTo(const QString &option)
{
    // We prefer using the system version of the 3rd party libs
    if (option == "ZLIB"
        || option == "LIBJPEG"
        || option == "LIBPNG"
        || option == "LIBMNG"
        || option == "LIBTIFF")
        return "system";

    // PNG is always built-in, never a plugin
    if (option == "PNG")
        return "yes";

    // These database drivers and image formats can be built-in or plugins.
    // Prefer plugins when Qt is shared.
    if (dictionary[ "SHARED" ] == "yes") {
        if (option == "SQL_MYSQL"
            || option == "SQL_MYSQL"
            || option == "SQL_ODBC"
            || option == "SQL_OCI"
            || option == "SQL_PSQL"
            || option == "SQL_TDS"
            || option == "SQL_DB2"
            || option == "SQL_SQLITE"
            || option == "SQL_SQLITE2"
            || option == "SQL_IBASE"
            || option == "JPEG"
            || option == "MNG"
            || option == "TIFF"
            || option == "GIF")
            return "plugin";
    }

    // By default we do not want to compile OCI driver when compiling with
    // MinGW, due to lack of such support from Oracle. It prob. wont work.
    // (Customer may force the use though)
    if (dictionary["QMAKESPEC"].endsWith("-g++")
        && option == "SQL_OCI")
        return "no";

    //Run syncqt for shadow build and developer build and sources from git
    if (option == "SYNCQT") {
        if ((buildPath != sourcePath)
            || (dictionary["BUILDDEV"] == "yes")
            || QDir(sourcePath + "/.git").exists())
            return "yes";
        if (!QFile::exists(sourcePath + "/bin/syncqt")
            || !QFile::exists(sourcePath + "/bin/syncqt.bat")
            || QDir(buildPath + "/include").exists())
            return "no";
    }
    return "yes";
}

/*!
    Checks the system for the availability of a feature.
    Returns true if the feature is available, else false.
*/
bool Configure::checkAvailability(const QString &part)
{
    bool available = false;
    if (part == "STYLE_WINDOWSXP")
        available = findFile("uxtheme.h");

    else if (part == "ZLIB")
        available = findFile("zlib.h");

    else if (part == "LIBJPEG")
        available = findFile("jpeglib.h");
    else if (part == "LIBPNG")
        available = findFile("png.h");
    else if (part == "LIBMNG")
        available = findFile("libmng.h");
    else if (part == "LIBTIFF")
        available = findFile("tiffio.h");
    else if (part == "SQL_MYSQL")
        available = findFile("mysql.h") && findFile("libmySQL.lib");
    else if (part == "SQL_ODBC")
        available = findFile("sql.h") && findFile("sqlext.h") && findFile("odbc32.lib");
    else if (part == "SQL_OCI")
        available = findFile("oci.h") && findFile("oci.lib");
    else if (part == "SQL_PSQL")
        available = findFile("libpq-fe.h") && findFile("libpq.lib") && findFile("ws2_32.lib") && findFile("advapi32.lib");
    else if (part == "SQL_TDS")
        available = findFile("sybfront.h") && findFile("sybdb.h") && findFile("ntwdblib.lib");
    else if (part == "SQL_DB2")
        available = findFile("sqlcli.h") && findFile("sqlcli1.h") && findFile("db2cli.lib");
    else if (part == "SQL_SQLITE")
        if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian"))
            available = false; // In Symbian we only support system sqlite option
        else
            available = true; // Built in, we have a fork
    else if (part == "SQL_SQLITE_LIB") {
        if (dictionary[ "SQL_SQLITE_LIB" ] == "system") {
            if (dictionary.contains("XQMAKESPEC")) {
                // Symbian has multiple .lib/.dll files we need to find
                if (dictionary["XQMAKESPEC"].startsWith("symbian")) {
                    available = true; // There is sqlite_symbian plugin which exports the necessary stuff
                    dictionary[ "QT_LFLAGS_SQLITE" ] += "-lsqlite3";
                } else if (dictionary["XQMAKESPEC"].endsWith("qcc")) {
                    available = true;
                    dictionary[ "QT_LFLAGS_SQLITE" ] += "-lsqlite3 -lz";
                }
            } else {
                available = findFile("sqlite3.h") && findFile("sqlite3.lib");
                if (available)
                    dictionary[ "QT_LFLAGS_SQLITE" ] += "sqlite3.lib";
            }
        } else
            available = true;
    } else if (part == "SQL_SQLITE2")
        available = findFile("sqlite.h") && findFile("sqlite.lib");
    else if (part == "SQL_IBASE")
        available = findFile("ibase.h") && (findFile("gds32_ms.lib") || findFile("gds32.lib"));
    else if (part == "IWMMXT")
        available = (dictionary[ "ARCHITECTURE" ]  == "windowsce");
    else if (part == "OPENGL_ES_CM")
        available = (dictionary[ "ARCHITECTURE" ]  == "windowsce");
    else if (part == "OPENGL_ES_2")
        available = (dictionary[ "ARCHITECTURE" ]  == "windowsce");
    else if (part == "DIRECTSHOW")
        available = (dictionary[ "ARCHITECTURE" ]  == "windowsce");
    else if (part == "SSE2")
        available = (dictionary.value("QMAKESPEC") != "win32-msvc");
    else if (part == "3DNOW")
        available = (dictionary.value("QMAKESPEC") != "win32-msvc") && (dictionary.value("QMAKESPEC") != "win32-icc") && findFile("mm3dnow.h");
    else if (part == "MMX" || part == "SSE")
        available = (dictionary.value("QMAKESPEC") != "win32-msvc");
    else if (part == "OPENSSL")
        available = findFile("openssl\\ssl.h");
    else if (part == "DBUS")
        available = findFile("dbus\\dbus.h");
    else if (part == "CETEST") {
        QString rapiHeader = locateFile("rapi.h");
        QString rapiLib = locateFile("rapi.lib");
        available = (dictionary[ "ARCHITECTURE" ]  == "windowsce") && !rapiHeader.isEmpty() && !rapiLib.isEmpty();
        if (available) {
            dictionary[ "QT_CE_RAPI_INC" ] += QLatin1String("\"") + rapiHeader + QLatin1String("\"");
            dictionary[ "QT_CE_RAPI_LIB" ] += QLatin1String("\"") + rapiLib + QLatin1String("\"");
        }
        else if (dictionary[ "CETEST_REQUESTED" ] == "yes") {
            cout << "cetest could not be enabled: rapi.h and rapi.lib could not be found." << endl;
            cout << "Make sure the environment is set up for compiling with ActiveSync." << endl;
            dictionary[ "DONE" ] = "error";
        }
    }
    else if (part == "INCREDIBUILD_XGE")
        available = findFile("BuildConsole.exe") && findFile("xgConsole.exe");
    else if (part == "XMLPATTERNS")
        available = dictionary.value("EXCEPTIONS") == "yes";
    else if (part == "PHONON") {
        if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian")) {
            available = true;
        } else {
            available = findFile("vmr9.h") && findFile("dshow.h") && findFile("dmo.h") && findFile("dmodshow.h")
                && (findFile("strmiids.lib") || findFile("libstrmiids.a"))
                && (findFile("dmoguids.lib") || findFile("libdmoguids.a"))
                && (findFile("msdmo.lib") || findFile("libmsdmo.a"))
                && findFile("d3d9.h");

            if (!available) {
                cout << "All the required DirectShow/Direct3D files couldn't be found." << endl
                     << "Make sure you have either the platform SDK AND the DirectShow SDK or the Windows SDK installed." << endl
                     << "If you have the DirectShow SDK installed, please make sure that you have run the <path to SDK>\\SetEnv.Cmd script." << endl;
                if (!findFile("vmr9.h"))  cout << "vmr9.h not found" << endl;
                if (!findFile("dshow.h")) cout << "dshow.h not found" << endl;
                if (!findFile("strmiids.lib")) cout << "strmiids.lib not found" << endl;
                if (!findFile("dmoguids.lib")) cout << "dmoguids.lib not found" << endl;
                if (!findFile("msdmo.lib")) cout << "msdmo.lib not found" << endl;
                if (!findFile("d3d9.h")) cout << "d3d9.h not found" << endl;
            }
        }
    } else if (part == "WMSDK") {
        available = findFile("wmsdk.h");
    } else if (part == "MULTIMEDIA" || part == "SCRIPT" || part == "SCRIPTTOOLS" || part == "DECLARATIVE") {
        available = true;
    } else if (part == "WEBKIT") {
        const QString qmakeSpec = dictionary.value("QMAKESPEC");
        available = qmakeSpec == "win32-msvc2005" || qmakeSpec == "win32-msvc2008" ||
                qmakeSpec == "win32-msvc2010" || qmakeSpec == "win32-msvc2012" || qmakeSpec.startsWith("win32-g++");
        if (dictionary[ "SHARED" ] == "no") {
            cout << endl << "WARNING: Using static linking will disable the WebKit module." << endl
                 << endl;
            available = false;
        }
    } else if (part == "AUDIO_BACKEND") {
        available = true;
        if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian")) {
            QString epocRoot = Environment::symbianEpocRoot();
            const QDir epocRootDir(epocRoot);
            if (epocRootDir.exists()) {
                QStringList paths;
                paths << "epoc32/release/armv5/lib/mmfdevsound.dso"
                      << "epoc32/release/armv5/lib/mmfdevsound.lib"
                      << "epoc32/release/winscw/udeb/mmfdevsound.dll"
                      << "epoc32/release/winscw/udeb/mmfdevsound.lib"
                      << "epoc32/include/mmf/server/sounddevice.h";

                QStringList::iterator i = paths.begin();
                while (i != paths.end()) {
                    const QString &path = epocRoot + *i;
                    if (QFile::exists(path))
                        i = paths.erase(i);
                    else
                        ++i;
                }

                available = (paths.size() == 0);
                if (!available) {
                    if (epocRoot.isEmpty())
                        epocRoot = "<empty string>";
                    cout << endl
                         << "The QtMultimedia audio backend will not be built because required" << endl
                         << "support for CMMFDevSound was not found in the SDK." << endl
                         << "The SDK which was examined was located at the following path:" << endl
                         << "    " << epocRoot << endl
                         << "The following required files were missing from the SDK:" << endl;
                    QString path;
                    foreach (path, paths)
                        cout << "    " << path << endl;
                    cout << endl;
                }
            } else {
                cout << endl
                     << "The SDK root was determined to be '" << epocRoot << "'." << endl
                     << "This directory was not found, so the SDK could not be checked for" << endl
                     << "CMMFDevSound support.  The QtMultimedia audio backend will therefore" << endl
                     << "not be built." << endl << endl;
                available = false;
            }
        }
    } else if (part == "DIRECTWRITE") {
        available = findFile("dwrite.h") && findFile("d2d1.h") && findFile("dwrite.lib");
    } else if (part == "STACK_PROTECTOR_STRONG") {
        QStringList compilerAndArgs;
        compilerAndArgs += "qcc";
        compilerAndArgs += "-fstack-protector-strong";
        available = dictionary[ "XQMAKESPEC" ].contains("blackberry") && compilerSupportsFlag(compilerAndArgs);
    } else if (part == "SLOG2") {
        available = findFile("slog2.h");
    }

    return available;
}

/*
    Autodetect options marked as "auto".
*/
void Configure::autoDetection()
{
    // Style detection
    if (dictionary["STYLE_WINDOWSXP"] == "auto")
        dictionary["STYLE_WINDOWSXP"] = checkAvailability("STYLE_WINDOWSXP") ? defaultTo("STYLE_WINDOWSXP") : "no";
    if (dictionary["STYLE_WINDOWSVISTA"] == "auto") // Vista style has the same requirements as XP style
        dictionary["STYLE_WINDOWSVISTA"] = checkAvailability("STYLE_WINDOWSXP") ? defaultTo("STYLE_WINDOWSVISTA") : "no";

    // Compression detection
    if (dictionary["ZLIB"] == "auto")
        dictionary["ZLIB"] =  checkAvailability("ZLIB") ? defaultTo("ZLIB") : "qt";

    // Image format detection
    if (dictionary["GIF"] == "auto")
        dictionary["GIF"] = defaultTo("GIF");
    if (dictionary["JPEG"] == "auto")
        dictionary["JPEG"] = defaultTo("JPEG");
    if (dictionary["PNG"] == "auto")
        dictionary["PNG"] = defaultTo("PNG");
    if (dictionary["MNG"] == "auto")
        dictionary["MNG"] = defaultTo("MNG");
    if (dictionary["TIFF"] == "auto")
        dictionary["TIFF"] = dictionary["ZLIB"] == "no" ? "no" : defaultTo("TIFF");
    if (dictionary["LIBJPEG"] == "auto")
        dictionary["LIBJPEG"] = checkAvailability("LIBJPEG") ? defaultTo("LIBJPEG") : "qt";
    if (dictionary["LIBPNG"] == "auto")
        dictionary["LIBPNG"] = checkAvailability("LIBPNG") ? defaultTo("LIBPNG") : "qt";
    if (dictionary["LIBMNG"] == "auto")
        dictionary["LIBMNG"] = checkAvailability("LIBMNG") ? defaultTo("LIBMNG") : "qt";
    if (dictionary["LIBTIFF"] == "auto")
        dictionary["LIBTIFF"] = checkAvailability("LIBTIFF") ? defaultTo("LIBTIFF") : "qt";

    // SQL detection (not on by default)
    if (dictionary["SQL_MYSQL"] == "auto")
        dictionary["SQL_MYSQL"] = checkAvailability("SQL_MYSQL") ? defaultTo("SQL_MYSQL") : "no";
    if (dictionary["SQL_ODBC"] == "auto")
        dictionary["SQL_ODBC"] = checkAvailability("SQL_ODBC") ? defaultTo("SQL_ODBC") : "no";
    if (dictionary["SQL_OCI"] == "auto")
        dictionary["SQL_OCI"] = checkAvailability("SQL_OCI") ? defaultTo("SQL_OCI") : "no";
    if (dictionary["SQL_PSQL"] == "auto")
        dictionary["SQL_PSQL"] = checkAvailability("SQL_PSQL") ? defaultTo("SQL_PSQL") : "no";
    if (dictionary["SQL_TDS"] == "auto")
        dictionary["SQL_TDS"] = checkAvailability("SQL_TDS") ? defaultTo("SQL_TDS") : "no";
    if (dictionary["SQL_DB2"] == "auto")
        dictionary["SQL_DB2"] = checkAvailability("SQL_DB2") ? defaultTo("SQL_DB2") : "no";
    if (dictionary["SQL_SQLITE"] == "auto")
        dictionary["SQL_SQLITE"] = checkAvailability("SQL_SQLITE") ? defaultTo("SQL_SQLITE") : "no";
    if (dictionary["SQL_SQLITE_LIB"] == "system")
        if (!checkAvailability("SQL_SQLITE_LIB"))
            dictionary["SQL_SQLITE_LIB"] = "no";
    if (dictionary["SQL_SQLITE2"] == "auto")
        dictionary["SQL_SQLITE2"] = checkAvailability("SQL_SQLITE2") ? defaultTo("SQL_SQLITE2") : "no";
    if (dictionary["SQL_IBASE"] == "auto")
        dictionary["SQL_IBASE"] = checkAvailability("SQL_IBASE") ? defaultTo("SQL_IBASE") : "no";
    if (dictionary["MMX"] == "auto")
        dictionary["MMX"] = checkAvailability("MMX") ? "yes" : "no";
    if (dictionary["3DNOW"] == "auto")
        dictionary["3DNOW"] = checkAvailability("3DNOW") ? "yes" : "no";
    if (dictionary["SSE"] == "auto")
        dictionary["SSE"] = checkAvailability("SSE") ? "yes" : "no";
    if (dictionary["SSE2"] == "auto")
        dictionary["SSE2"] = checkAvailability("SSE2") ? "yes" : "no";
    if (dictionary["IWMMXT"] == "auto")
        dictionary["IWMMXT"] = checkAvailability("IWMMXT") ? "yes" : "no";
    if (dictionary["OPENSSL"] == "auto")
        dictionary["OPENSSL"] = checkAvailability("OPENSSL") ? "yes" : "no";
    if (dictionary["DBUS"] == "auto")
        dictionary["DBUS"] = checkAvailability("DBUS") ? "yes" : "no";
    if (dictionary["SCRIPT"] == "auto")
        dictionary["SCRIPT"] = checkAvailability("SCRIPT") ? "yes" : "no";
    if (dictionary["SCRIPTTOOLS"] == "auto")
        dictionary["SCRIPTTOOLS"] = dictionary["SCRIPT"] == "yes" ? "yes" : "no";
    if (dictionary["XMLPATTERNS"] == "auto")
        dictionary["XMLPATTERNS"] = checkAvailability("XMLPATTERNS") ? "yes" : "no";
    if (dictionary["PHONON"] == "auto")
        dictionary["PHONON"] = checkAvailability("PHONON") ? "yes" : "no";
    if (dictionary["WEBKIT"] == "auto")
        dictionary["WEBKIT"] = checkAvailability("WEBKIT") ? "yes" : "no";
    if (dictionary["DECLARATIVE"] == "auto")
        dictionary["DECLARATIVE"] = dictionary["SCRIPT"] == "yes" ? "yes" : "no";
    if (dictionary["DECLARATIVE_DEBUG"] == "auto")
        dictionary["DECLARATIVE_DEBUG"] = dictionary["DECLARATIVE"] == "yes" ? "yes" : "no";
    if (dictionary["AUDIO_BACKEND"] == "auto")
        dictionary["AUDIO_BACKEND"] = checkAvailability("AUDIO_BACKEND") ? "yes" : "no";
    if (dictionary["WMSDK"] == "auto")
        dictionary["WMSDK"] = checkAvailability("WMSDK") ? "yes" : "no";

    // Qt/WinCE remote test application
    if (dictionary["CETEST"] == "auto")
        dictionary["CETEST"] = checkAvailability("CETEST") ? "yes" : "no";

    // Detection of IncrediBuild buildconsole
    if (dictionary["INCREDIBUILD_XGE"] == "auto")
        dictionary["INCREDIBUILD_XGE"] = checkAvailability("INCREDIBUILD_XGE") ? "yes" : "no";

    // Detection of -fstack-protector-strong support
    if (dictionary["STACK_PROTECTOR_STRONG"] == "auto")
        dictionary["STACK_PROTECTOR_STRONG"] = checkAvailability("STACK_PROTECTOR_STRONG") ? "yes" : "no";

    if ((platform() == QNX || platform() == BLACKBERRY) && dictionary["SLOG2"] == "auto") {
        dictionary[ "SLOG2" ] = checkAvailability("SLOG2") ? "yes" : "no";
    }

    // Mark all unknown "auto" to the default value..
    for (QMap<QString,QString>::iterator i = dictionary.begin(); i != dictionary.end(); ++i) {
        if (i.value() == "auto")
            i.value() = defaultTo(i.key());
    }
}

bool Configure::verifyConfiguration()
{
    if (dictionary["SQL_SQLITE_LIB"] == "no" && dictionary["SQL_SQLITE"] != "no") {
        cout << "WARNING: Configure could not detect the presence of a system SQLite3 lib." << endl
             << "Configure will therefore continue with the SQLite3 lib bundled with Qt." << endl
             << "(Press any key to continue..)";
        if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
            exit(0);      // Exit cleanly for Ctrl+C

        dictionary["SQL_SQLITE_LIB"] = "qt"; // Set to Qt's bundled lib an continue
    }
    if (dictionary["QMAKESPEC"].contains("-g++")
        && dictionary["SQL_OCI"] != "no") {
        cout << "WARNING: Qt does not support compiling the Oracle database driver with" << endl
             << "MinGW, due to lack of such support from Oracle. Consider disabling the" << endl
             << "Oracle driver, as the current build will most likely fail." << endl;
        cout << "(Press any key to continue..)";
        if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
            exit(0);      // Exit cleanly for Ctrl+C
    }
    if (dictionary["QMAKESPEC"].endsWith("win32-msvc.net")) {
        cout << "WARNING: The makespec win32-msvc.net is deprecated. Consider using" << endl
             << "win32-msvc2002 or win32-msvc2003 instead." << endl;
        cout << "(Press any key to continue..)";
        if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
            exit(0);      // Exit cleanly for Ctrl+C
    }
    if (0 != dictionary["ARM_FPU_TYPE"].size()) {
            QStringList l= QStringList()
                    << "softvfp"
                    << "softvfp+vfpv2"
                    << "vfpv2";
            if (!(l.contains(dictionary["ARM_FPU_TYPE"])))
                    cout << QString("WARNING: Using unsupported fpu flag: %1").arg(dictionary["ARM_FPU_TYPE"]) << endl;
    }
    if (dictionary["DECLARATIVE"] == "yes" && dictionary["SCRIPT"] == "no") {
        cout << "WARNING: To be able to compile QtDeclarative we need to also compile the" << endl
             << "QtScript module. If you continue, we will turn on the QtScript module." << endl
             << "(Press any key to continue..)";
        if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
            exit(0);      // Exit cleanly for Ctrl+C

        dictionary["SCRIPT"] = "yes";
    }

    if (dictionary["DIRECTWRITE"] == "yes" && !checkAvailability("DIRECTWRITE")) {
        cout << "WARNING: To be able to compile the DirectWrite font engine you will" << endl
             << "need the Microsoft DirectWrite and Microsoft Direct2D development" << endl
             << "files such as headers and libraries." << endl
             << "(Press any key to continue..)";
        if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
            exit(0);      // Exit cleanly for Ctrl+C
    }

    if (dictionary["QPA"] == "yes") {
        if (dictionary["QT3SUPPORT"] == "yes") {
            dictionary["QT3SUPPORT"] = "no";

            cout << "WARNING: Qt3 compatibility is not compatible with QPA builds." << endl
                 << "Qt3 compatibility (Qt3Support) will be disabled." << endl
                 << "(Press any key to continue..)";
            if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
                exit(0);      // Exit cleanly for Ctrl+C
        }
    }
    return true;
}

/*
 Things that affect the Qt API/ABI:
   Options:
     minimal-config small-config medium-config large-config full-config

   Options:
     debug release
     stl

 Things that do not affect the Qt API/ABI:
     system-jpeg no-jpeg jpeg
     system-mng no-mng mng
     system-png no-png png
     system-zlib no-zlib zlib
     system-tiff no-tiff tiff
     no-gif gif
     dll staticlib

     nocrosscompiler
     GNUmake
     largefile
     nis
     nas
     tablet
     ipv6

     X11     : x11sm xinerama xcursor xfixes xrandr xrender fontconfig xkb
     Embedded: embedded freetype
*/
void Configure::generateBuildKey()
{
    QString spec = dictionary["QMAKESPEC"];

    QString compiler = "msvc"; // ICC is compatible
    if (spec.contains("-g++"))
        compiler = "mingw";
    else if (spec.endsWith("-borland"))
        compiler = "borland";

    // Build options which changes the Qt API/ABI
    QStringList build_options;
    if (!dictionary["QCONFIG"].isEmpty())
        build_options += dictionary["QCONFIG"] + "-config ";
    build_options.sort();

    // Sorted defines that start with QT_NO_
    QStringList build_defines = qmakeDefines.filter(QRegExp("^QT_NO_"));
    build_defines.sort();

    // Build up the QT_BUILD_KEY ifdef
    QString buildKey = "QT_BUILD_KEY \"";
    if (!dictionary["USER_BUILD_KEY"].isEmpty())
        buildKey += dictionary["USER_BUILD_KEY"] + " ";

    QString build32Key = buildKey + "Windows " + compiler + " %1 " + build_options.join(" ") + " " + build_defines.join(" ");
    QString build64Key = buildKey + "Windows x64 " + compiler + " %1 " + build_options.join(" ") + " " + build_defines.join(" ");
    QString buildSymbianKey = buildKey + "Symbian " + build_options.join(" ") + " " + build_defines.join(" ");
    build32Key = build32Key.simplified();
    build64Key = build64Key.simplified();
    buildSymbianKey = buildSymbianKey.simplified();
    build32Key.prepend("#   define ");
    build64Key.prepend("#   define ");
    buildSymbianKey.prepend("# define ");

    QString buildkey = "#if defined(__SYMBIAN32__)\n"
                       + buildSymbianKey + "\"\n"
                       "#else\n"
                       // Debug builds
                       "# if !defined(QT_NO_DEBUG)\n"
                       "#  if (defined(WIN64) || defined(_WIN64) || defined(__WIN64__))\n"
                       + build64Key.arg("debug") + "\"\n"
                       "#  else\n"
                       + build32Key.arg("debug") + "\"\n"
                       "#  endif\n"
                       "# else\n"
                       // Release builds
                       "#  if (defined(WIN64) || defined(_WIN64) || defined(__WIN64__))\n"
                       + build64Key.arg("release") + "\"\n"
                       "#  else\n"
                       + build32Key.arg("release") + "\"\n"
                       "#  endif\n"
                       "# endif\n"
                       "#endif\n";

    dictionary["BUILD_KEY"] = buildkey;
}

void Configure::generateOutputVars()
{
    // Generate variables for output
    // Build key ----------------------------------------------------
    if (dictionary.contains("BUILD_KEY")) {
        qmakeVars += dictionary.value("BUILD_KEY");
    }

    QString build = dictionary[ "BUILD" ];
    bool buildAll = (dictionary[ "BUILDALL" ] == "yes");
    if (build == "debug") {
        if (buildAll)
            qtConfig += "release";
        qtConfig += "debug";
    } else if (build == "release") {
        if (buildAll)
            qtConfig += "debug";
        qtConfig += "release";
    }

    // Compression --------------------------------------------------
    if (dictionary[ "ZLIB" ] == "qt")
        qtConfig += "zlib";
    else if (dictionary[ "ZLIB" ] == "system")
        qtConfig += "system-zlib";

    // Image formates -----------------------------------------------
    if (dictionary[ "GIF" ] == "no")
        qtConfig += "no-gif";
    else if (dictionary[ "GIF" ] == "yes")
        qtConfig += "gif";

    if (dictionary[ "TIFF" ] == "no")
        qtConfig += "no-tiff";
    else if (dictionary[ "TIFF" ] == "yes")
        qtConfig += "tiff";
    if (dictionary[ "LIBTIFF" ] == "system")
        qtConfig += "system-tiff";

    if (dictionary[ "JPEG" ] == "no")
        qtConfig += "no-jpeg";
    else if (dictionary[ "JPEG" ] == "yes")
        qtConfig += "jpeg";
    if (dictionary[ "LIBJPEG" ] == "system")
        qtConfig += "system-jpeg";

    if (dictionary[ "PNG" ] == "no")
        qtConfig += "no-png";
    else if (dictionary[ "PNG" ] == "yes")
        qtConfig += "png";
    if (dictionary[ "LIBPNG" ] == "system")
        qtConfig += "system-png";

    if (dictionary[ "MNG" ] == "no")
        qtConfig += "no-mng";
    else if (dictionary[ "MNG" ] == "yes")
        qtConfig += "mng";
    if (dictionary[ "LIBMNG" ] == "system")
        qtConfig += "system-mng";

    // Text rendering --------------------------------------------------
    if (dictionary[ "FREETYPE" ] == "yes")
        qtConfig += "freetype";
    else if (dictionary[ "FREETYPE" ] == "system")
        qtConfig += "system-freetype";

    // Styles -------------------------------------------------------
    if (dictionary[ "STYLE_WINDOWS" ] == "yes")
        qmakeStyles += "windows";

    if (dictionary[ "STYLE_PLASTIQUE" ] == "yes")
        qmakeStyles += "plastique";

    if (dictionary[ "STYLE_CLEANLOOKS" ] == "yes")
        qmakeStyles += "cleanlooks";

    if (dictionary[ "STYLE_WINDOWSXP" ] == "yes")
        qmakeStyles += "windowsxp";

    if (dictionary[ "STYLE_WINDOWSVISTA" ] == "yes")
        qmakeStyles += "windowsvista";

    if (dictionary[ "STYLE_MOTIF" ] == "yes")
        qmakeStyles += "motif";

    if (dictionary[ "STYLE_SGI" ] == "yes")
        qmakeStyles += "sgi";

    if (dictionary[ "STYLE_WINDOWSCE" ] == "yes")
    qmakeStyles += "windowsce";

    if (dictionary[ "STYLE_WINDOWSMOBILE" ] == "yes")
    qmakeStyles += "windowsmobile";

    if (dictionary[ "STYLE_CDE" ] == "yes")
        qmakeStyles += "cde";

    if (dictionary[ "STYLE_S60" ] == "yes")
        qmakeStyles += "s60";

    // Databases ----------------------------------------------------
    if (dictionary[ "SQL_MYSQL" ] == "yes")
        qmakeSql += "mysql";
    else if (dictionary[ "SQL_MYSQL" ] == "plugin")
        qmakeSqlPlugins += "mysql";

    if (dictionary[ "SQL_ODBC" ] == "yes")
        qmakeSql += "odbc";
    else if (dictionary[ "SQL_ODBC" ] == "plugin")
        qmakeSqlPlugins += "odbc";

    if (dictionary[ "SQL_OCI" ] == "yes")
        qmakeSql += "oci";
    else if (dictionary[ "SQL_OCI" ] == "plugin")
        qmakeSqlPlugins += "oci";

    if (dictionary[ "SQL_PSQL" ] == "yes")
        qmakeSql += "psql";
    else if (dictionary[ "SQL_PSQL" ] == "plugin")
        qmakeSqlPlugins += "psql";

    if (dictionary[ "SQL_TDS" ] == "yes")
        qmakeSql += "tds";
    else if (dictionary[ "SQL_TDS" ] == "plugin")
        qmakeSqlPlugins += "tds";

    if (dictionary[ "SQL_DB2" ] == "yes")
        qmakeSql += "db2";
    else if (dictionary[ "SQL_DB2" ] == "plugin")
        qmakeSqlPlugins += "db2";

    if (dictionary[ "SQL_SQLITE" ] == "yes")
        qmakeSql += "sqlite";
    else if (dictionary[ "SQL_SQLITE" ] == "plugin")
        qmakeSqlPlugins += "sqlite";

    if (dictionary[ "SQL_SQLITE_LIB" ] == "system")
        qmakeConfig += "system-sqlite";

    if (dictionary[ "SQL_SQLITE2" ] == "yes")
        qmakeSql += "sqlite2";
    else if (dictionary[ "SQL_SQLITE2" ] == "plugin")
        qmakeSqlPlugins += "sqlite2";

    if (dictionary[ "SQL_IBASE" ] == "yes")
        qmakeSql += "ibase";
    else if (dictionary[ "SQL_IBASE" ] == "plugin")
        qmakeSqlPlugins += "ibase";

    // Other options ------------------------------------------------
    if (dictionary[ "BUILDALL" ] == "yes") {
        qmakeConfig += "build_all";
    }
    qmakeConfig += dictionary[ "BUILD" ];
    dictionary[ "QMAKE_OUTDIR" ] = dictionary[ "BUILD" ];

    if (dictionary["MSVC_MP"] == "yes")
        qmakeConfig += "msvc_mp";

    if (dictionary[ "SHARED" ] == "yes") {
        QString version = dictionary[ "VERSION" ];
        if (!version.isEmpty()) {
            qmakeVars += "QMAKE_QT_VERSION_OVERRIDE = " + version.left(version.indexOf("."));
            version.remove(QLatin1Char('.'));
        }
        dictionary[ "QMAKE_OUTDIR" ] += "_shared";
    } else {
        dictionary[ "QMAKE_OUTDIR" ] += "_static";
    }

    if (dictionary[ "ACCESSIBILITY" ] == "yes")
        qtConfig += "accessibility";

    if (!qmakeLibs.isEmpty())
        qmakeVars += "LIBS           += " + escapeSeparators(qmakeLibs.join(" "));

    if (!dictionary["QT_LFLAGS_SQLITE"].isEmpty())
        qmakeVars += "QT_LFLAGS_SQLITE += " + escapeSeparators(dictionary["QT_LFLAGS_SQLITE"]);

    if (dictionary[ "QT3SUPPORT" ] == "yes")
        qtConfig += "qt3support";

    if (dictionary[ "OPENGL" ] == "yes")
        qtConfig += "opengl";

    if (dictionary["OPENGL_ES_CM"] == "yes") {
        qtConfig += "opengles1";
        if (dictionary["QPA"] == "no")
            qtConfig += "egl";
    }

    if (dictionary["OPENGL_ES_2"] == "yes") {
        qtConfig += "opengles2";
        if (dictionary["QPA"] == "no")
            qtConfig += "egl";
    }

    if (dictionary["OPENVG"] == "yes") {
        qtConfig += "openvg";
        if (dictionary["QPA"] == "no")
            qtConfig += "egl";
    }

    if (dictionary["S60"] == "yes") {
        qtConfig += "s60";
    }

     if (dictionary["DIRECTSHOW"] == "yes")
        qtConfig += "directshow";

    if (dictionary[ "OPENSSL" ] == "yes")
        qtConfig += "openssl";
    else if (dictionary[ "OPENSSL" ] == "linked")
        qtConfig += "openssl-linked";

    if (dictionary[ "DBUS" ] == "yes")
        qtConfig += "dbus";
    else if (dictionary[ "DBUS" ] == "linked")
        qtConfig += "dbus dbus-linked";

    if (dictionary["IPV6"] == "yes")
        qtConfig += "ipv6";
    else if (dictionary["IPV6"] == "no")
        qtConfig += "no-ipv6";

    if (dictionary[ "CETEST" ] == "yes")
        qtConfig += "cetest";

    if (dictionary[ "SCRIPT" ] == "yes")
        qtConfig += "script";

    if (dictionary[ "SCRIPTTOOLS" ] == "yes") {
        if (dictionary[ "SCRIPT" ] == "no") {
            cout << "QtScriptTools was requested, but it can't be built due to QtScript being "
                    "disabled." << endl;
            dictionary[ "DONE" ] = "error";
        }
        qtConfig += "scripttools";
    }

    if (dictionary[ "XMLPATTERNS" ] == "yes")
        qtConfig += "xmlpatterns";

    if (dictionary["PHONON"] == "yes") {
        qtConfig += "phonon";
        if (dictionary["PHONON_BACKEND"] == "yes")
            qtConfig += "phonon-backend";
    }

    if (dictionary["MULTIMEDIA"] == "yes") {
        qtConfig += "multimedia";
        if (dictionary["AUDIO_BACKEND"] == "yes")
            qtConfig += "audio-backend";
    }

    QString dst = buildPath + "/mkspecs/modules/qt_webkit_version.pri";
    QFile::remove(dst);
    if (dictionary["WEBKIT"] != "no") {
        // This include takes care of adding "webkit" to QT_CONFIG.
        QString src = sourcePath + "/src/3rdparty/webkit/Source/WebKit/qt/qt_webkit_version.pri";
        QFile::copy(src, dst);
        if (dictionary["WEBKIT"] == "debug")
            qtConfig += "webkit-debug";
    }

    if (dictionary["DECLARATIVE"] == "yes") {
        if (dictionary[ "SCRIPT" ] == "no") {
            cout << "QtDeclarative was requested, but it can't be built due to QtScript being "
                    "disabled." << endl;
            dictionary[ "DONE" ] = "error";
        }
        qtConfig += "declarative";
    }

    if (dictionary["DIRECTWRITE"] == "yes")
        qtConfig += "directwrite";

    if (dictionary[ "NATIVE_GESTURES" ] == "yes")
        qtConfig += "native-gestures";

    if (dictionary["QPA"] == "yes")
        qtConfig += "qpa";

    if (dictionary["CROSS_COMPILE"] == "yes")
        qtConfig << " cross_compile";

    if (dictionary["NIS"] == "yes")
        qtConfig += "nis";

    if (dictionary["CUPS"] == "yes")
        qtConfig += "cups";

    if (dictionary["QT_ICONV"] == "yes")
        qtConfig += "iconv";
    else if (dictionary["QT_ICONV"] == "sun")
        qtConfig += "sun-libiconv";
    else if (dictionary["QT_ICONV"] == "gnu")
        qtConfig += "gnu-libiconv";

    if (dictionary["QT_INOTIFY"] == "yes")
        qtConfig += "inotify";

    if (dictionary["NEON"] == "yes")
        qtConfig += "neon";

    if (dictionary["LARGE_FILE"] == "yes")
        qtConfig += "largefile";

    if (dictionary["FONT_CONFIG"] == "yes") {
        qtConfig += "fontconfig";
        qmakeVars += "QMAKE_CFLAGS_FONTCONFIG =";
        qmakeVars += "QMAKE_LIBS_FONTCONFIG   = -lfreetype -lfontconfig";
    }

    // We currently have no switch for QtSvg, so add it unconditionally.
    qtConfig += "svg";
    if (dictionary["STACK_PROTECTOR_STRONG"] == "yes")
        qtConfig += "stack-protector-strong";

    if (dictionary["SYSTEM_PROXIES"] == "yes")
        qtConfig += "system-proxies";

    // We currently have no switch for QtConcurrent, so add it unconditionally.
    qtConfig += "concurrent";

    // Add config levels --------------------------------------------
    QStringList possible_configs = QStringList()
        << "minimal"
        << "small"
        << "medium"
        << "large"
        << "full";

    QString set_config = dictionary["QCONFIG"];
    if (possible_configs.contains(set_config)) {
        foreach (const QString &cfg, possible_configs) {
            qtConfig += (cfg + "-config");
            if (cfg == set_config)
                break;
        }
    }

    if (dictionary.contains("XQMAKESPEC") && (dictionary["QMAKESPEC"] != dictionary["XQMAKESPEC"])) {
            qmakeConfig += "cross_compile";
            dictionary["CROSS_COMPILE"] = "yes";
    }

    // Directories and settings for .qmake.cache --------------------

    // if QT_INSTALL_* have not been specified on commandline, define them now from QT_INSTALL_PREFIX
    // if prefix is empty (WINCE), make all of them empty, if they aren't set
    bool qipempty = false;
    if (dictionary[ "QT_INSTALL_PREFIX" ].isEmpty())
        qipempty = true;

    if (!dictionary[ "QT_INSTALL_DOCS" ].size())
        dictionary[ "QT_INSTALL_DOCS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/doc");
    if (!dictionary[ "QT_INSTALL_HEADERS" ].size())
        dictionary[ "QT_INSTALL_HEADERS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/include");
    if (!dictionary[ "QT_INSTALL_LIBS" ].size())
        dictionary[ "QT_INSTALL_LIBS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/lib");
    if (!dictionary[ "QT_INSTALL_BINS" ].size())
        dictionary[ "QT_INSTALL_BINS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/bin");
    if (!dictionary[ "QT_INSTALL_PLUGINS" ].size())
        dictionary[ "QT_INSTALL_PLUGINS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/plugins");
    if (!dictionary[ "QT_INSTALL_IMPORTS" ].size())
        dictionary[ "QT_INSTALL_IMPORTS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/imports");
    if (!dictionary[ "QT_INSTALL_DATA" ].size())
        dictionary[ "QT_INSTALL_DATA" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ]);
    if (!dictionary[ "QT_INSTALL_TRANSLATIONS" ].size())
        dictionary[ "QT_INSTALL_TRANSLATIONS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/translations");
    if (!dictionary[ "QT_INSTALL_EXAMPLES" ].size())
        dictionary[ "QT_INSTALL_EXAMPLES" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/examples");
    if (!dictionary[ "QT_INSTALL_DEMOS" ].size())
        dictionary[ "QT_INSTALL_DEMOS" ] = qipempty ? "" : fixSeparators(dictionary[ "QT_INSTALL_PREFIX" ] + "/demos");

    if (dictionary.contains("XQMAKESPEC") && dictionary[ "XQMAKESPEC" ].startsWith("linux"))
        dictionary[ "QMAKE_RPATHDIR" ] = dictionary[ "QT_INSTALL_LIBS" ];

    qmakeVars += QString("OBJECTS_DIR     = ") + fixSeparators("tmp/obj/" + dictionary[ "QMAKE_OUTDIR" ], true);
    qmakeVars += QString("MOC_DIR         = ") + fixSeparators("tmp/moc/" + dictionary[ "QMAKE_OUTDIR" ], true);
    qmakeVars += QString("RCC_DIR         = ") + fixSeparators("tmp/rcc/" + dictionary["QMAKE_OUTDIR"], true);

    if (!qmakeDefines.isEmpty())
        qmakeVars += QString("DEFINES        += ") + qmakeDefines.join(" ");
    if (!qmakeIncludes.isEmpty())
        qmakeVars += QString("INCLUDEPATH    += ") + escapeSeparators(qmakeIncludes.join(" "));
    if (!opensslLibs.isEmpty())
        qmakeVars += opensslLibs;
    if (dictionary[ "OPENSSL" ] == "linked") {
        if (!opensslLibsDebug.isEmpty() || !opensslLibsRelease.isEmpty()) {
            if (opensslLibsDebug.isEmpty() || opensslLibsRelease.isEmpty()) {
                cout << "Error: either both or none of OPENSSL_LIBS_DEBUG/_RELEASE must be defined." << endl;
                exit(1);
            }
            qmakeVars += opensslLibsDebug;
            qmakeVars += opensslLibsRelease;
        } else if (opensslLibs.isEmpty()) {
            if (dictionary.contains("XQMAKESPEC") && dictionary[ "XQMAKESPEC" ].startsWith("symbian")) {
                qmakeVars += QString("OPENSSL_LIBS    = -llibssl -llibcrypto");
            } else {
                qmakeVars += QString("OPENSSL_LIBS    = -lssleay32 -llibeay32");
            }
        }
    }
    if (!psqlLibs.isEmpty())
        qmakeVars += QString("QT_LFLAGS_PSQL=") + psqlLibs.section("=", 1);

    {
        QStringList lflagsTDS;
        if (!sybase.isEmpty())
            lflagsTDS += QString("-L") + fixSeparators(sybase.section("=", 1) + "/lib");
        if (!sybaseLibs.isEmpty())
            lflagsTDS += sybaseLibs.section("=", 1);
        if (!lflagsTDS.isEmpty())
            qmakeVars += QString("QT_LFLAGS_TDS=") + lflagsTDS.join(" ");
    }

    if (!qmakeSql.isEmpty())
        qmakeVars += QString("sql-drivers    += ") + qmakeSql.join(" ");
    if (!qmakeSqlPlugins.isEmpty())
        qmakeVars += QString("sql-plugins    += ") + qmakeSqlPlugins.join(" ");
    if (!qmakeStyles.isEmpty())
        qmakeVars += QString("styles         += ") + qmakeStyles.join(" ");
    if (!qmakeStylePlugins.isEmpty())
        qmakeVars += QString("style-plugins  += ") + qmakeStylePlugins.join(" ");

    if (dictionary["QMAKESPEC"].contains("-g++")) {
        QString includepath = qgetenv("INCLUDE");
        bool hasSh = Environment::detectExecutable("sh.exe");
        QChar separator = (!includepath.contains(":\\") && hasSh ? QChar(':') : QChar(';'));
        qmakeVars += QString("TMPPATH            = $$quote($$(INCLUDE))");
        qmakeVars += QString("QMAKE_INCDIR_POST += $$split(TMPPATH,\"%1\")").arg(separator);
        qmakeVars += QString("TMPPATH            = $$quote($$(LIB))");
        qmakeVars += QString("QMAKE_LIBDIR_POST += $$split(TMPPATH,\"%1\")").arg(separator);
    }

    if (!dictionary[ "QMAKESPEC" ].length()) {
        cout << "Configure could not detect your compiler. QMAKESPEC must either" << endl
             << "be defined as an environment variable, or specified as an" << endl
             << "argument with -platform" << endl;
        dictionary[ "HELP" ] = "yes";

        QStringList winPlatforms;
        QDir mkspecsDir(sourcePath + "/mkspecs");
        const QFileInfoList &specsList = mkspecsDir.entryInfoList();
        for (int i = 0; i < specsList.size(); ++i) {
            const QFileInfo &fi = specsList.at(i);
            if (fi.fileName().left(5) == "win32") {
                winPlatforms += fi.fileName();
            }
        }
        cout << "Available platforms are: " << qPrintable(winPlatforms.join(", ")) << endl;
        dictionary[ "DONE" ] = "error";
    }
}

#if !defined(EVAL)
void Configure::generateCachefile()
{
    // Generate .qmake.cache
    QFile cacheFile(buildPath + "/.qmake.cache");
    if (cacheFile.open(QFile::WriteOnly | QFile::Text)) { // Truncates any existing file.
        QTextStream cacheStream(&cacheFile);
        for (QStringList::Iterator var = qmakeVars.begin(); var != qmakeVars.end(); ++var) {
            cacheStream << (*var) << endl;
        }
        cacheStream << "CONFIG         += " << qmakeConfig.join(" ") << " incremental create_prl link_prl depend_includepath QTDIR_build" << endl;

        QStringList buildParts;
        buildParts << "libs" << "tools" << "examples" << "demos" << "docs" << "translations";
        foreach (const QString &item, disabledBuildParts) {
            buildParts.removeAll(item);
        }
        cacheStream << "QT_BUILD_PARTS  = " << buildParts.join(" ") << endl;

        QString targetSpec = dictionary.contains("XQMAKESPEC") ? dictionary[ "XQMAKESPEC" ] : dictionary[ "QMAKESPEC" ];
        QString mkspec_path = fixSeparators(sourcePath + "/mkspecs/" + targetSpec);
        if (QFile::exists(mkspec_path))
            cacheStream << "QMAKESPEC       = " << escapeSeparators(mkspec_path) << endl;
        else
            cacheStream << "QMAKESPEC       = " << fixSeparators(targetSpec, true) << endl;
        cacheStream << "ARCH            = " << dictionary[ "ARCHITECTURE" ] << endl;
        cacheStream << "QT_BUILD_TREE   = " << fixSeparators(dictionary[ "QT_BUILD_TREE" ], true) << endl;
        cacheStream << "QT_SOURCE_TREE  = " << fixSeparators(dictionary[ "QT_SOURCE_TREE" ], true) << endl;

        if (dictionary["QT_EDITION"] != "QT_EDITION_OPENSOURCE")
            cacheStream << "DEFINES        *= QT_EDITION=QT_EDITION_DESKTOP" << endl;

        //so that we can build without an install first (which would be impossible)
        cacheStream << "QMAKE_MOC       = $$QT_BUILD_TREE" << fixSeparators("/bin/moc.exe", true) << endl;
        cacheStream << "QMAKE_UIC       = $$QT_BUILD_TREE" << fixSeparators("/bin/uic.exe", true) << endl;
        cacheStream << "QMAKE_UIC3      = $$QT_BUILD_TREE" << fixSeparators("/bin/uic3.exe", true) << endl;
        cacheStream << "QMAKE_RCC       = $$QT_BUILD_TREE" << fixSeparators("/bin/rcc.exe", true) << endl;
        cacheStream << "QMAKE_DUMPCPP   = $$QT_BUILD_TREE" << fixSeparators("/bin/dumpcpp.exe", true) << endl;
        cacheStream << "QMAKE_INCDIR_QT = $$QT_BUILD_TREE" << fixSeparators("/include", true) << endl;
        cacheStream << "QMAKE_LIBDIR_QT = $$QT_BUILD_TREE" << fixSeparators("/lib", true) << endl;
        if (dictionary["CETEST"] == "yes") {
            cacheStream << "QT_CE_RAPI_INC  = " << fixSeparators(dictionary[ "QT_CE_RAPI_INC" ], true) << endl;
            cacheStream << "QT_CE_RAPI_LIB  = " << fixSeparators(dictionary[ "QT_CE_RAPI_LIB" ], true) << endl;
        }

        // embedded
        if (!dictionary["KBD_DRIVERS"].isEmpty())
            cacheStream << "kbd-drivers += "<< dictionary["KBD_DRIVERS"]<<endl;
        if (!dictionary["GFX_DRIVERS"].isEmpty())
            cacheStream << "gfx-drivers += "<< dictionary["GFX_DRIVERS"]<<endl;
        if (!dictionary["MOUSE_DRIVERS"].isEmpty())
            cacheStream << "mouse-drivers += "<< dictionary["MOUSE_DRIVERS"]<<endl;
        if (!dictionary["DECORATIONS"].isEmpty())
            cacheStream << "decorations += "<<dictionary["DECORATIONS"]<<endl;

        if (!dictionary["QMAKE_RPATHDIR"].isEmpty())
            cacheStream << "QMAKE_RPATHDIR += "<<dictionary["QMAKE_RPATHDIR"];

        cacheStream.flush();
        cacheFile.close();
    }
    QFile configFile(dictionary[ "QT_BUILD_TREE" ] + "/mkspecs/qconfig.pri");
    if (configFile.open(QFile::WriteOnly | QFile::Text)) { // Truncates any existing file.
        QTextStream configStream(&configFile);
        configStream << "CONFIG+= ";
        configStream << dictionary[ "BUILD" ];
        if (dictionary[ "SHARED" ] == "yes") {
            configStream << " shared";
            qtConfig << "shared";
        } else {
            configStream << " static";
            qtConfig << "static";
        }

        if (dictionary[ "LTCG" ] == "yes")
            configStream << " ltcg";
        if (dictionary[ "STL" ] == "yes")
            configStream << " stl";
        if (dictionary[ "EXCEPTIONS" ] == "yes")
            configStream << " exceptions";
        if (dictionary[ "EXCEPTIONS" ] == "no")
            configStream << " exceptions_off";
        if (dictionary[ "RTTI" ] == "yes")
            configStream << " rtti";
        if (dictionary[ "MMX" ] == "yes")
            configStream << " mmx";
        if (dictionary[ "3DNOW" ] == "yes")
            configStream << " 3dnow";
        if (dictionary[ "SSE" ] == "yes")
            configStream << " sse";
        if (dictionary[ "SSE2" ] == "yes")
            configStream << " sse2";
        if (dictionary[ "IWMMXT" ] == "yes")
            configStream << " iwmmxt";
        if (dictionary["INCREDIBUILD_XGE"] == "yes")
            configStream << " incredibuild_xge";
        if (dictionary["PLUGIN_MANIFESTS"] == "no")
            configStream << " no_plugin_manifest";
        if (dictionary["QPA"] == "yes")
            configStream << " qpa";
        if (dictionary["NIS"] == "yes")
            configStream << " nis";
        if (dictionary["QT_CUPS"] == "yes")
            configStream << " cups";

        if (dictionary["QT_ICONV"] == "yes")
            configStream << " iconv";
        else if (dictionary["QT_ICONV"] == "sun")
            configStream << " sun-libiconv";
        else if (dictionary["QT_ICONV"] == "gnu")
            configStream << " gnu-libiconv";

        if (dictionary["NEON"] == "yes")
            configStream << " neon";

        if (dictionary["LARGE_FILE"] == "yes")
            configStream << " largefile";

        if (dictionary["FONT_CONFIG"] == "yes")
            configStream << " fontconfig";

        if (dictionary[ "SLOG2" ] == "yes")
            configStream << " slog2";

        if (dictionary.contains("SYMBIAN_DEFFILES")) {
            if (dictionary["SYMBIAN_DEFFILES"] == "yes") {
                configStream << " def_files";
            } else if (dictionary["SYMBIAN_DEFFILES"] == "no") {
                configStream << " def_files_disabled";
            }
        }

        if (dictionary["DIRECTWRITE"] == "yes")
            configStream << "directwrite";

        configStream << endl;
        configStream << "QT_ARCH = " << dictionary[ "ARCHITECTURE" ] << endl;
        if (dictionary["QT_EDITION"].contains("OPENSOURCE"))
            configStream << "QT_EDITION = " << QLatin1String("OpenSource") << endl;
        else
            configStream << "QT_EDITION = " << dictionary["EDITION"] << endl;
        configStream << "QT_CONFIG += " << qtConfig.join(" ") << endl;

        configStream << "#versioning " << endl
                     << "QT_VERSION = " << dictionary["VERSION"] << endl
                     << "QT_MAJOR_VERSION = " << dictionary["VERSION_MAJOR"] << endl
                     << "QT_MINOR_VERSION = " << dictionary["VERSION_MINOR"] << endl
                     << "QT_PATCH_VERSION = " << dictionary["VERSION_PATCH"] << endl;

        configStream << "#Qt for Windows CE c-runtime deployment" << endl
                     << "QT_CE_C_RUNTIME = " << fixSeparators(dictionary[ "CE_CRT" ], true) << endl;

        if (dictionary["CE_SIGNATURE"] != QLatin1String("no"))
            configStream << "DEFAULT_SIGNATURE=" << dictionary["CE_SIGNATURE"] << endl;

        if (!dictionary["QMAKE_RPATHDIR"].isEmpty())
            configStream << "QMAKE_RPATHDIR += " << dictionary["QMAKE_RPATHDIR"] << endl;

        if (!dictionary["QT_LIBINFIX"].isEmpty())
            configStream << "QT_LIBINFIX = " << dictionary["QT_LIBINFIX"] << endl;

        configStream << "#Qt for Symbian FPU settings" << endl;
        if (!dictionary["ARM_FPU_TYPE"].isEmpty()) {
            configStream<<"MMP_RULES += \"ARMFPU "<< dictionary["ARM_FPU_TYPE"]<< "\"";
        }
        if (!dictionary["QT_NAMESPACE"].isEmpty()) {
            configStream << "#namespaces" << endl << "QT_NAMESPACE = " << dictionary["QT_NAMESPACE"] << endl;
        }

        configStream.flush();
        configFile.close();
    }
}
#endif

QString Configure::addDefine(QString def)
{
    QString result, defNeg, defD = def;

    defD.replace(QRegExp("=.*"), "");
    def.replace(QRegExp("="), " ");

    if (def.startsWith("QT_NO_")) {
        defNeg = defD;
        defNeg.replace("QT_NO_", "QT_");
    } else if (def.startsWith("QT_")) {
        defNeg = defD;
        defNeg.replace("QT_", "QT_NO_");
    }

    if (defNeg.isEmpty()) {
        result = "#ifndef $DEFD\n"
                 "# define $DEF\n"
                 "#endif\n\n";
    } else {
        result = "#if defined($DEFD) && defined($DEFNEG)\n"
                 "# undef $DEFD\n"
                 "#elif !defined($DEFD)\n"
                 "# define $DEF\n"
                 "#endif\n\n";
    }
    result.replace("$DEFNEG", defNeg);
    result.replace("$DEFD", defD);
    result.replace("$DEF", def);
    return result;
}

#if !defined(EVAL)
void Configure::generateConfigfiles()
{
    QDir(buildPath).mkpath("src/corelib/global");
    QString outName(buildPath + "/src/corelib/global/qconfig.h");
    QTemporaryFile tmpFile;
    QTextStream tmpStream;

    if (tmpFile.open()) {
        tmpStream.setDevice(&tmpFile);

        if (dictionary[ "QCONFIG" ] == "full") {
            tmpStream << "/* Everything */" << endl;
        } else {
            QString configName("qconfig-" + dictionary[ "QCONFIG" ] + ".h");
            tmpStream << "/* Copied from " << configName << "*/" << endl;
            tmpStream << "#ifndef QT_BOOTSTRAPPED" << endl;
            QFile inFile(sourcePath + "/src/corelib/global/" + configName);
            if (inFile.open(QFile::ReadOnly)) {
                QByteArray buffer = inFile.readAll();
                tmpFile.write(buffer.constData(), buffer.size());
                inFile.close();
            }
            tmpStream << "#endif // QT_BOOTSTRAPPED" << endl;
        }
        tmpStream << endl;

        if (dictionary[ "SHARED" ] == "yes") {
            tmpStream << "#ifndef QT_DLL" << endl;
            tmpStream << "#define QT_DLL" << endl;
            tmpStream << "#endif" << endl;
        }
        tmpStream << endl;
        tmpStream << "/* License information */" << endl;
        tmpStream << "#define QT_PRODUCT_LICENSEE \"" << licenseInfo[ "LICENSEE" ] << "\"" << endl;
        tmpStream << "#define QT_PRODUCT_LICENSE \"" << dictionary[ "EDITION" ] << "\"" << endl;
        tmpStream << endl;
        tmpStream << "// Qt Edition" << endl;
        tmpStream << "#ifndef QT_EDITION" << endl;
        tmpStream << "#  define QT_EDITION " << dictionary["QT_EDITION"] << endl;
        tmpStream << "#endif" << endl;
        tmpStream << endl;
        tmpStream << dictionary["BUILD_KEY"];
        tmpStream << endl;
        if (dictionary["BUILDDEV"] == "yes") {
            dictionary["QMAKE_INTERNAL"] = "yes";
            tmpStream << "/* Used for example to export symbols for the certain autotests*/" << endl;
            tmpStream << "#define QT_BUILD_INTERNAL" << endl;
            tmpStream << endl;
        }
        tmpStream << "/* Machine byte-order */" << endl;
        tmpStream << "#define Q_BIG_ENDIAN 4321" << endl;
        tmpStream << "#define Q_LITTLE_ENDIAN 1234" << endl;

        if (dictionary["LITTLE_ENDIAN"] == "yes")
            tmpStream << "#define Q_BYTE_ORDER Q_LITTLE_ENDIAN" << endl;
        else
            tmpStream << "#define Q_BYTE_ORDER Q_BIG_ENDIAN" << endl;

        tmpStream << endl << "// Compile time features" << endl;
        tmpStream << "#define QT_ARCH_" << dictionary["ARCHITECTURE"].toUpper() << endl;
        if (dictionary["GRAPHICS_SYSTEM"] == "runtime" && dictionary["RUNTIME_SYSTEM"] != "runtime")
            tmpStream << "#define QT_DEFAULT_RUNTIME_SYSTEM \"" << dictionary["RUNTIME_SYSTEM"] << "\"" << endl;

        QStringList qconfigList;
        if (dictionary["STL"] == "no")                qconfigList += "QT_NO_STL";
        if (dictionary["STYLE_WINDOWS"] != "yes")     qconfigList += "QT_NO_STYLE_WINDOWS";
        if (dictionary["STYLE_PLASTIQUE"] != "yes")   qconfigList += "QT_NO_STYLE_PLASTIQUE";
        if (dictionary["STYLE_CLEANLOOKS"] != "yes")   qconfigList += "QT_NO_STYLE_CLEANLOOKS";
        if (dictionary["STYLE_WINDOWSXP"] != "yes" && dictionary["STYLE_WINDOWSVISTA"] != "yes")
            qconfigList += "QT_NO_STYLE_WINDOWSXP";
        if (dictionary["STYLE_WINDOWSVISTA"] != "yes")   qconfigList += "QT_NO_STYLE_WINDOWSVISTA";
        if (dictionary["STYLE_MOTIF"] != "yes")       qconfigList += "QT_NO_STYLE_MOTIF";
        if (dictionary["STYLE_CDE"] != "yes")         qconfigList += "QT_NO_STYLE_CDE";
        if (dictionary["STYLE_S60"] != "yes")         qconfigList += "QT_NO_STYLE_S60";
        if (dictionary["STYLE_WINDOWSCE"] != "yes")   qconfigList += "QT_NO_STYLE_WINDOWSCE";
        if (dictionary["STYLE_WINDOWSMOBILE"] != "yes")   qconfigList += "QT_NO_STYLE_WINDOWSMOBILE";
        if (dictionary["STYLE_GTK"] != "yes")         qconfigList += "QT_NO_STYLE_GTK";

        if (dictionary["GIF"] == "yes")              qconfigList += "QT_BUILTIN_GIF_READER=1";
        if (dictionary["PNG"] != "yes")              qconfigList += "QT_NO_IMAGEFORMAT_PNG";
        if (dictionary["MNG"] != "yes")              qconfigList += "QT_NO_IMAGEFORMAT_MNG";
        if (dictionary["JPEG"] != "yes")             qconfigList += "QT_NO_IMAGEFORMAT_JPEG";
        if (dictionary["TIFF"] != "yes")             qconfigList += "QT_NO_IMAGEFORMAT_TIFF";
        if (dictionary["ZLIB"] == "no") {
            qconfigList += "QT_NO_ZLIB";
            qconfigList += "QT_NO_COMPRESS";
        }

        if (dictionary["ACCESSIBILITY"] == "no")     qconfigList += "QT_NO_ACCESSIBILITY";
        if (dictionary["EXCEPTIONS"] == "no")        qconfigList += "QT_NO_EXCEPTIONS";
        if (dictionary["OPENGL"] == "no")            qconfigList += "QT_NO_OPENGL";
        if (dictionary["OPENVG"] == "no")            qconfigList += "QT_NO_OPENVG";
        if (dictionary["OPENSSL"] == "no")           qconfigList += "QT_NO_OPENSSL";
        if (dictionary["OPENSSL"] == "linked")       qconfigList += "QT_LINKED_OPENSSL";
        if (dictionary["DBUS"] == "no")              qconfigList += "QT_NO_DBUS";
        if (dictionary["IPV6"] == "no")              qconfigList += "QT_NO_IPV6";
        if (dictionary["WEBKIT"] == "no")            qconfigList += "QT_NO_WEBKIT";
        if (dictionary["DECLARATIVE"] == "no")       qconfigList += "QT_NO_DECLARATIVE";
        if (dictionary["DECLARATIVE_DEBUG"] == "no") qconfigList += "QDECLARATIVE_NO_DEBUG_PROTOCOL";
        if (dictionary["PHONON"] == "no")            qconfigList += "QT_NO_PHONON";
        if (dictionary["MULTIMEDIA"] == "no")        qconfigList += "QT_NO_MULTIMEDIA";
        if (dictionary["XMLPATTERNS"] == "no")       qconfigList += "QT_NO_XMLPATTERNS";
        if (dictionary["SCRIPT"] == "no")            qconfigList += "QT_NO_SCRIPT";
        if (dictionary["SCRIPTTOOLS"] == "no")       qconfigList += "QT_NO_SCRIPTTOOLS";
        if (dictionary["FREETYPE"] == "no")          qconfigList += "QT_NO_FREETYPE";
        if (dictionary["S60"] == "no")               qconfigList += "QT_NO_S60";
        if (dictionary["NATIVE_GESTURES"] == "no")   qconfigList += "QT_NO_NATIVE_GESTURES";

        if ((dictionary["OPENGL_ES_CM"]   == "no"
             && dictionary["OPENGL_ES_2"] == "no"
             && dictionary["OPENVG"]      == "no")
            || (dictionary["QPA"]         == "yes")) qconfigList += "QT_NO_EGL";

        if (dictionary["OPENGL_ES_CM"] == "yes" ||
           dictionary["OPENGL_ES_2"]  == "yes")     qconfigList += "QT_OPENGL_ES";

        if (dictionary["OPENGL_ES_CM"] == "yes")     qconfigList += "QT_OPENGL_ES_1";
        if (dictionary["OPENGL_ES_2"]  == "yes")     qconfigList += "QT_OPENGL_ES_2";
        if (dictionary["SQL_MYSQL"] == "yes")        qconfigList += "QT_SQL_MYSQL";
        if (dictionary["SQL_ODBC"] == "yes")         qconfigList += "QT_SQL_ODBC";
        if (dictionary["SQL_OCI"] == "yes")          qconfigList += "QT_SQL_OCI";
        if (dictionary["SQL_PSQL"] == "yes")         qconfigList += "QT_SQL_PSQL";
        if (dictionary["SQL_TDS"] == "yes")          qconfigList += "QT_SQL_TDS";
        if (dictionary["SQL_DB2"] == "yes")          qconfigList += "QT_SQL_DB2";
        if (dictionary["SQL_SQLITE"] == "yes")       qconfigList += "QT_SQL_SQLITE";
        if (dictionary["SQL_SQLITE2"] == "yes")      qconfigList += "QT_SQL_SQLITE2";
        if (dictionary["SQL_IBASE"] == "yes")        qconfigList += "QT_SQL_IBASE";

        if (dictionary["GRAPHICS_SYSTEM"] == "openvg")  qconfigList += "QT_GRAPHICSSYSTEM_OPENVG";
        if (dictionary["GRAPHICS_SYSTEM"] == "opengl")  qconfigList += "QT_GRAPHICSSYSTEM_OPENGL";
        if (dictionary["GRAPHICS_SYSTEM"] == "raster")  qconfigList += "QT_GRAPHICSSYSTEM_RASTER";
        if (dictionary["GRAPHICS_SYSTEM"] == "runtime") qconfigList += "QT_GRAPHICSSYSTEM_RUNTIME";

        if (dictionary["POSIX_IPC"] == "yes")        qconfigList += "QT_POSIX_IPC";

        if (dictionary["QPA"] == "yes")
            qconfigList << "Q_WS_QPA" << "QT_NO_QWS_QPF" << "QT_NO_QWS_QPF2";

        if (dictionary["NIS"] == "yes")
            qconfigList << "QT_NIS";
        else
            qconfigList << "QT_NO_NIS";

        if (dictionary["LARGE_FILE"] == "yes")
            tmpStream << "#define QT_LARGEFILE_SUPPORT 64" << endl;

        if (dictionary["FONT_CONFIG"] == "no")
            qconfigList << "QT_NO_FONTCONFIG";

        if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith("symbian")) {
            // These features are not ported to Symbian (yet)
            qconfigList += "QT_NO_CRASHHANDLER";
            qconfigList += "QT_NO_PRINTER";
            qconfigList += "QT_NO_SYSTEMTRAYICON";
            if (dictionary.contains("QT_LIBINFIX"))
                tmpStream << QString("#define QT_LIBINFIX \"%1\"").arg(dictionary["QT_LIBINFIX"]) << endl;
        }

        qconfigList.sort();
        for (int i = 0; i < qconfigList.count(); ++i)
            tmpStream << addDefine(qconfigList.at(i));

        if (dictionary["EMBEDDED"] == "yes")
        {
            // Check for keyboard, mouse, gfx.
            QStringList kbdDrivers = dictionary["KBD_DRIVERS"].split(" ");;
            QStringList allKbdDrivers;
            allKbdDrivers<<"tty"<<"usb"<<"sl5000"<<"yopy"<<"vr41xx"<<"qvfb"<<"um";
            foreach (const QString &kbd, allKbdDrivers) {
                if (!kbdDrivers.contains(kbd))
                    tmpStream<<"#define QT_NO_QWS_KBD_"<<kbd.toUpper()<<endl;
            }

            QStringList mouseDrivers = dictionary["MOUSE_DRIVERS"].split(" ");
            QStringList allMouseDrivers;
            allMouseDrivers << "pc"<<"bus"<<"linuxtp"<<"yopy"<<"vr41xx"<<"tslib"<<"qvfb";
            foreach (const QString &mouse, allMouseDrivers) {
                if (!mouseDrivers.contains(mouse))
                    tmpStream<<"#define QT_NO_QWS_MOUSE_"<<mouse.toUpper()<<endl;
            }

            QStringList gfxDrivers = dictionary["GFX_DRIVERS"].split(" ");
            QStringList allGfxDrivers;
            allGfxDrivers<<"linuxfb"<<"transformed"<<"qvfb"<<"vnc"<<"multiscreen"<<"ahi";
            foreach (const QString &gfx, allGfxDrivers) {
                if (!gfxDrivers.contains(gfx))
                    tmpStream<<"#define QT_NO_QWS_"<<gfx.toUpper()<<endl;
            }

            tmpStream<<"#define Q_WS_QWS"<<endl;

            QStringList depths = dictionary[ "QT_QWS_DEPTH" ].split(" ");
            foreach (const QString &depth, depths)
              tmpStream<<"#define QT_QWS_DEPTH_"+depth<<endl;
        }

        if (dictionary[ "QT_CUPS" ] == "no")
          tmpStream<<"#define QT_NO_CUPS"<<endl;

        if (dictionary[ "QT_ICONV" ]  == "no")
          tmpStream<<"#define QT_NO_ICONV"<<endl;

        if (dictionary[ "QT_GLIB" ] == "no")
          tmpStream<<"#define QT_NO_GLIB"<<endl;

        if (dictionary[ "QT_LPR" ] == "no")
          tmpStream<<"#define QT_NO_LPR"<<endl;

        if (dictionary[ "QT_INOTIFY" ] == "no")
          tmpStream<<"#define QT_NO_INOTIFY"<<endl;

        if (dictionary[ "QT_SXE" ] == "no")
          tmpStream<<"#define QT_NO_SXE"<<endl;

        if (dictionary[ "QPA" ] == "yes")
          tmpStream<<"#define QT_QPA_DEFAULT_PLATFORM_NAME \"" << qpaPlatformName() << "\""<<endl;

        tmpStream.flush();
        tmpFile.flush();

        // Replace old qconfig.h with new one
        ::SetFileAttributes((wchar_t*)outName.utf16(), FILE_ATTRIBUTE_NORMAL);
        QFile::remove(outName);
        tmpFile.copy(outName);
        tmpFile.close();
    }

    // Copy configured mkspec to default directory, but remove the old one first, if there is any
    QString defSpec = buildPath + "/mkspecs/default";
    QFileInfo defSpecInfo(defSpec);
    if (defSpecInfo.exists()) {
        if (!Environment::rmdir(defSpec)) {
            cout << "Couldn't update default mkspec! Are files in " << qPrintable(defSpec) << " read-only?" << endl;
            dictionary["DONE"] = "error";
            return;
        }
    }

    QString spec = dictionary.contains("XQMAKESPEC") ? dictionary["XQMAKESPEC"] : dictionary["QMAKESPEC"];
    QString pltSpec = sourcePath + "/mkspecs/" + spec;
    QString includeSpec = buildPath + "/mkspecs/" + spec;
    if (!Environment::cpdir(pltSpec, defSpec, includeSpec)) {
        cout << "Couldn't update default mkspec! Does " << qPrintable(pltSpec) << " exist?" << endl;
        dictionary["DONE"] = "error";
        return;
    }

    // Generate the new qconfig.cpp file
    QDir(buildPath).mkpath("src/corelib/global");
    outName = buildPath + "/src/corelib/global/qconfig.cpp";

    QTemporaryFile tmpFile2;
    if (tmpFile2.open()) {
        tmpStream.setDevice(&tmpFile2);
        tmpStream << "/* Licensed */" << endl
                  << "static const char qt_configure_licensee_str          [512 + 12] = \"qt_lcnsuser=" << licenseInfo["LICENSEE"] << "\";" << endl
                  << "static const char qt_configure_licensed_products_str [512 + 12] = \"qt_lcnsprod=" << dictionary["EDITION"] << "\";" << endl
                  << endl
                  << "/* Build date */" << endl
                  << "static const char qt_configure_installation          [11  + 12] = \"qt_instdate=" << QDate::currentDate().toString(Qt::ISODate) << "\";" << endl
                  << endl;
        if (!dictionary[ "QT_HOST_PREFIX" ].isNull())
            tmpStream << "#if !defined(QT_BOOTSTRAPPED) && !defined(QT_BUILD_QMAKE)" << endl;
        tmpStream << "static const char qt_configure_prefix_path_str       [512 + 12] = \"qt_prfxpath=" << escapeSeparators(dictionary["QT_INSTALL_PREFIX"]) << "\";" << endl
                  << "static const char qt_configure_documentation_path_str[512 + 12] = \"qt_docspath=" << escapeSeparators(dictionary["QT_INSTALL_DOCS"]) << "\";"  << endl
                  << "static const char qt_configure_headers_path_str      [512 + 12] = \"qt_hdrspath=" << escapeSeparators(dictionary["QT_INSTALL_HEADERS"]) << "\";"  << endl
                  << "static const char qt_configure_libraries_path_str    [512 + 12] = \"qt_libspath=" << escapeSeparators(dictionary["QT_INSTALL_LIBS"]) << "\";"  << endl
                  << "static const char qt_configure_binaries_path_str     [512 + 12] = \"qt_binspath=" << escapeSeparators(dictionary["QT_INSTALL_BINS"]) << "\";"  << endl
                  << "static const char qt_configure_plugins_path_str      [512 + 12] = \"qt_plugpath=" << escapeSeparators(dictionary["QT_INSTALL_PLUGINS"]) << "\";"  << endl
                  << "static const char qt_configure_imports_path_str      [512 + 12] = \"qt_impspath=" << escapeSeparators(dictionary["QT_INSTALL_IMPORTS"]) << "\";"  << endl
                  << "static const char qt_configure_data_path_str         [512 + 12] = \"qt_datapath=" << escapeSeparators(dictionary["QT_INSTALL_DATA"]) << "\";"  << endl
                  << "static const char qt_configure_translations_path_str [512 + 12] = \"qt_trnspath=" << escapeSeparators(dictionary["QT_INSTALL_TRANSLATIONS"]) << "\";" << endl
                  << "static const char qt_configure_examples_path_str     [512 + 12] = \"qt_xmplpath=" << escapeSeparators(dictionary["QT_INSTALL_EXAMPLES"]) << "\";"  << endl
                  << "static const char qt_configure_demos_path_str        [512 + 12] = \"qt_demopath=" << escapeSeparators(dictionary["QT_INSTALL_DEMOS"]) << "\";"  << endl
                  //<< "static const char qt_configure_settings_path_str [256] = \"qt_stngpath=" << escapeSeparators(dictionary["QT_INSTALL_SETTINGS"]) << "\";" << endl
                  ;
        if (!dictionary[ "QT_HOST_PREFIX" ].isNull()) {
             tmpStream << "#else" << endl
                       << "static const char qt_configure_prefix_path_str       [512 + 12] = \"qt_prfxpath=" << escapeSeparators(dictionary[ "QT_HOST_PREFIX" ]) << "\";" << endl
                       << "static const char qt_configure_documentation_path_str[512 + 12] = \"qt_docspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/doc", true) <<"\";"  << endl
                       << "static const char qt_configure_headers_path_str      [512 + 12] = \"qt_hdrspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/include", true) <<"\";"  << endl
                       << "static const char qt_configure_libraries_path_str    [512 + 12] = \"qt_libspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/lib", true) <<"\";"  << endl
                       << "static const char qt_configure_binaries_path_str     [512 + 12] = \"qt_binspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/bin", true) <<"\";"  << endl
                       << "static const char qt_configure_plugins_path_str      [512 + 12] = \"qt_plugpath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/plugins", true) <<"\";"  << endl
                       << "static const char qt_configure_imports_path_str      [512 + 12] = \"qt_impspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/imports", true) <<"\";"  << endl
                       << "static const char qt_configure_data_path_str         [512 + 12] = \"qt_datapath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ], true) <<"\";"  << endl
                       << "static const char qt_configure_translations_path_str [512 + 12] = \"qt_trnspath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/translations", true) <<"\";" << endl
                       << "static const char qt_configure_examples_path_str     [512 + 12] = \"qt_xmplpath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/example", true) <<"\";"  << endl
                       << "static const char qt_configure_demos_path_str        [512 + 12] = \"qt_demopath=" << fixSeparators(dictionary[ "QT_HOST_PREFIX" ] + "/demos", true) <<"\";"  << endl
                       << "#endif //QT_BOOTSTRAPPED" << endl;
        }
        tmpStream << "/* strlen( \"qt_lcnsxxxx\") == 12 */" << endl
                  << "#define QT_CONFIGURE_LICENSEE qt_configure_licensee_str + 12;" << endl
                  << "#define QT_CONFIGURE_LICENSED_PRODUCTS qt_configure_licensed_products_str + 12;" << endl
                  << "#define QT_CONFIGURE_PREFIX_PATH qt_configure_prefix_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_DOCUMENTATION_PATH qt_configure_documentation_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_HEADERS_PATH qt_configure_headers_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_LIBRARIES_PATH qt_configure_libraries_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_BINARIES_PATH qt_configure_binaries_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_PLUGINS_PATH qt_configure_plugins_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_IMPORTS_PATH qt_configure_imports_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_DATA_PATH qt_configure_data_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_TRANSLATIONS_PATH qt_configure_translations_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_EXAMPLES_PATH qt_configure_examples_path_str + 12;" << endl
                  << "#define QT_CONFIGURE_DEMOS_PATH qt_configure_demos_path_str + 12;" << endl
                  //<< "#define QT_CONFIGURE_SETTINGS_PATH qt_configure_settings_path_str + 12;" << endl
                  << endl;

        tmpStream.flush();
        tmpFile2.flush();

        // Replace old qconfig.cpp with new one
        ::SetFileAttributes((wchar_t*)outName.utf16(), FILE_ATTRIBUTE_NORMAL);
        QFile::remove(outName);
        tmpFile2.copy(outName);
        tmpFile2.close();
    }

    QTemporaryFile tmpFile3;
    if (tmpFile3.open()) {
        tmpStream.setDevice(&tmpFile3);
        tmpStream << "/* Evaluation license key */" << endl
                  << "static const volatile char qt_eval_key_data              [512 + 12] = \"qt_qevalkey=" << licenseInfo["LICENSEKEYEXT"] << "\";" << endl;

        tmpStream.flush();
        tmpFile3.flush();

        outName = buildPath + "/src/corelib/global/qconfig_eval.cpp";
        ::SetFileAttributes((wchar_t*)outName.utf16(), FILE_ATTRIBUTE_NORMAL);
        QFile::remove(outName);

        if (dictionary["EDITION"] == "Evaluation" || qmakeDefines.contains("QT_EVAL"))
            tmpFile3.copy(outName);
        tmpFile3.close();
    }
}
#endif

#if !defined(EVAL)
void Configure::displayConfig()
{
    // Give some feedback
    cout << "Environment:" << endl;
    QString env = QString::fromLocal8Bit(getenv("INCLUDE")).replace(QRegExp("[;,]"), "\r\n      ");
    if (env.isEmpty())
        env = "Unset";
    cout << "    INCLUDE=\r\n      " << env << endl;
    env = QString::fromLocal8Bit(getenv("LIB")).replace(QRegExp("[;,]"), "\r\n      ");
    if (env.isEmpty())
        env = "Unset";
    cout << "    LIB=\r\n      " << env << endl;
    env = QString::fromLocal8Bit(getenv("PATH")).replace(QRegExp("[;,]"), "\r\n      ");
    if (env.isEmpty())
        env = "Unset";
    cout << "    PATH=\r\n      " << env << endl;

    if (dictionary["EDITION"] == "OpenSource") {
        cout << "You are licensed to use this software under the terms of the GNU GPL version 3.";
        cout << "You are licensed to use this software under the terms of the Lesser GNU LGPL version 2.1." << endl;
        cout << "See " << dictionary["LICENSE FILE"] << "3" << endl << endl
             << " or " << dictionary["LICENSE FILE"] << "L" << endl << endl;
    } else {
        QString l1 = licenseInfo[ "LICENSEE" ];
        QString l2 = licenseInfo[ "LICENSEID" ];
        QString l3 = dictionary["EDITION"] + ' ' + "Edition";
        QString l4 = licenseInfo[ "EXPIRYDATE" ];
        cout << "Licensee...................." << (l1.isNull() ? "" : l1) << endl;
        cout << "License ID.................." << (l2.isNull() ? "" : l2) << endl;
        cout << "Product license............." << (l3.isNull() ? "" : l3) << endl;
        cout << "Expiry Date................." << (l4.isNull() ? "" : l4) << endl << endl;
    }

    cout << "Configuration:" << endl;
    cout << "    " << qmakeConfig.join("\r\n    ") << endl;
    cout << "Qt Configuration:" << endl;
    cout << "    " << qtConfig.join("\r\n    ") << endl;
    cout << endl;

    if (dictionary.contains("XQMAKESPEC"))
        cout << "QMAKESPEC..................." << dictionary[ "XQMAKESPEC" ] << " (" << dictionary["QMAKESPEC_FROM"] << ")" << endl;
    else
        cout << "QMAKESPEC..................." << dictionary[ "QMAKESPEC" ] << " (" << dictionary["QMAKESPEC_FROM"] << ")" << endl;
    cout << "Architecture................" << dictionary[ "ARCHITECTURE" ] << endl;
    cout << "Maketool...................." << dictionary[ "MAKE" ] << endl;
    cout << "Debug symbols..............." << (dictionary[ "BUILD" ] == "debug" ? "yes" : "no") << endl;
    cout << "Link Time Code Generation..." << dictionary[ "LTCG" ] << endl;
    cout << "Accessibility support......." << dictionary[ "ACCESSIBILITY" ] << endl;
    cout << "STL support................." << dictionary[ "STL" ] << endl;
    cout << "Exception support..........." << dictionary[ "EXCEPTIONS" ] << endl;
    cout << "RTTI support................" << dictionary[ "RTTI" ] << endl;
    cout << "MMX support................." << dictionary[ "MMX" ] << endl;
    cout << "3DNOW support..............." << dictionary[ "3DNOW" ] << endl;
    cout << "SSE support................." << dictionary[ "SSE" ] << endl;
    cout << "SSE2 support................" << dictionary[ "SSE2" ] << endl;
    cout << "IWMMXT support.............." << dictionary[ "IWMMXT" ] << endl;
    cout << "NEON support................" << dictionary[ "NEON" ] << endl;
    cout << "OpenGL support.............." << dictionary[ "OPENGL" ] << endl;
    cout << "OpenVG support.............." << dictionary[ "OPENVG" ] << endl;
    cout << "OpenSSL support............." << dictionary[ "OPENSSL" ] << endl;
    cout << "QtDBus support.............." << dictionary[ "DBUS" ] << endl;
    cout << "QtXmlPatterns support......." << dictionary[ "XMLPATTERNS" ] << endl;
    cout << "Phonon support.............." << dictionary[ "PHONON" ] << endl;
    cout << "QtMultimedia support........" << dictionary[ "MULTIMEDIA" ] << endl;
    cout << "Large File support.........." << dictionary[ "LARGE_FILE" ] << endl;
    cout << "NIS support................." << dictionary[ "NIS" ] << endl;
    cout << "Iconv support..............." << dictionary[ "QT_ICONV" ] << endl;
    cout << "Inotify support............." << dictionary[ "QT_INOTIFY" ] << endl;
    {
        QString webkit = dictionary[ "WEBKIT" ];
        if (webkit == "debug")
            webkit = "yes (debug)";
        cout << "WebKit support.............." << webkit << endl;
    }
    {
        QString declarative = dictionary[ "DECLARATIVE" ];
        cout << "Declarative support........." << declarative << endl;
        if (declarative == "yes")
            cout << "Declarative debugging......." << dictionary[ "DECLARATIVE_DEBUG" ] << endl;
    }
    cout << "QtScript support............" << dictionary[ "SCRIPT" ] << endl;
    cout << "QtScriptTools support......." << dictionary[ "SCRIPTTOOLS" ] << endl;
    cout << "Graphics System............." << dictionary[ "GRAPHICS_SYSTEM" ] << endl;
    cout << "Qt3 compatibility..........." << dictionary[ "QT3SUPPORT" ] << endl;
    cout << "DirectWrite support........." << dictionary[ "DIRECTWRITE" ] << endl;
    cout << "Use system proxies.........." << dictionary[ "SYSTEM_PROXIES" ] << endl << endl;

    cout << "Third Party Libraries:" << endl;
    cout << "    ZLIB support............" << dictionary[ "ZLIB" ] << endl;
    cout << "    GIF support............." << dictionary[ "GIF" ] << endl;
    cout << "    TIFF support............" << dictionary[ "TIFF" ] << endl;
    cout << "    JPEG support............" << dictionary[ "JPEG" ] << endl;
    cout << "    PNG support............." << dictionary[ "PNG" ] << endl;
    cout << "    MNG support............." << dictionary[ "MNG" ] << endl;
    cout << "    FreeType support........" << dictionary[ "FREETYPE" ] << endl << endl;
    if (platform() == QNX || platform() == BLACKBERRY)
        cout << "    SLOG2 support..........." << dictionary[ "SLOG2" ] << endl;

    cout << "Styles:" << endl;
    cout << "    Windows................." << dictionary[ "STYLE_WINDOWS" ] << endl;
    cout << "    Windows XP.............." << dictionary[ "STYLE_WINDOWSXP" ] << endl;
    cout << "    Windows Vista..........." << dictionary[ "STYLE_WINDOWSVISTA" ] << endl;
    cout << "    Plastique..............." << dictionary[ "STYLE_PLASTIQUE" ] << endl;
    cout << "    Cleanlooks.............." << dictionary[ "STYLE_CLEANLOOKS" ] << endl;
    cout << "    Motif..................." << dictionary[ "STYLE_MOTIF" ] << endl;
    cout << "    CDE....................." << dictionary[ "STYLE_CDE" ] << endl;
    cout << "    Windows CE.............." << dictionary[ "STYLE_WINDOWSCE" ] << endl;
    cout << "    Windows Mobile.........." << dictionary[ "STYLE_WINDOWSMOBILE" ] << endl;
    cout << "    S60....................." << dictionary[ "STYLE_S60" ] << endl << endl;

    cout << "Sql Drivers:" << endl;
    cout << "    ODBC...................." << dictionary[ "SQL_ODBC" ] << endl;
    cout << "    MySQL..................." << dictionary[ "SQL_MYSQL" ] << endl;
    cout << "    OCI....................." << dictionary[ "SQL_OCI" ] << endl;
    cout << "    PostgreSQL.............." << dictionary[ "SQL_PSQL" ] << endl;
    cout << "    TDS....................." << dictionary[ "SQL_TDS" ] << endl;
    cout << "    DB2....................." << dictionary[ "SQL_DB2" ] << endl;
    cout << "    SQLite.................." << dictionary[ "SQL_SQLITE" ] << " (" << dictionary[ "SQL_SQLITE_LIB" ] << ")" << endl;
    cout << "    SQLite2................." << dictionary[ "SQL_SQLITE2" ] << endl;
    cout << "    InterBase..............." << dictionary[ "SQL_IBASE" ] << endl << endl;

    cout << "Sources are in.............." << dictionary[ "QT_SOURCE_TREE" ] << endl;
    cout << "Build is done in............" << dictionary[ "QT_BUILD_TREE" ] << endl;
    cout << "Install prefix.............." << dictionary[ "QT_INSTALL_PREFIX" ] << endl;
    cout << "Headers installed to........" << dictionary[ "QT_INSTALL_HEADERS" ] << endl;
    cout << "Libraries installed to......" << dictionary[ "QT_INSTALL_LIBS" ] << endl;
    cout << "Plugins installed to........" << dictionary[ "QT_INSTALL_PLUGINS" ] << endl;
    cout << "Imports installed to........" << dictionary[ "QT_INSTALL_IMPORTS" ] << endl;
    cout << "Binaries installed to......." << dictionary[ "QT_INSTALL_BINS" ] << endl;
    cout << "Docs installed to..........." << dictionary[ "QT_INSTALL_DOCS" ] << endl;
    cout << "Data installed to..........." << dictionary[ "QT_INSTALL_DATA" ] << endl;
    cout << "Translations installed to..." << dictionary[ "QT_INSTALL_TRANSLATIONS" ] << endl;
    cout << "Examples installed to......." << dictionary[ "QT_INSTALL_EXAMPLES" ] << endl;
    cout << "Demos installed to.........." << dictionary[ "QT_INSTALL_DEMOS" ] << endl << endl;

    if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith(QLatin1String("wince"))) {
        cout << "Using c runtime detection..." << dictionary[ "CE_CRT" ] << endl;
        cout << "Cetest support.............." << dictionary[ "CETEST" ] << endl;
        cout << "Signature..................." << dictionary[ "CE_SIGNATURE"] << endl << endl;
    }

    if (dictionary.contains("XQMAKESPEC") && dictionary["XQMAKESPEC"].startsWith(QLatin1String("symbian"))) {
        cout << "Support for S60............." << dictionary[ "S60" ] << endl;
    }

    if (dictionary.contains("SYMBIAN_DEFFILES")) {
        cout << "Symbian DEF files enabled..." << dictionary[ "SYMBIAN_DEFFILES" ] << endl;
        if (dictionary["SYMBIAN_DEFFILES"] == "no") {
            cout << "WARNING: Disabling DEF files will mean that Qt is NOT binary compatible with previous versions." << endl;
            cout << "         This feature is only intended for use during development, NEVER for release builds." << endl;
        }
    }

    if (dictionary["ASSISTANT_WEBKIT"] == "yes")
        cout << "Using WebKit as html rendering engine in Qt Assistant." << endl;

    if (checkAvailability("INCREDIBUILD_XGE"))
        cout << "Using IncrediBuild XGE......" << dictionary["INCREDIBUILD_XGE"] << endl;
    if (!qmakeDefines.isEmpty()) {
        cout << "Defines.....................";
        for (QStringList::Iterator defs = qmakeDefines.begin(); defs != qmakeDefines.end(); ++defs)
            cout << (*defs) << " ";
        cout << endl;
    }
    if (!qmakeIncludes.isEmpty()) {
        cout << "Include paths...............";
        for (QStringList::Iterator incs = qmakeIncludes.begin(); incs != qmakeIncludes.end(); ++incs)
            cout << (*incs) << " ";
        cout << endl;
    }
    if (!qmakeLibs.isEmpty()) {
        cout << "Additional libraries........";
        for (QStringList::Iterator libs = qmakeLibs.begin(); libs != qmakeLibs.end(); ++libs)
            cout << (*libs) << " ";
        cout << endl;
    }
    if (dictionary[ "QMAKE_INTERNAL" ] == "yes") {
        cout << "Using internal configuration." << endl;
    }
    if (dictionary[ "SHARED" ] == "no") {
        cout << "WARNING: Using static linking will disable the use of plugins." << endl;
        cout << "         Make sure you compile ALL needed modules into the library." << endl;
    }
    if (dictionary[ "OPENSSL" ] == "linked") {
        if (!opensslLibsDebug.isEmpty() || !opensslLibsRelease.isEmpty()) {
            cout << "Using OpenSSL libraries:" << endl;
            cout << "   debug  : " << opensslLibsDebug << endl;
            cout << "   release: " << opensslLibsRelease << endl;
            cout << "   both   : " << opensslLibs << endl;
        } else if (opensslLibs.isEmpty()) {
            cout << "NOTE: When linking against OpenSSL, you can override the default" << endl;
            cout << "library names through OPENSSL_LIBS and optionally OPENSSL_LIBS_DEBUG/OPENSSL_LIBS_RELEASE" << endl;
            cout << "For example:" << endl;
            cout << "    configure -openssl-linked OPENSSL_LIBS=\"-lssleay32 -llibeay32\"" << endl;
        }
    }
    if (dictionary[ "ZLIB_FORCED" ] == "yes") {
        QString which_zlib = "supplied";
        if (dictionary[ "ZLIB" ] == "system")
            which_zlib = "system";

        cout << "NOTE: The -no-zlib option was supplied but is no longer supported." << endl
             << endl
             << "Qt now requires zlib support in all builds, so the -no-zlib" << endl
             << "option was ignored. Qt will be built using the " << which_zlib
             << "zlib" << endl;
    }
}
#endif

#if !defined(EVAL)
void Configure::generateHeaders()
{
    if (dictionary["SYNCQT"] == "yes") {
        if (findFile("perl.exe")) {
            cout << "Running syncqt..." << endl;
            QStringList args;
            args += buildPath + "/bin/syncqt.bat";
            QStringList env;
            env += QString("QTDIR=" + sourcePath);
            env += QString("PATH=" + buildPath + "/bin/;" + qgetenv("PATH"));
            int retc = Environment::execute(args, env, QStringList());
            if (retc) {
                cout << "syncqt failed, return code " << retc << endl << endl;
                dictionary["DONE"] = "error";
            }
        } else {
            cout << "Perl not found in environment - cannot run syncqt." << endl;
            dictionary["DONE"] = "error";
        }
    }
}

void Configure::buildQmake()
{
    if (dictionary[ "BUILD_QMAKE" ] == "yes") {
        QStringList args;

        // Build qmake
        QString pwd = QDir::currentPath();
        QDir::setCurrent(buildPath + "/qmake");

        QString makefile = "Makefile";
        {
            QFile out(makefile);
            if (out.open(QFile::WriteOnly | QFile::Text)) {
                QTextStream stream(&out);
                stream << "#AutoGenerated by configure.exe" << endl
                    << "BUILD_PATH = " << QDir::convertSeparators(buildPath) << endl
                    << "SOURCE_PATH = " << QDir::convertSeparators(sourcePath) << endl;
                stream << "QMAKESPEC = " << dictionary["QMAKESPEC"] << endl;

                if (dictionary["EDITION"] == "OpenSource" ||
                    dictionary["QT_EDITION"].contains("OPENSOURCE"))
                    stream << "QMAKE_OPENSOURCE_EDITION = yes" << endl;
                stream << "\n\n";

                QFile in(sourcePath + "/qmake/" + dictionary["QMAKEMAKEFILE"]);
                if (in.open(QFile::ReadOnly | QFile::Text)) {
                    QString d = in.readAll();
                    //### need replaces (like configure.sh)? --Sam
                    stream << d << endl;
                }
                stream.flush();
                out.close();
            }
        }

        args += dictionary[ "MAKE" ];
        args += "-f";
        args += makefile;

        cout << "Creating qmake..." << endl;
        int exitCode = Environment::execute(args, QStringList(), QStringList());
        if (exitCode) {
            args.clear();
            args += dictionary[ "MAKE" ];
            args += "-f";
            args += makefile;
            args += "clean";
            exitCode = Environment::execute(args, QStringList(), QStringList());
            if (exitCode) {
                cout << "Cleaning qmake failed, return code " << exitCode << endl << endl;
                dictionary[ "DONE" ] = "error";
            } else {
                args.clear();
                args += dictionary[ "MAKE" ];
                args += "-f";
                args += makefile;
                exitCode = Environment::execute(args, QStringList(), QStringList());
                if (exitCode) {
                    cout << "Building qmake failed, return code " << exitCode << endl << endl;
                    dictionary[ "DONE" ] = "error";
                }
            }
        }
        QDir::setCurrent(pwd);
    }
}
#endif

void Configure::buildHostTools()
{
    if (dictionary[ "NOPROCESS" ] == "yes")
        dictionary[ "DONE" ] = "yes";

    if (!dictionary.contains("XQMAKESPEC"))
        return;

    QString pwd = QDir::currentPath();
    QStringList hostToolsDirs;
    hostToolsDirs
        << "src/tools"
        << "tools/linguist/lrelease";

    if (dictionary["XQMAKESPEC"].startsWith("wince"))
        hostToolsDirs << "tools/checksdk";

    if (dictionary[ "CETEST" ] == "yes")
        hostToolsDirs << "tools/qtestlib/wince/cetest";

    for (int i = 0; i < hostToolsDirs.count(); ++i) {
        cout << "Creating " << hostToolsDirs.at(i) << " ..." << endl;
        QString toolBuildPath = buildPath + "/" + hostToolsDirs.at(i);
        QString toolSourcePath = sourcePath + "/" + hostToolsDirs.at(i);

        // generate Makefile
        QStringList args;
        args << QDir::toNativeSeparators(buildPath + "/bin/qmake");
        // override .qmake.cache because we are not cross-building these.
        // we need a full path so that a build with -prefix will still find it.
        args << "-spec" << QDir::toNativeSeparators(buildPath + "/mkspecs/" + dictionary["QMAKESPEC"]);
        args << "-r";
        args << "-o" << QDir::toNativeSeparators(toolBuildPath + "/Makefile");

        QDir().mkpath(toolBuildPath);
        QDir::setCurrent(toolSourcePath);
        int exitCode = Environment::execute(args, QStringList(), QStringList());
        if (exitCode) {
            cout << "qmake failed, return code " << exitCode << endl << endl;
            dictionary["DONE"] = "error";
            break;
        }

        // build app
        args.clear();
        args += dictionary["MAKE"];
        QDir::setCurrent(toolBuildPath);
        exitCode = Environment::execute(args, QStringList(), QStringList());
        if (exitCode) {
            args.clear();
            args += dictionary["MAKE"];
            args += "clean";
            exitCode = Environment::execute(args, QStringList(), QStringList());
            if (exitCode) {
                cout << "Cleaning " << hostToolsDirs.at(i) << " failed, return code " << exitCode << endl << endl;
                dictionary["DONE"] = "error";
                break;
            } else {
                args.clear();
                args += dictionary["MAKE"];
                exitCode = Environment::execute(args, QStringList(), QStringList());
                if (exitCode) {
                    cout << "Building " << hostToolsDirs.at(i) << " failed, return code " << exitCode << endl << endl;
                    dictionary["DONE"] = "error";
                    break;
                }
            }
        }
    }
    QDir::setCurrent(pwd);
}

void Configure::findProjects(const QString& dirName)
{
    if (dictionary[ "NOPROCESS" ] == "no") {
        QDir dir(dirName);
        QString entryName;
        int makeListNumber;
        ProjectType qmakeTemplate;
        const QFileInfoList &list = dir.entryInfoList(QStringList(QLatin1String("*.pro")),
                                                      QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot);
        for (int i = 0; i < list.size(); ++i) {
            const QFileInfo &fi = list.at(i);
            if (fi.fileName() != "qmake.pro") {
                entryName = dirName + "/" + fi.fileName();
                if (fi.isDir()) {
                    findProjects(entryName);
                } else {
                    qmakeTemplate = projectType(fi.absoluteFilePath());
                    switch (qmakeTemplate) {
                    case Lib:
                    case Subdirs:
                        makeListNumber = 1;
                        break;
                    default:
                        makeListNumber = 2;
                        break;
                    }
                    makeList[makeListNumber].append(new MakeItem(sourceDir.relativeFilePath(fi.absolutePath()),
                                                    fi.fileName(),
                                                    "Makefile",
                                                    qmakeTemplate));
                }
            }

        }
    }
}

void Configure::appendMakeItem(int inList, const QString &item)
{
    QString dir;
    if (item != "src")
        dir = "/" + item;
    dir.prepend("/src");
    makeList[inList].append(new MakeItem(sourcePath + dir,
        item + ".pro", buildPath + dir + "/Makefile", Lib));
    if (dictionary[ "DSPFILES" ] == "yes") {
        makeList[inList].append(new MakeItem(sourcePath + dir,
            item + ".pro", buildPath + dir + "/" + item + ".dsp", Lib));
    }
    if (dictionary[ "VCPFILES" ] == "yes") {
        makeList[inList].append(new MakeItem(sourcePath + dir,
            item + ".pro", buildPath + dir + "/" + item + ".vcp", Lib));
    }
    if (dictionary[ "VCPROJFILES" ] == "yes") {
        makeList[inList].append(new MakeItem(sourcePath + dir,
            item + ".pro", buildPath + dir + "/" + item + ".vcproj", Lib));
    }
}

void Configure::generateMakefiles()
{
    if (dictionary[ "NOPROCESS" ] == "no") {
#if !defined(EVAL)
        cout << "Creating makefiles in src..." << endl;
#endif

        QString spec = dictionary.contains("XQMAKESPEC") ? dictionary[ "XQMAKESPEC" ] : dictionary[ "QMAKESPEC" ];
        if (spec != "win32-msvc")
            dictionary[ "DSPFILES" ] = "no";

        if (spec != "win32-msvc.net" && !spec.startsWith("win32-msvc2") && !spec.startsWith(QLatin1String("wince")))
            dictionary[ "VCPROJFILES" ] = "no";

        int i = 0;
        QString pwd = QDir::currentPath();
        if (dictionary["FAST"] != "yes") {
            QString dirName;
            bool generate = true;
            bool doDsp = (dictionary["DSPFILES"] == "yes" || dictionary["VCPFILES"] == "yes"
                          || dictionary["VCPROJFILES"] == "yes");
            while (generate) {
                QString pwd = QDir::currentPath();
                QString dirPath = fixSeparators(buildPath + dirName);
                QStringList args;

                args << fixSeparators(buildPath + "/bin/qmake");

                if (doDsp) {
                    if (dictionary[ "DEPENDENCIES" ] == "no")
                        args << "-nodepend";
                    args << "-tp" <<  "vc";
                    doDsp = false; // DSP files will be done
                    printf("Generating Visual Studio project files...\n");
                } else {
                    printf("Generating Makefiles...\n");
                    generate = false; // Now Makefiles will be done
                }
                // don't pass -spec - .qmake.cache has it already
                args << "-r";
                args << (sourcePath + "/projects.pro");
                args << "-o";
                args << buildPath;
                if (!dictionary[ "QMAKEADDITIONALARGS" ].isEmpty())
                    args << dictionary[ "QMAKEADDITIONALARGS" ];

                QDir::setCurrent(fixSeparators(dirPath));
                if (int exitCode = Environment::execute(args, QStringList(), QStringList())) {
                    cout << "Qmake failed, return code " << exitCode  << endl << endl;
                    dictionary[ "DONE" ] = "error";
                }
            }
        } else {
            findProjects(sourcePath);
            for (i=0; i<3; i++) {
                for (int j=0; j<makeList[i].size(); ++j) {
                    MakeItem *it=makeList[i][j];
                    QString dirPath = fixSeparators(it->directory + "/");
                    QString projectName = it->proFile;
                    QString makefileName = buildPath + "/" + dirPath + it->target;

                    // For shadowbuilds, we need to create the path first
                    QDir buildPathDir(buildPath);
                    if (sourcePath != buildPath && !buildPathDir.exists(dirPath))
                        buildPathDir.mkpath(dirPath);

                    QStringList args;

                    args << fixSeparators(buildPath + "/bin/qmake");
                    args << sourcePath + "/" + dirPath + projectName;
                    args << dictionary[ "QMAKE_ALL_ARGS" ];

                    cout << "For " << qPrintable(dirPath + projectName) << endl;
                    args << "-o";
                    args << it->target;
                    args << "-spec";
                    args << spec;
                    if (!dictionary[ "QMAKEADDITIONALARGS" ].isEmpty())
                        args << dictionary[ "QMAKEADDITIONALARGS" ];

                    QDir::setCurrent(fixSeparators(dirPath));

                    QFile file(makefileName);
                    if (!file.open(QFile::WriteOnly)) {
                        printf("failed on dirPath=%s, makefile=%s\n",
                            qPrintable(dirPath), qPrintable(makefileName));
                        continue;
                    }
                    QTextStream txt(&file);
                    txt << "all:\n";
                    txt << "\t" << args.join(" ") << "\n";
                    txt << "\t\"$(MAKE)\" -$(MAKEFLAGS) -f " << it->target << "\n";
                    txt << "first: all\n";
                    txt << "qmake:\n";
                    txt << "\t" << args.join(" ") << "\n";
                }
            }
        }
        QDir::setCurrent(pwd);
    } else {
        cout << "Processing of project files have been disabled." << endl;
        cout << "Only use this option if you really know what you're doing." << endl << endl;
        return;
    }
}

void Configure::showSummary()
{
    QString make = dictionary[ "MAKE" ];
    if (!dictionary.contains("XQMAKESPEC")) {
        cout << endl << endl << "Qt is now configured for building. Just run " << qPrintable(make) << "." << endl;
        cout << "To reconfigure, run " << qPrintable(make) << " confclean and configure." << endl << endl;
    } else if (dictionary.value("QMAKESPEC").startsWith("wince")) {
        // we are cross compiling for Windows CE
        cout << endl << endl << "Qt is now configured for building. To start the build run:" << endl
             << "\tsetcepaths " << dictionary.value("XQMAKESPEC") << endl
             << "\t" << qPrintable(make) << endl
             << "To reconfigure, run " << qPrintable(make) << " confclean and configure." << endl << endl;
    } else { // Compiling for Symbian OS
        cout << endl << endl << "Qt is now configured for building. To start the build run:" << qPrintable(dictionary["QTBUILDINSTRUCTION"]) << "." << endl
        << "To reconfigure, run '" << qPrintable(dictionary["CONFCLEANINSTRUCTION"]) << "' and configure." << endl;
    }
}

Configure::ProjectType Configure::projectType(const QString& proFileName)
{
    QFile proFile(proFileName);
    if (proFile.open(QFile::ReadOnly)) {
        QString buffer = proFile.readLine(1024);
        while (!buffer.isEmpty()) {
            QStringList segments = buffer.split(QRegExp("\\s"));
            QStringList::Iterator it = segments.begin();

            if (segments.size() >= 3) {
                QString keyword = (*it++);
                QString operation = (*it++);
                QString value = (*it++);

                if (keyword == "TEMPLATE") {
                    if (value == "lib")
                        return Lib;
                    else if (value == "subdirs")
                        return Subdirs;
                }
            }
            // read next line
            buffer = proFile.readLine(1024);
        }
        proFile.close();
    }
    // Default to app handling
    return App;
}

#if !defined(EVAL)

bool Configure::showLicense(QString orgLicenseFile)
{
    if (dictionary["LICENSE_CONFIRMED"] == "yes") {
        cout << "You have already accepted the terms of the license." << endl << endl;
        return true;
    }

    bool haveGpl3 = false;
    QString licenseFile = orgLicenseFile;
    QString theLicense;
    if (dictionary["EDITION"] == "OpenSource" || dictionary["EDITION"] == "Snapshot") {
        haveGpl3 = QFile::exists(orgLicenseFile + "/LICENSE.GPL3");
        theLicense = "GNU Lesser General Public License (LGPL) version 2.1";
        if (haveGpl3)
            theLicense += "\nor the GNU General Public License (GPL) version 3";
    } else {
        // the first line of the license file tells us which license it is
        QFile file(licenseFile);
        if (!file.open(QFile::ReadOnly)) {
            cout << "Failed to load LICENSE file" << endl;
            return false;
        }
        theLicense = file.readLine().trimmed();
    }

    forever {
        char accept = '?';
        cout << "You are licensed to use this software under the terms of" << endl
             << "the " << theLicense << "." << endl
             << endl;
        if (dictionary["EDITION"] == "OpenSource" || dictionary["EDITION"] == "Snapshot") {
            if (haveGpl3)
                cout << "Type '3' to view the GNU General Public License version 3 (GPLv3)." << endl;
            cout << "Type 'L' to view the Lesser GNU General Public License version 2.1 (LGPLv2.1)." << endl;
        } else {
            cout << "Type '?' to view the " << theLicense << "." << endl;
        }
        cout << "Type 'y' to accept this license offer." << endl
             << "Type 'n' to decline this license offer." << endl
             << endl
             << "Do you accept the terms of the license?" << endl;
        cin >> accept;
        accept = tolower(accept);

        if (accept == 'y') {
            return true;
        } else if (accept == 'n') {
            return false;
        } else {
            if (dictionary["EDITION"] == "OpenSource" || dictionary["EDITION"] == "Snapshot") {
                if (accept == '3')
                    licenseFile = orgLicenseFile + "/LICENSE.GPL3";
                else
                    licenseFile = orgLicenseFile + "/LICENSE.LGPL";
            }
            // Get console line height, to fill the screen properly
            int i = 0, screenHeight = 25; // default
            CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
            HANDLE stdOut = GetStdHandle(STD_OUTPUT_HANDLE);
            if (GetConsoleScreenBufferInfo(stdOut, &consoleInfo))
                screenHeight = consoleInfo.srWindow.Bottom
                             - consoleInfo.srWindow.Top
                             - 1; // Some overlap for context

            // Prompt the license content to the user
            QFile file(licenseFile);
            if (!file.open(QFile::ReadOnly)) {
                cout << "Failed to load LICENSE file" << licenseFile << endl;
                return false;
            }
            QStringList licenseContent = QString(file.readAll()).split('\n');
            while (i < licenseContent.size()) {
                cout << licenseContent.at(i) << endl;
                if (++i % screenHeight == 0) {
                    cout << "(Press any key for more..)";
                    if (_getch() == 3) // _Any_ keypress w/no echo(eat <Enter> for stdout)
                        exit(0);      // Exit cleanly for Ctrl+C
                    cout << "\r";     // Overwrite text above
                }
            }
        }
    }
}

void Configure::readLicense()
{
    dictionary["PLATFORM NAME"] = platformName();
    dictionary["LICENSE FILE"] = sourcePath;

    bool openSource = false;
    bool hasOpenSource = QFile::exists(dictionary["LICENSE FILE"] + "/LICENSE.GPL3") || QFile::exists(dictionary["LICENSE FILE"] + "/LICENSE.LGPL");
    if (dictionary["BUILDNOKIA"] == "yes" || dictionary["BUILDTYPE"] == "commercial") {
        openSource = false;
    } else if (dictionary["BUILDTYPE"] == "opensource") {
        openSource = true;
    } else if (hasOpenSource) { // No Open Source? Just display the commercial license right away
        forever {
            char accept = '?';
            cout << "Which edition of Qt do you want to use ?" << endl;
            cout << "Type 'c' if you want to use the Commercial Edition." << endl;
            cout << "Type 'o' if you want to use the Open Source Edition." << endl;
            cin >> accept;
            accept = tolower(accept);

            if (accept == 'c') {
                openSource = false;
                break;
            } else if (accept == 'o') {
                openSource = true;
                break;
            }
        }
    }
    if (hasOpenSource && openSource) {
        cout << endl << "This is the " << dictionary["PLATFORM NAME"] << " Open Source Edition." << endl;
        licenseInfo["LICENSEE"] = "Open Source";
        dictionary["EDITION"] = "OpenSource";
        dictionary["QT_EDITION"] = "QT_EDITION_OPENSOURCE";
        cout << endl;
        if (!showLicense(dictionary["LICENSE FILE"])) {
            cout << "Configuration aborted since license was not accepted";
            dictionary["DONE"] = "error";
            return;
        }
    } else if (openSource) {
        cout << endl << "Cannot find the GPL license files! Please download the Open Source version of the library." << endl;
        dictionary["DONE"] = "error";
    }
#ifdef COMMERCIAL_VERSION
    else {
        Tools::checkLicense(dictionary, licenseInfo, firstLicensePath());
        if (dictionary["DONE"] != "error" && dictionary["BUILDNOKIA"] != "yes") {
            // give the user some feedback, and prompt for license acceptance
            cout << endl << "This is the " << dictionary["PLATFORM NAME"] << " " << dictionary["EDITION"] << " Edition."<< endl << endl;
            if (!showLicense(dictionary["LICENSE FILE"])) {
                cout << "Configuration aborted since license was not accepted";
                dictionary["DONE"] = "error";
                return;
            }
        }
    }
#else // !COMMERCIAL_VERSION
    else {
        cout << endl << "Cannot build commercial edition from the open source version of the library." << endl;
        dictionary["DONE"] = "error";
    }
#endif
}

void Configure::reloadCmdLine()
{
    if (dictionary[ "REDO" ] == "yes") {
        QFile inFile(buildPath + "/configure" + dictionary[ "CUSTOMCONFIG" ] + ".cache");
        if (inFile.open(QFile::ReadOnly)) {
            QTextStream inStream(&inFile);
            QString buffer;
            inStream >> buffer;
            while (buffer.length()) {
                configCmdLine += buffer;
                inStream >> buffer;
            }
            inFile.close();
        }
    }
}

void Configure::saveCmdLine()
{
    if (dictionary[ "REDO" ] != "yes") {
        QFile outFile(buildPath + "/configure" + dictionary[ "CUSTOMCONFIG" ] + ".cache");
        if (outFile.open(QFile::WriteOnly | QFile::Text)) {
            QTextStream outStream(&outFile);
            for (QStringList::Iterator it = configCmdLine.begin(); it != configCmdLine.end(); ++it) {
                outStream << (*it) << " " << endl;
            }
            outStream.flush();
            outFile.close();
        }
    }
}
#endif // !EVAL

bool Configure::compilerSupportsFlag(const QStringList &compilerAndArgs)
{
    QFile file("conftest.cpp");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        cout << "could not open temp file for writing" << endl;
        return false;
    }
    if (!file.write("int main() { return 0; }\r\n")) {
        cout << "could not write to temp file" << endl;
        return false;
    }
    file.close();
    // compilerAndArgs contains compiler because there is no way to query it
    QStringList command = compilerAndArgs;
    command += "-o";
    command += "conftest-out.o";
    command += "conftest.cpp";
    int code = Environment::execute(command, QStringList(), QStringList());
    file.remove();
    QFile::remove("conftest-out.o");
    return code == 0;
}

bool Configure::isDone()
{
    return !dictionary["DONE"].isEmpty();
}

bool Configure::isOk()
{
    return (dictionary[ "DONE" ] != "error");
}

QString Configure::platformName() const
{
    switch (platform()) {
    default:
    case WINDOWS:
        return QLatin1String("Qt for Windows");
    case WINDOWS_CE:
        return QLatin1String("Qt for Windows CE");
    case QNX:
        return QLatin1String("Qt for QNX");
    case BLACKBERRY:
        return QLatin1String("Qt for Blackberry");
    case SYMBIAN:
        return QLatin1String("Qt for Symbian");
    }
}

QString Configure::qpaPlatformName() const
{
    switch (platform()) {
    default:
    case WINDOWS:
    case WINDOWS_CE:
        return QLatin1String("windows");
    case QNX:
        return QLatin1String("qnx");
    case BLACKBERRY:
        return QLatin1String("blackberry");
    }
}

int Configure::platform() const
{
    const QString qMakeSpec = dictionary.value("QMAKESPEC");
    const QString xQMakeSpec = dictionary.value("XQMAKESPEC");

    if ((qMakeSpec.startsWith("wince") || xQMakeSpec.startsWith("wince")))
        return WINDOWS_CE;

    if (xQMakeSpec.contains("qnx"))
        return QNX;

    if (xQMakeSpec.contains("blackberry"))
        return BLACKBERRY;

    if (xQMakeSpec.startsWith("symbian"))
        return SYMBIAN;

    return WINDOWS;
}

bool
Configure::filesDiffer(const QString &fn1, const QString &fn2)
{
    QFile file1(fn1), file2(fn2);
    if (!file1.open(QFile::ReadOnly) || !file2.open(QFile::ReadOnly))
        return true;
    const int chunk = 2048;
    int used1 = 0, used2 = 0;
    char b1[chunk], b2[chunk];
    while (!file1.atEnd() && !file2.atEnd()) {
        if (!used1)
            used1 = file1.read(b1, chunk);
        if (!used2)
            used2 = file2.read(b2, chunk);
        if (used1 > 0 && used2 > 0) {
            const int cmp = qMin(used1, used2);
            if (memcmp(b1, b2, cmp))
                return true;
            if ((used1 -= cmp))
                memcpy(b1, b1+cmp, used1);
            if ((used2 -= cmp))
                memcpy(b2, b2+cmp, used2);
        }
    }
    return !file1.atEnd() || !file2.atEnd();
}

QT_END_NAMESPACE
