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

# Patch the 3rdParty pthread dll and lib CMakeLists.txt files to fix and install problem.
file(
  COPY
  ${Darknet_Patch}/3rdparty/dll/CMakeLists.txt
  DESTINATION
  ${Darknet_Source}/3rdparty/dll
  )
file(
  COPY
  ${Darknet_Patch}/3rdparty/lib/CMakeLists.txt
  DESTINATION
  ${Darknet_Source}/3rdparty/lib
  )

# Add #include <sys/time.h> to the MAC section as well
file(
  COPY
  ${Darknet_Patch}/utils.c
  DESTINATION
  ${Darknet_Source}/
  )
