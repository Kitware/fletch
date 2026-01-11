#+
# This file is called as CMake -P script for the patch step of
# External_CppDB.cmake.  It fixes the CMakeLists.txt to use find modules
# and updates headers/sources for C++17 compatibility (auto_ptr -> unique_ptr)
#-
file(COPY ${CppDB_patch}/CMakeLists.txt ${CppDB_patch}/FindSQLite.cmake
  DESTINATION ${CppDB_source}
)

# Copy patched headers for C++17 compatibility (std::auto_ptr -> std::unique_ptr)
file(COPY
  ${CppDB_patch}/cppdb/frontend.h
  ${CppDB_patch}/cppdb/backend.h
  ${CppDB_patch}/cppdb/connection_specific.h
  ${CppDB_patch}/cppdb/conn_manager.h
  ${CppDB_patch}/cppdb/pool.h
  DESTINATION ${CppDB_source}/cppdb
)

# Copy patched source files for C++17 compatibility (std::auto_ptr -> std::unique_ptr)
file(COPY
  ${CppDB_patch}/src/backend.cpp
  ${CppDB_patch}/src/pool.cpp
  DESTINATION ${CppDB_source}/src
)
