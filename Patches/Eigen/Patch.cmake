#+
# This file is called as CMake -P script for the patch step of
# External_Eigen.cmake Eigen_patch and Eigen_source are defined on the command
# line along with the call.
#-

# message("Patching Eigen ${Eigen_patch} AND ${Eigen_source}")
# configure_file(
#   ${Eigen_patch}/cmake/FindBLAS.cmake
#   ${Eigen_source}/cmake/
#   COPYONLY
#   )

# # Apply language_support patch from upstream commit
# # https://bitbucket.org/eigen/eigen/commits/ba14974d054a
# configure_file(
#   ${Eigen_patch}/cmake/language_support.cmake
#   ${Eigen_source}/cmake/
#   COPYONLY
# )

# configure_file(
#   ${Eigen_patch}/src/LU/arch/Inverse_SSE.h
#   ${Eigen_source}/Eigen/src/LU/arch/Inverse_SSE.h
#   COPYONLY )
