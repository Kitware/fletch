#+
# This file is called as CMake -P script for the patch step of
# External_SQLite.cmake
#
# SQLite_patch and SQLite_source are defined on the command line along with
# the call. Essentially, we're just copying a CMake based build into the 
# SQLite source tree
#-

file(COPY 
  ${SQLite_patch}/CMakeLists.txt
  ${SQLite_patch}/SQLiteConfig.cmake.in
  ${SQLite_patch}/SQLiteConfigVersion.cmake.in
  ${SQLite_patch}/sqlite3.def
  DESTINATION ${SQLite_source}
)
