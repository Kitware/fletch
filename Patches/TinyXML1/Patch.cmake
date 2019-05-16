#+
# This file is called as CMake -P script for the patch step of
# External_TinyXML1.cmake.
# TinyXML_patch and TinyXML_source are defined on the command line along with
# the call.
#-

message("Patching TinyXML1")
file(COPY ${TinyXML1_patch}/CMakeLists.txt DESTINATION ${TinyXML1_source})
