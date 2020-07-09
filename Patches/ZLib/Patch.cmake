#+
# This file is called as CMake -P script for the patch step of
# External_Zlib.cmake
#-

file(COPY ${ZLib_patch}/CMakeLists.txt	DESTINATION ${ZLib_source})
