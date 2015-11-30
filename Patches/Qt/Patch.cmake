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

# As a workaround for Windows, pre-copy the mkspec files to allow the
# make install step to work
file(COPY ${Qt_source}/mkspecs DESTINATION ${Qt_install}/lib/qt4)

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
