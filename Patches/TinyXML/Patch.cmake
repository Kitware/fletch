#+
# This file is called as CMake -P script for the patch step of
# External_TinyXML.cmake.
# TinyXML_patch and TinyXML_source are defined on the command line along with
# the call.
#-

message("Patching TinyXML")
file(COPY ${TinyXML_patch}/CMakeLists.txt DESTINATION ${TinyXML_source})

if(WIN32)
  file(COPY ${TinyXML_patch}/tinyxml.h DESTINATION ${TinyXML_source})
endif()
