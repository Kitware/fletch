#+
# This file is called as CMake -P script for the patch step of
# External_Eigen.cmake Eigen_patch and Eigen_source are defined on the command
# line along with the call.
#-

message("Patching Eigen ${Eigen_patch} AND ${Eigen_source}")
configure_file(
  ${Eigen_patch}/cmake/FindBLAS.cmake
  ${Eigen_source}/cmake/
  COPYONLY
)
