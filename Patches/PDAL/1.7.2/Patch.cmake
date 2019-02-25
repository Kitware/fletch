#+
# This file is called as CMake -P script for the patch step of
# External_PDAL.cmake when building with PDAL 2.7.2
#-

message("Patching PDAL in ${PDAL_source}")


# Disable finding OSGeo4W64 because it conflicts with other Fletch libs
file(COPY ${PDAL_patch}/win32_compiler_options.cmake
  DESTINATION ${PDAL_source}/cmake
)

# LIBXML2 is supposed to be optional, but the CMake code to remove it is broken
file(COPY ${PDAL_patch}/CMakeLists.txt
  DESTINATION ${PDAL_source}/
)

