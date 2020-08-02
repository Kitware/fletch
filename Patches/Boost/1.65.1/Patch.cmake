# This file is called as CMake -P script for the patch step of
# External_Boost.cmake.
# It fixes:

file(COPY ${Boost_patch}/build.bat
  DESTINATION ${Boost_source}/tools/build/src/engine
  )

file(COPY ${Boost_patch}/copy_path.cpp
  DESTINATION ${Boost_source}/tools/bcp/
  )

file(COPY ${Boost_patch}/builtin_converters.cpp
  DESTINATION ${Boost_source}/libs/python/src/converter/
  )

file(COPY ${Boost_patch}/msvc.jam
  DESTINATION ${Boost_source}/tools/build/src/tools/
  )
file(COPY ${Boost_patch}/visualc.hpp
  DESTINATION ${Boost_source}/boost/config/compiler/
  )
