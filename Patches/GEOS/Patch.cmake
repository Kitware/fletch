#+
# This file is called as CMake -P script for the patch step of
# External_GEOS.cmake.
# GEOS_patch and GEOS_source are defined on the command line along with the
# call.
#-
message("Patching geos")

# This patch removes the GEOS doc directory
# since it references tests which are disabled
file(COPY ${GEOS_patch}/CMakeLists.txt DESTINATION ${GEOS_source}/)
