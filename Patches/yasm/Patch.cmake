# CMake 4 compatibility patch for yasm
# Updates cmake_minimum_required to VERSION 3.10 (minimum required by CMake 4)
# Fixes LOCATION property errors (CMP0026) by using generator expressions

set(_yasm_cmakelists "${yasm_source}/CMakeLists.txt")
if(EXISTS "${_yasm_cmakelists}")
  file(READ "${_yasm_cmakelists}" _yasm_cmake_content)
  # Replace cmake_minimum_required with versions < 3.10 to 3.10 (lowercase)
  string(REGEX REPLACE
    "cmake_minimum_required[ \t]*\\([ \t]*VERSION[ \t]+([0-2]\\.[0-9]+|3\\.[0-9])[ \t]*\\)"
    "cmake_minimum_required(VERSION 3.10)"
    _yasm_cmake_content "${_yasm_cmake_content}")
  # Replace CMAKE_MINIMUM_REQUIRED with versions < 3.10 to 3.10 (uppercase)
  string(REGEX REPLACE
    "CMAKE_MINIMUM_REQUIRED[ \t]*\\([ \t]*VERSION[ \t]+([0-2]\\.[0-9]+|3\\.[0-9])[ \t]*\\)"
    "cmake_minimum_required(VERSION 3.10)"
    _yasm_cmake_content "${_yasm_cmake_content}")
  file(WRITE "${_yasm_cmakelists}" "${_yasm_cmake_content}")
endif()

# Fix YasmMacros.cmake - replace get_target_property LOCATION with generator expressions
# This fixes CMake policy CMP0026 violations
set(_yasm_macros "${yasm_source}/cmake/modules/YasmMacros.cmake")
if(EXISTS "${_yasm_macros}")
  file(READ "${_yasm_macros}" _macros_content)

  # Fix YASM_GENPERF macro - handle both GET_TARGET_PROPERTY and get_target_property
  # Match: GET_TARGET_PROPERTY(GENPERF_EXE genperf LOCATION) or similar variable names
  string(REGEX REPLACE
    "[Gg][Ee][Tt]_[Tt][Aa][Rr][Gg][Ee][Tt]_[Pp][Rr][Oo][Pp][Ee][Rr][Tt][Yy][ \t]*\\([ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]+genperf[ \t]+LOCATION[ \t]*\\)"
    "set(\\1 \"$<TARGET_FILE:genperf>\")"
    _macros_content "${_macros_content}")

  # Fix YASM_RE2C macro
  string(REGEX REPLACE
    "[Gg][Ee][Tt]_[Tt][Aa][Rr][Gg][Ee][Tt]_[Pp][Rr][Oo][Pp][Ee][Rr][Tt][Yy][ \t]*\\([ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]+re2c[ \t]+LOCATION[ \t]*\\)"
    "set(\\1 \"$<TARGET_FILE:re2c>\")"
    _macros_content "${_macros_content}")

  # Fix YASM_GENMACRO macro
  string(REGEX REPLACE
    "[Gg][Ee][Tt]_[Tt][Aa][Rr][Gg][Ee][Tt]_[Pp][Rr][Oo][Pp][Ee][Rr][Tt][Yy][ \t]*\\([ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]+genmacro[ \t]+LOCATION[ \t]*\\)"
    "set(\\1 \"$<TARGET_FILE:genmacro>\")"
    _macros_content "${_macros_content}")

  file(WRITE "${_yasm_macros}" "${_macros_content}")
endif()

# Fix modules/preprocs/nasm/CMakeLists.txt - genversion LOCATION property
set(_nasm_preproc "${yasm_source}/modules/preprocs/nasm/CMakeLists.txt")
if(EXISTS "${_nasm_preproc}")
  file(READ "${_nasm_preproc}" _nasm_content)

  # Fix genversion LOCATION property - handle both GET_TARGET_PROPERTY and get_target_property
  string(REGEX REPLACE
    "[Gg][Ee][Tt]_[Tt][Aa][Rr][Gg][Ee][Tt]_[Pp][Rr][Oo][Pp][Ee][Rr][Tt][Yy][ \t]*\\([ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]+genversion[ \t]+LOCATION[ \t]*\\)"
    "set(\\1 \"$<TARGET_FILE:genversion>\")"
    _nasm_content "${_nasm_content}")

  file(WRITE "${_nasm_preproc}" "${_nasm_content}")
endif()
