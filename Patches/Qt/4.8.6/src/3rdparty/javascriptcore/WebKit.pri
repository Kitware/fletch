# Include file to make it easy to include WebKit into Qt projects

# Detect that we are building as a standalone package by the presence of
# either the generated files directory or as part of the Qt package through
# QTDIR_build
CONFIG(QTDIR_build): CONFIG += standalone_package
else:exists($$PWD/WebCore/generated): CONFIG += standalone_package

CONFIG(standalone_package) {
    OUTPUT_DIR=$$PWD
}

CONFIG += depend_includepath

isEmpty(OUTPUT_DIR) {
    CONFIG(debug, debug|release) {
        OUTPUT_DIR=$$PWD/WebKitBuild/Debug
    } else { # Release
        OUTPUT_DIR=$$PWD/WebKitBuild/Release
    }
}

DEFINES += BUILDING_QT__=1
building-libs {
    win32-msvc200*|win32-msvc2010*|win32-msvc2012*|win32-icc: INCLUDEPATH += $$PWD/JavaScriptCore/os-win32
} else {
    CONFIG(QTDIR_build) {
        QT += webkit
    } else {
        QMAKE_LIBDIR = $$OUTPUT_DIR/lib $$QMAKE_LIBDIR
        QTWEBKITLIBNAME = QtWebKit
        mac:!static:contains(QT_CONFIG, qt_framework):!CONFIG(webkit_no_framework) {
            LIBS += -framework $$QTWEBKITLIBNAME
            QMAKE_FRAMEWORKPATH = $$OUTPUT_DIR/lib $$QMAKE_FRAMEWORKPATH
        } else {
            win32-*|wince* {
                CONFIG(debug, debug|release):build_pass: QTWEBKITLIBNAME = $${QTWEBKITLIBNAME}d
                QTWEBKITLIBNAME = $${QTWEBKITLIBNAME}$${QT_MAJOR_VERSION}
                win32-g++*: LIBS += -l$$QTWEBKITLIBNAME
                else: LIBS += $${QTWEBKITLIBNAME}.lib
            } else {
                LIBS += -lQtWebKit
                symbian {
                    TARGET.EPOCSTACKSIZE = 0x14000 // 80 kB
                    TARGET.EPOCHEAPSIZE = 0x20000 0x2000000 // Min 128kB, Max 32MB
                }
            }
        }
    }
    DEPENDPATH += $$PWD/WebKit/qt/Api
}
greaterThan(QT_MINOR_VERSION, 5):DEFINES += WTF_USE_ACCELERATED_COMPOSITING

!mac:!unix|symbian {
    DEFINES += USE_SYSTEM_MALLOC
}

CONFIG(release, debug|release) {
    DEFINES += NDEBUG
}

BASE_DIR = $$PWD
INCLUDEPATH += $$PWD/WebKit/qt/Api

CONFIG -= warn_on
*-g++*:QMAKE_CXXFLAGS += -Wall -Wreturn-type -fno-strict-aliasing -Wcast-align -Wchar-subscripts -Wformat-security -Wreturn-type -Wno-unused-parameter -Wno-sign-compare -Wno-switch -Wno-switch-enum -Wundef -Wmissing-noreturn -Winit-self

# Enable GNU compiler extensions to the ARM compiler for all Qt ports using RVCT
symbian|*-armcc {
    RVCT_COMMON_CFLAGS = --gnu --diag_suppress 68,111,177,368,830,1293
    RVCT_COMMON_CXXFLAGS = $$RVCT_COMMON_CFLAGS --no_parse_templates
}

*-armcc {
    QMAKE_CFLAGS += $$RVCT_COMMON_CFLAGS
    QMAKE_CXXFLAGS += $$RVCT_COMMON_CXXFLAGS
}

symbian {
    QMAKE_CXXFLAGS.ARMCC += $$RVCT_COMMON_CXXFLAGS
}

symbian|maemo5: DEFINES *= QT_NO_UITOOLS

contains(DEFINES, QT_NO_UITOOLS): CONFIG -= uitools

# Disable a few warnings on Windows. The warnings are also
# disabled in WebKitLibraries/win/tools/vsprops/common.vsprops
win32-msvc*: QMAKE_CXXFLAGS += -wd4291 -wd4344 -wd4396 -wd4503 -wd4800 -wd4819 -wd4996

