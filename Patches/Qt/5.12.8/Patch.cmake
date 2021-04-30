#+
# This file is called as CMake -P script for the patch step of
# External_Qt.cmake
#-

message("Patching Qt in ${Qt_source}")

# Fix a build issues on MSVC
file(COPY ${Qt_patch}/qtconnectivity/src/bluetooth/qbluetoothservicediscoveryagent_winrt.cpp
  DESTINATION ${Qt_source}/qtconnectivity/src/bluetooth/
  )


# Fix a build issues with gcc 11. Headers need to include <limits>
file(COPY ${Qt_patch}/qtbase/src/corelib/tools/qbytearraymatcher.h
  DESTINATION ${Qt_source}/qtbase/src/corelib/tools/
  )

file(COPY ${Qt_patch}/qtbase/src/corelib/global/qendian.h
  DESTINATION ${Qt_source}/qtbase/src/corelib/global/
  )
