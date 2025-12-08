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
file(COPY
  ${libkml_patch}/convenience/feature_list.cc
  DESTINATION ${libkml_source}/src/kml/convenience/
)
