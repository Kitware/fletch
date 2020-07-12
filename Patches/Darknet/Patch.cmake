#+
# This file is called as CMake -P script for the patch step of
# External_Darknet.cmake
#-

file(
  COPY
  ${Darknet_Patch}/CMakeLists.txt
  DESTINATION
  ${Darknet_Source}
  )
