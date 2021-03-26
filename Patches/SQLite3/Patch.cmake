#+
# This file is called as CMake -P script for the patch step of
# External_SQLite3.cmake
#
# SQLite3_patch and SQLite3_source are defined on the command line along with
# the call. Essentially, we're just copying a CMake based build into the
# SQLite3 source tree
#-

file(COPY
  ${SQLite3_patch}/CMakeLists.txt
  ${SQLite3_patch}/SQLite3Config.cmake.in
  ${SQLite3_patch}/SQLite3ConfigVersion.cmake.in
  ${SQLite3_patch}/sqlite3.def
  DESTINATION ${SQLite3_source}
)
