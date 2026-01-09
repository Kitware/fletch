#+
# This file is called as CMake -P script for the patch step of
# External_PROJ.cmake PROJ_PATCH and PROJ_SOURCE are defined
# on the command line along with the call.
#-

configure_file(
  ${PROJ_PATCH}/proj_json_streaming_writer.hpp
  ${PROJ_SOURCE}/src/
  COPYONLY
)
