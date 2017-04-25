#+
# This file is called as CMake -P script for the patch step of
# External_libjson.cmake to cmake-ify libjson
#-

# CMake-ify
file(COPY ${libjson_patch}/cmakeify/ DESTINATION ${libjson_source})
file(REMOVE ${libjson_source}/JSONOptions.h)
file(GLOB_RECURSE junk_files ${libjson_source}/*/._*)
file(REMOVE ${junk_files})

file(COPY
  ${libjson_patch}/JSONChildren.cpp
  DESTINATION
  ${libjson_source}/_internal/Source/
  )
