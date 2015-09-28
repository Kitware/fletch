#+
# This file is called as CMake -P script for the patch step of
# External_GeographicLib.cmake.  It fixes non-ascii characters in pod file
#-
file(COPY ${GeographicLib_patch}/MagneticField.pod
  DESTINATION ${GeographicLib_source}/man
)
