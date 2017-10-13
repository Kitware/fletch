if(NOT BUILD_tests)
  return()
endif()

add_library(${tgtName}_gtest STATIC EXCLUDE_FROM_ALL gtest.h gtest-all.cpp)
caffe_default_properties(${tgtName}_gtest)

