#+
# This file is called as CMake -P script for the patch step of
# External_GeographicLib.cmake.  It fixes non-ascii characters in pod file
#-
file(COPY ${GeographicLib_patch}/MagneticField.pod
  DESTINATION ${GeographicLib_source}/man
)
file(COPY ${GeographicLib_patch}/CMakeLists.txt
  DESTINATION ${GeographicLib_source}
)
file(COPY ${GeographicLib_patch}/cmake/CMakeLists.txt
  DESTINATION ${GeographicLib_source}/cmake
)
file(COPY ${GeographicLib_patch}/src/CMakeLists.txt
  DESTINATION ${GeographicLib_source}/src
)
