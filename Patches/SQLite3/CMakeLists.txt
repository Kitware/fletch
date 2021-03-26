project ( SQLite3 )
cmake_minimum_required(VERSION 2.8)

# Build output paths
if( NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY )
  set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/lib )
endif()
if( NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY )
  set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/lib )
endif()
if( NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY )
  set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/bin )
endif()

# Default to building shared
option(BUILD_SHARED_LIBS "Build with shared libraries." OFF)

# We need -fPIC when building statically
if( UNIX AND NOT BUILD_SHARED_LIBS)
  set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)
endif()

# Determine the SQLite3 version getting built
file( READ sqlite3.h SQLite3_INCLUDE_FILE )
string( REGEX REPLACE
  ".*# *define *SQLITE_VERSION *\\\"([0-9\\.]+)\\\".*" "\\1"
  SQLite3_VERSION "${SQLite3_INCLUDE_FILE}"
)

option(SQLite3_ENABLE_THREADSAFE "Build a thread-safe library" ON)
option(SQLite3_ENABLE_COLUMN_METADATA "Additional APIs that provide convenient
access to meta-data" ON)
option(SQLite3_ENABLE_RTREE "Support for R*Tree indexes" ON)
option(SQLite3_ENABLE_LOAD_EXTENSIONS "Support loadable extensions" ON)
option(SQLite3_ENABLE_EXECUTABLE "Build the sqlite (static) executable" OFF)

if(SQLite3_ENABLE_THREADSAFE)
  add_definitions(-DSQLITE_THREADSAFE=1)
  find_package(Threads REQUIRED )
endif()
if(SQLite3_ENABLE_COLUMN_METADATA)
  add_definitions(-DSQLITE_ENABLE_COLUMN_METADATA=1)
endif()
if(SQLite3_ENABLE_RTREE)
  add_definitions(-DSQLITE_ENABLE_RTREE=1)
endif()
if(SQLite3_ENABLE_LOAD_EXTENSIONS)
  add_definitions(-DSQLITE_ENABLE_LOAD_EXTENSION=1)
else()
  add_definitions(-DSQLITE_OMIT_LOAD_EXTENSION=1)
endif()

set(sqlite_sources
    sqlite3.c
    sqlite3.h
    sqlite3ext.h
    sqlite3.def
)
add_library(sqlite3 ${sqlite_sources} )

target_link_libraries( sqlite3 ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})
set_target_properties( sqlite3 PROPERTIES
  VERSION ${SQLite3_VERSION} SOVERSION ${SQLite3_VERSION}
)
list(APPEND SQLite3_TARGETS sqlite3)
if(SQLite3_ENABLE_EXECUTABLE)
  set(BUILD_SHARED_LIBS OFF) # The sqlite_exe is always build statically
  add_executable(sqlite3_exe ${sqlite_sources} shell.c sqlite3.def)
  target_link_libraries(sqlite3_exe ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})
  list(APPEND SQLite3_TARGETS sqlite3_exe)
endif()

install(TARGETS ${SQLite3_TARGETS}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY . DESTINATION include FILES_MATCHING PATTERN "*.h" )

# Configure the module config
configure_file(
  "${SQLite3_SOURCE_DIR}/SQLite3Config.cmake.in"
  "SQLite3Config.cmake"
)
configure_file(
  "${SQLite3_SOURCE_DIR}/SQLite3ConfigVersion.cmake.in"
  "SQLite3ConfigVersion.cmake"
)

install( FILES
  ${SQLite3_BINARY_DIR}/SQLite3Config.cmake
  ${SQLite3_BINARY_DIR}/SQLite3ConfigVersion.cmake
  DESTINATION
  share/cmake )
