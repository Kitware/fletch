#+
# This file is called as CMake -P script for the patch step of
# External_libtiff.cmake to fix build with VS2015
#-

message("Patching libtiff in ${libtiff_source}")

# file(COPY
#   ${libtiff_patch}/CMakeLists.txt
#   DESTINATION ${libtiff_source}
# )

# file(COPY
#   ${libtiff_patch}/libtiff/CMakeLists.txt
#   DESTINATION ${libtiff_source}/libtiff
# )
