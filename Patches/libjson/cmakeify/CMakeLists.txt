cmake_minimum_required(VERSION 2.8)
project(libjson)

# Setup build directories
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${libjson_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${libjson_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${libjson_BINARY_DIR}/bin)
endif()

set(libjson_VERSION_MAJOR 7)
set(libjson_VERSION_MINOR 6)
set(libjson_VERSION_PATCH 1)
set(libjson_VERSION "${libjson_VERSION_MAJOR}.${libjson_VERSION_MINOR}.${libjson_VERSION_PATCH}")


option(BUILD_SHARED_LIBS False "Build stared libraries instead of static")

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

set(JSON_LIBNAME "json" CACHE STRING "Name of the installation library")

# Pre-load some compiler flags
include(${libjson_SOURCE_DIR}/CompilerFlags.cmake)

# Configure the options header
include(${libjson_SOURCE_DIR}/JSONOptions.cmake)

configure_file(
  ${libjson_SOURCE_DIR}/JSONOptions.h.in
  ${libjson_SOURCE_DIR}/JSONOptions.h
)
configure_file(
  ${libjson_SOURCE_DIR}/libjson.h
  ${libjson_BINARY_DIR}/${JSON_LIBNAME}.h
  COPYONLY
)
install(FILES
  ${libjson_BINARY_DIR}/${JSON_LIBNAME}.h
  ${libjson_SOURCE_DIR}/JSONOptions.h
  DESTINATION include/${JSON_LIBNAME}
)
install(DIRECTORY _internal/Dependencies DESTINATION include/${JSON_LIBNAME})

include_directories(${libjson_BINARY_DIR})
add_subdirectory(_internal/Source)
