#+
# This file is called as CMake -P script for the patch step of
# External_CppDB.cmake.  It fixes the CMakeLists.txt to use find modules
#-
file(COPY ${CppDB_patch}/CMakeLists.txt ${CppDB_patch}/FindSQLite.cmake
  DESTINATION ${CppDB_source}
)

file(COPY ${CppDB_patch}/cppdb/frontend.h
  DESTINATION ${CppDB_source}/cppdb
)
