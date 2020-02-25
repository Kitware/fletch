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
