#+
# This file is called as CMake -P script for the patch step of
# External_pybind11.cmake to fix issues with GIL deadlocks
#-

message("Patching pybind11 in ${pybind11_source}")

file(COPY
  ${pybind11_patch}/include/pybind11/options.h
  ${pybind11_patch}/include/pybind11/pybind11.h
  DESTINATION ${pybind11_source}/include/pybind11
)

file(COPY
  ${pybind11_patch}/tests/CMakeLists.txt
  ${pybind11_patch}/tests/conftest.py
  ${pybind11_patch}/tests/test_use_gilstate.cpp
  ${pybind11_patch}/tests/test_use_gilstate.py
  DESTINATION ${pybind11_source}/tests
)
