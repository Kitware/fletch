#+
# This file is called as CMake -P script for the patch step of
# External_LIBSVM.cmake LIBSVM_patch and LIBSVM_source are defined on the command
# line along with the call.
#-
# The purpose of this is to add CMake build to libsvm
message("Patching libsvm ${LIBSVM_patch} AND ${LIBSVM_source}")
message(STATUS "libsvm patch file = ${LIBSVM_patch}")
configure_file(
  ${LIBSVM_patch}/CMakeLists.txt
  ${LIBSVM_source}/CMakeLists.txt
  COPYONLY
)

file(COPY
  DESTINATION ${LIBSVM_source}
)

