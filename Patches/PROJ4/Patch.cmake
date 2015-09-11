#+
# This file is called as CMake -P script for the patch step of
# External_PROJ4.cmake PROJ4_patch and PROJ4_source are defined on the command
# line along with the call.
#-

message("Patching PROJ4 ${PROJ4_patch} AND ${PROJ4_source}")
configure_file(
  ${PROJ4_patch}/CMakeLists.txt
  ${PROJ4_source}/CMakeLists.txt
  COPYONLY
)

configure_file(
  ${PROJ4_patch}/proj_config.h
  ${PROJ4_source}/src/proj4_config.h
  COPYONLY
)

configure_file(
  ${PROJ4_patch}/jniproj.c
  ${PROJ4_source}/src/jniproj.c
  COPYONLY
)
