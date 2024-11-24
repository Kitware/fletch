#+
# This file is called as CMake -P script for the patch step of
# External_pybind11.cmake pybind11_patch and pybind11_source are
# defined on the command line along with the call.
#-

configure_file(
  ${pybind11_patch}/gil.h
  ${pybind11_source}/include/pybind11/
  COPYONLY
)

configure_file(
  ${pybind11_patch}/FindPythonLibsNew.cmake
  ${pybind11_source}/tools
  COPYONLY
)
