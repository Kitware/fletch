cmake_minimum_required(VERSION 2.8.3)
project(TinyXML)

# We need -fPIC when building statically
if( UNIX AND NOT BUILD_SHARED_LIBS)
  set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)
endif()

# Determine the TinyXML version getting built
file(READ tinyxml.h TinyXML_INCLUDE_FILE)
string(REGEX REPLACE
  ".*TIXML_MAJOR_VERSION = ([0-9]+).*" "\\1"
  TinyXML_VERSION_MAJOR "${TinyXML_INCLUDE_FILE}")
string(REGEX REPLACE
  ".*TIXML_MINOR_VERSION = ([0-9]+).*" "\\1"
  TinyXML_VERSION_MINOR "${TinyXML_INCLUDE_FILE}")
string(REGEX REPLACE
  ".*TIXML_PATCH_VERSION = ([0-9]+).*" "\\1"
  TinyXML_VERSION_PATCH "${TinyXML_INCLUDE_FILE}")
set(TinyXML_VERSION "${TinyXML_VERSION_MAJOR}.${TinyXML_VERSION_MINOR}.${TinyXML_VERSION_PATCH}")

add_definitions(-DTIXML_USE_STL)
add_library(tinyxml
  tinystr.cpp
  tinyxml.cpp
  tinyxmlparser.cpp
  tinyxmlerror.cpp
)
set_target_properties(tinyxml PROPERTIES
  VERSION 0.${TinyXML_VERSION} SOVERSION 0
)
install(TARGETS tinyxml
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(FILES tinyxml.h DESTINATION include)
