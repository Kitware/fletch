#+
# This file is called as CMake -P script for the patch step of
# External_GFlags to fix Windows VC2015 errors
#


file(COPY ${GFlags_patch}/windows_port.h
  DESTINATION ${GFlags_source}/src
  )

file(COPY ${GFlags_patch}/windows_port.cc
  DESTINATION ${GFlags_source}/src
  )

