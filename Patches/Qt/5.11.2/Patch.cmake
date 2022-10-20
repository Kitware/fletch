#+
# This file is called as CMake -P script for the patch step of
# External_Qt.cmake
#-

message("Patching Qt in ${Qt_source}")

# Add a special gcc44 mkspec for RHEL5
file(COPY ${Qt_patch}/qtconnectivity/src/bluetooth/qbluetoothservicediscoveryagent_winrt.cpp
  DESTINATION ${Qt_source}/qtconnectivity/src/bluetooth/
  )

# Qt asm declaration broken on gcc gcc 8.3
file(COPY ${Qt_patch}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/jit/JITStubs.cpp
  DESTINATION ${Qt_source}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/jit/
  )

# Fix build issue on Mac
file(RENAME ${Qt_source}/qtscript/src/3rdparty/javascriptcore/VERSION
  ${Qt_source}/qtscript/src/3rdparty/javascriptcore/VERSION.txt
  )

# Patch for gcc 9.1.
file(COPY ${Qt_patch}/qtbase/src/corelib/global/qrandom.cpp
  DESTINATION ${Qt_source}/qtbase/src/corelib/global/
  )


# Patch for gcc 9.1 and updated kernel headers.
if (NOT WIN32)
  file(COPY ${Qt_patch}/qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp
    DESTINATION ${Qt_source}/qtserialbus/src/plugins/canbus/socketcan/
    )
endif()

# Fix a build issues with gcc 11. Headers need to include <limits>
file(COPY ${Qt_patch}/qtbase/src/corelib/tools/qbytearraymatcher.h
  DESTINATION ${Qt_source}/qtbase/src/corelib/tools/
  )

# Fix a build issues on Mac.
# Can't use futimens on MacOS < 10.3 which is controlled by
# the QMAKE_MACOSX_DEPLOYMENT_TARGET value in qmake.conf
# not by the actual system version.
if (APPLE)
  file(COPY ${Qt_patch}/qtbase/mkspecs/macx-clang/qmake.conf
    DESTINATION ${Qt_source}/qtbase/mkspecs/macx-clang/
    )
endif()
