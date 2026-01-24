# Add patch to use user-provided UUID instead of hardcoded one when writing SEI
configure_file(
  ${x265_patch}/sei.h
  ${x265_source}/source/encoder/
  COPYONLY
)

# CMake 4 compatibility: Remove deprecated policy settings that cannot be set to OLD
# CMP0025 and CMP0054 can no longer be set to OLD in CMake 4.x
set(_x265_cmakelists "${x265_source}/source/CMakeLists.txt")
if(EXISTS "${_x265_cmakelists}")
  file(READ "${_x265_cmakelists}" _x265_cmake_content)
  # Remove cmake_policy(SET CMP0025 OLD) lines
  string(REGEX REPLACE "cmake_policy\\([ \t]*SET[ \t]+CMP0025[ \t]+OLD[ \t]*\\)" "# cmake_policy(SET CMP0025 OLD) # Removed for CMake 4 compatibility" _x265_cmake_content "${_x265_cmake_content}")
  # Remove cmake_policy(SET CMP0054 OLD) lines
  string(REGEX REPLACE "cmake_policy\\([ \t]*SET[ \t]+CMP0054[ \t]+OLD[ \t]*\\)" "# cmake_policy(SET CMP0054 OLD) # Removed for CMake 4 compatibility" _x265_cmake_content "${_x265_cmake_content}")
  file(WRITE "${_x265_cmakelists}" "${_x265_cmake_content}")
endif()
