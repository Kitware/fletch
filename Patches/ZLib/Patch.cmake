#+
# This file is called as CMake -P script for the patch step of
# External_Zlib.cmake
#-

file(COPY ${zlib_patch}/CMakeLists.txt	DESTINATION ${zlib_source})
