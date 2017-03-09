#+
# This file is called as CMake -P script for the patch step of
# External_Qt.cmake
#-

message("Patching Qt in ${Qt_source}")

# Add a special gcc44 mkspec for RHEL5
file(COPY ${Qt_patch}/linux-g++44
  DESTINATION ${Qt_source}/mkspecs
)

# Currently disabled as it seems to generate illegal opcodes with gcc44 on
# SandyBridge CPUs and RHEL5
# Allow *nix qmake to consume the CFLAGS and CXXFLAGS environment variables
#configure_file(
#  ${Qt_patch}/common/unix.conf
#  ${Qt_source}/mkspecs/common/unix.conf
#  @ONLY
#)

# Patch the configure script:
# A bug in the configure script will currently falsely generate unsupported instructions
# for the CPU.  The configure checks only test to see if the compiler supports the
# instructions but not if the underlying CPU actually supportes them.  This patch will
# rely on the underlying compiler flags to be set properly by the mkspec file
file(COPY ${Qt_patch}/configure DESTINATION ${Qt_source})


# Copy over the mac related patch

# gui/dialogs
file(COPY
  ${Qt_patch}/gui/dialogs/qcolordialog_mac.mm
  ${Qt_patch}/gui/dialogs/qfiledialog_mac.mm
  ${Qt_patch}/gui/dialogs/qfontdialog_mac.mm
  DESTINATION ${Qt_source}/src/gui/dialogs
  )

# gui/painting
file(COPY
  ${Qt_patch}/gui/painting/qpaintengine_mac.cpp
  DESTINATION ${Qt_source}/src/gui/painting
  )

# gui/kernel
file(COPY
  ${Qt_patch}/gui/kernel/qapplication_mac.mm
  ${Qt_patch}/gui/kernel/qcocoaapplication_mac.mm
  ${Qt_patch}/gui/kernel/qcocoaapplicationdelegate_mac.mm
  ${Qt_patch}/gui/kernel/qcocoaapplicationdelegate_mac_p.h
  ${Qt_patch}/gui/kernel/qcocoamenuloader_mac.mm
  ${Qt_patch}/gui/kernel/qcocoasharedwindowmethods_mac_p.h
  ${Qt_patch}/gui/kernel/qeventdispatcher_mac.mm
  ${Qt_patch}/gui/kernel/qt_cocoa_helpers_mac.mm
  ${Qt_patch}/gui/kernel/qwidget_mac.mm
  DESTINATION ${Qt_source}/src/gui/kernel
  )

# gui/styles
file(COPY
  ${Qt_patch}/gui/styles/qmacstyle_mac.mm
  DESTINATION ${Qt_source}/src/gui/styles
  )

# gui/util
file(COPY
  ${Qt_patch}/gui/util/qsystemtrayicon_mac.mm
  DESTINATION ${Qt_source}/src/gui/util
  )

# gui/widgets
file(COPY
  ${Qt_patch}/gui/widgets/qcocoamenu_mac.mm
  ${Qt_patch}/gui/widgets/qmenu_mac.mm
  DESTINATION ${Qt_source}/src/gui/widgets
  )

# Workaround to build Qt with c++11
file(COPY ${Qt_source}/src DESTINATION ${Qt_source})

# Fix the build for VS 2015 and 2017
# this patch is a merge of these two patches:
#https://fami.codefreak.ru/mirrors/qt/unofficial_builds/qt4.8.7-msvc2015/02-fix_build_with_msvc2015-45e8f4ee.diff
#https://fami.codefreak.ru/gitlab/peter/qt4/commit/51e706b1899b3e59f7789bf94184643ccfabeebd

set(MSVC_FILES
  configure.exe
  src/3rdparty/clucene/src/CLucene/StdHeader.h
  src/3rdparty/clucene/src/CLucene/util/VoidMap.h
  src/3rdparty/javascriptcore/JavaScriptCore/wtf/StringExtras.h
  src/3rdparty/javascriptcore/JavaScriptCore/wtf/TypeTraits.h
  src/3rdparty/javascriptcore/JavaScriptCore/runtime/ArgList.h
  src/3rdparty/javascriptcore/WebKit.pri
  tools/designer/src/uitools/uitools.pro
  mkspecs/win32-msvc2015/
  mkspecs/win32-msvc2015/qmake.conf
  mkspecs/win32-msvc2015/qplatformdefs.h
  mkspecs/win32-msvc2017/
  mkspecs/win32-msvc2017/qmake.conf
  mkspecs/win32-msvc2017/qplatformdefs.h
  qmake/Makefile.win32
  qmake/generators/win32/msvc_objectmodel.h
  tools/configure/configureapp.cpp
  tools/configure/environment.cpp
  tools/configure/environment.h
)

foreach(f ${MSVC_FILES})
  get_filename_component(dest ${Qt_source}/${f} DIRECTORY)
  message("COPY  ${Qt_patch}/${f}    DESTINATION ${dest}")
  file(COPY ${Qt_patch}/${f} DESTINATION ${dest})
endforeach()


# As a workaround for Windows, pre-copy the mkspec files to allow the
# make install step to work.  This should always be the last step
# in this file, in case things are added to the mkspecs.
file(COPY ${Qt_source}/mkspecs DESTINATION ${Qt_install}/lib/qt4)
