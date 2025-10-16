#+
# This file is called as CMake -P script for the patch step of

file (COPY ${Ceres_patch}/FindTBB.cmake
  DESTINATION ${Ceres_source}/cmake)
