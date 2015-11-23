#+
# This file is called as CMake -P script for the patch step of
# External_SuiteSparse.cmake.  It fixes the CMakeLists.txt to use find modules
#-

file(COPY ${SuiteSparse_patch}/CMakeLists.txt
  DESTINATION ${SuiteSparse_source}
)
