project ( SQLite3 )
cmake_minimum_required(VERSION 3.5)

include(GNUInstallDirs)

# Build output paths
if( NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY )
  set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR} )
endif()
if( NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY )
  set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR} )
endif()
if( NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY )
  set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SQLite3_BINARY_DIR}/${CMAKE_INSTALL_BINDIR} )
endif()

# Default to building shared
option(BUILD_SHARED_LIBS "Build with shared libraries." OFF)

# We need -fPIC when building statically. May as well always have it.
set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)

# Determine the SQLite3 version getting built
file( READ sqlite3.h SQLite3_INCLUDE_FILE )
string( REGEX REPLACE
  ".*# *define *SQLITE_VERSION *\\\"([0-9\\.]+)\\\".*" "\\1"
  SQLite3_VERSION "${SQLite3_INCLUDE_FILE}"
)

option(SQLite3_ENABLE_THREADSAFE "Build a thread-safe library" ON)
option(SQLite3_ENABLE_COLUMN_METADATA "Additional APIs that provide convenient access to meta-data" ON)
option(SQLite3_ENABLE_RTREE "Support for R*Tree indexes" ON)
option(SQLite3_ENABLE_LOAD_EXTENSIONS "Support loadable extensions" ON)
option(SQLite3_ENABLE_EXECUTABLE "Build the sqlite (static) executable" OFF)
option(SQLite3_ENABLE_DESERIALIZE "sqlite3_serialize / sqlite3_deserialize" ON)
option(SQLite3_ENABLE_FTS "Full-text search (FTS3/4/5)" ON)
option(SQLite3_ENABLE_JSON "JSON1 functions" ON)

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
# Python's _sqlite3 extension links sqlite3_serialize, so a library built
# without this cannot satisfy it and "import sqlite3" fails at load time.
if(SQLite3_ENABLE_DESERIALIZE)
  add_definitions(-DSQLITE_ENABLE_DESERIALIZE=1)
endif()
if(SQLite3_ENABLE_FTS)
  add_definitions(-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS4=1
                  -DSQLITE_ENABLE_FTS5=1)
endif()
if(SQLite3_ENABLE_JSON)
  add_definitions(-DSQLITE_ENABLE_JSON1=1)
endif()

set(sqlite_sources
    sqlite3.c
    sqlite3.h
    sqlite3ext.h
)
add_library(sqlite3 ${sqlite_sources} )

# Export the whole public API on Windows.
#
# This build used to hand the linker a vendored sqlite3.def whose export list
# stopped being updated long before the 3.35 source it was applied to: 192
# symbols, missing sqlite3_close_v2, sqlite3_trace_v2, sqlite3_serialize,
# sqlite3_create_window_function and some eighty more. Python's _sqlite3
# extension imports several of them, so every Windows install failed
# "import sqlite3" with STATUS_ENTRYPOINT_NOT_FOUND (0xc0000139), which in turn
# broke anything reaching huggingface_hub or transformers. Defining SQLITE_API
# as dllexport is SQLite's own documented way to build the DLL, and cannot go
# stale as the vendored version moves.
if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(sqlite3
    PRIVATE "SQLITE_API=__declspec(dllexport)")
endif()

target_link_libraries( sqlite3 ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})
set_target_properties( sqlite3 PROPERTIES
  VERSION ${SQLite3_VERSION} SOVERSION ${SQLite3_VERSION}
)
list(APPEND SQLite3_TARGETS sqlite3)
if(SQLite3_ENABLE_EXECUTABLE)
  add_executable(sqlite3_exe ${sqlite_sources} shell.c)
  target_link_libraries(sqlite3_exe ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})
  list(APPEND SQLite3_TARGETS sqlite3_exe)
endif()

install(TARGETS ${SQLite3_TARGETS}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY . DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} FILES_MATCHING PATTERN "*.h" )

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
