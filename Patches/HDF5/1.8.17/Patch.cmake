#+
# This file is called as CMake -P script for the patch step of
# External_HDF5.cmake HDF5_patch and HDF5_source are defined on the command
# line along with the call.
#-
#This patch, is copied from https://github.com/live-clones/hdf5/compare/develop...billhoffman:fix-h5watch-postbuild
#It fixes an issue with an excessively long install command. The patch will hopefully be part of the next HDF5 release.

message("Patching HDF5 ${HDF5_patch} AND ${HDF5_source}")
configure_file(
  ${HDF5_patch}/CMakeTests.cmake
  ${HDF5_source}/hl/tools/h5watch/
  COPYONLY
)
