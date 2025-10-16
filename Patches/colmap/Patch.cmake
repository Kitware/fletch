#+
# This file is called as CMake -P script for the patch step of
# External_colmap to fix linking to FreeImage
#


file(COPY ${colmap_patch}/CMakeLists.txt
  DESTINATION ${colmap_source}/src/colmap/sensor/
  )
