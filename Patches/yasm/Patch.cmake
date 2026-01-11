# CMake 4 compatibility patch for yasm
# Updates cmake_minimum_required to VERSION 3.5 (minimum required by CMake 4)

set(_yasm_cmakelists "${yasm_source}/CMakeLists.txt")
if(EXISTS "${_yasm_cmakelists}")
  file(READ "${_yasm_cmakelists}" _yasm_cmake_content)
  # Replace cmake_minimum_required with versions < 3.5 to 3.5 (lowercase)
  string(REGEX REPLACE
    "cmake_minimum_required[ \t]*\\([ \t]*VERSION[ \t]+([0-2]\\.[0-9]+|3\\.[0-4])[ \t]*\\)"
    "cmake_minimum_required(VERSION 3.5)"
    _yasm_cmake_content "${_yasm_cmake_content}")
  # Replace CMAKE_MINIMUM_REQUIRED with versions < 3.5 to 3.5 (uppercase)
  string(REGEX REPLACE
    "CMAKE_MINIMUM_REQUIRED[ \t]*\\([ \t]*VERSION[ \t]+([0-2]\\.[0-9]+|3\\.[0-4])[ \t]*\\)"
    "cmake_minimum_required(VERSION 3.5)"
    _yasm_cmake_content "${_yasm_cmake_content}")
  file(WRITE "${_yasm_cmakelists}" "${_yasm_cmake_content}")
endif()
