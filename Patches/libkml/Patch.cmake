#+
# This file is called as CMake -P script for the patch step of
# External_libkml.cmake to fix build with VS2013
#-

message("Patching libkml in ${libkml_source}")

file(COPY
  ${libkml_patch}/util.h
  ${libkml_patch}/file_win32.cc
  DESTINATION ${libkml_source}/src/kml/base/
)

file(COPY
  ${libkml_patch}/iomem_simple.c
  ${libkml_patch}/unzip.c
  DESTINATION ${libkml_source}/third_party/zlib-1.2.3/contrib/minizip
)

# Fix C++17 compatibility: remove deprecated std::binary_function
if(fletch_BUILD_CXX17)
  file(COPY
    ${libkml_patch}/convenience/feature_list.cc
    DESTINATION ${libkml_source}/src/kml/convenience/
  )
endif()

# Fix CMake 3.29+ compatibility: export() generated files cannot be installed
# with install(FILES), must use install(EXPORT) instead
file(READ "${libkml_source}/CMakeLists.txt" _cmake_content)

# Add EXPORT KMLTargets to INSTALL(TARGETS kml ...)
string(REPLACE
"  INSTALL(TARGETS kml
    RUNTIME DESTINATION bin COMPONENT RuntimeLibraries"
"  INSTALL(TARGETS kml
    EXPORT KMLTargets
    RUNTIME DESTINATION bin COMPONENT RuntimeLibraries"
  _cmake_content "${_cmake_content}")

# Replace install(FILES ... KMLTargets.cmake) with install(EXPORT KMLTargets ...)
string(REPLACE
  "INSTALL(FILES \${libkml_BINARY_DIR}/KMLTargets.cmake DESTINATION lib/cmake)"
  "install(EXPORT KMLTargets FILE KMLTargets.cmake DESTINATION lib/cmake)"
  _cmake_content "${_cmake_content}")

# Add expat target to the export set when building internal expat
# The expat target needs to be in the same export set as kml since kml links to it
string(REPLACE
  "LIST(APPEND KML_TARGETS expat)"
  "LIST(APPEND KML_TARGETS expat)
  # Install expat target with export set for CMake 3.29+ compatibility
  INSTALL(TARGETS expat
    EXPORT KMLTargets
    RUNTIME DESTINATION bin COMPONENT RuntimeLibraries
    LIBRARY DESTINATION lib COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION lib COMPONENT Development)"
  _cmake_content "${_cmake_content}")

file(WRITE "${libkml_source}/CMakeLists.txt" "${_cmake_content}")
