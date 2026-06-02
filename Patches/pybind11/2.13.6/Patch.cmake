#+
# This file is called as CMake -P script for the patch step of
# External_pybind11.cmake pybind11_patch and pybind11_source are defined on the command
# line along with the call.
#-

# Patching files based off of open PR for pybind11
# https://github.com/pybind/pybind11/pull/2839
configure_file(
  ${pybind11_patch}/cast.h
  ${pybind11_source}/include/pybind11/
  COPYONLY
)

configure_file(
  ${pybind11_patch}/pybind11.h
  ${pybind11_source}/include/pybind11/
  COPYONLY
)

configure_file(
  ${pybind11_patch}/detail/class.h
  ${pybind11_source}/include/pybind11/detail
  COPYONLY
)

configure_file(
  ${pybind11_patch}/detail/common.h
  ${pybind11_source}/include/pybind11/detail
  COPYONLY
)
