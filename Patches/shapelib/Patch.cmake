#+
# This file is called as CMake -P script for the patch step of
# External_shapelib.cmake.
# TinyXML_patch and TinyXML_source are defined on the command line along with
# the call.
#-

message("Patching shapelib")
file(COPY ${shapelib_patch}/CMakeLists.txt DESTINATION ${shapelib_source})
#file(COPY ${shapelib_patch}/SHAPELIBConfig.cmake.in DESTINATION ${shapelib_source})
#file(COPY ${shapelib_patch}/shapefil.h DESTINATION ${shapelib_source})
