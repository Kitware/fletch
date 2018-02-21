#+
# This file is called as CMake -P script for the patch step of
# External_GTest.cmake.
# GTest_patch and GTest_source are defined on the command line along with the
# call.
#-

message("Patching GTest")
# https://github.com/google/googletest/pull/1160
foreach(dir googletest googlemock)
  file(COPY ${GTest_patch}/${dir}/CMakeLists.txt DESTINATION ${GTest_source}/${dir})
endforeach()

 file(COPY ${GTest_patch}/googletest/cmake/internal_utils.cmake DESTINATION ${GTest_source}/googletest/cmake)
