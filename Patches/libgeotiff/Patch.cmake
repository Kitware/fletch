#+
# This file is called as CMake -P script for the patch step of
# External_libgeotiff.cmake
#-

message("Patching libgeotiff ${libgeotiff_source}")

# Remove cmake_policy(SET CMP0022 OLD) and cmake_policy(SET CMP0042 OLD)
# which are no longer supported in newer CMake versions
file(READ ${libgeotiff_source}/CMakeLists.txt _cmakelists_content)
string(REPLACE "cmake_policy(SET CMP0022 OLD)" "" _cmakelists_content "${_cmakelists_content}")
string(REPLACE "cmake_policy(SET CMP0042 OLD)" "" _cmakelists_content "${_cmakelists_content}")
file(WRITE ${libgeotiff_source}/CMakeLists.txt "${_cmakelists_content}")
