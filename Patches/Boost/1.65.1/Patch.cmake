# This file is called as CMake -P script for the patch step of
# External_Boost.cmake.
# It fixes:

file(COPY ${Boost_patch}/build.bat
  DESTINATION ${Boost_source}/tools/build/src/engine
  )

file(COPY ${Boost_patch}/copy_path.cpp
  DESTINATION ${Boost_source}/tools/bcp/
  )
