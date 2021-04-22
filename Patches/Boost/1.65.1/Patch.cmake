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

# Patch to fix b2's missing headers
# This problem manifests in darwin clang and results in
# error: implicit declaration of function ...
file(COPY ${Boost_patch}/debugger.c
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/execcmd.c
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/filesys.h
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/fileunix.c
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/jam.c
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/make.c
  DESTINATION ${Boost_source}/tools/build/src/engine/
  )
file(COPY ${Boost_patch}/path.c
  DESTINATION ${Boost_source}/tools/build/src/engine/modules/
  )
