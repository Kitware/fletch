#+
# This file is called as CMake -P script for the patch step of
# External_GEOS.cmake.
# GEOS_patch and GEOS_source are defined on the command line along with the
# call.
#-
message("Patching geos")

file(COPY ${GEOS_patch}/capi/CMakeLists.txt DESTINATION ${GEOS_source}/capi)
file(COPY ${GEOS_patch}/src/CMakeLists.txt DESTINATION ${GEOS_source}/src)
