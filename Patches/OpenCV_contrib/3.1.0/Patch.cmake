#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV_contrib.cmake when building with OpenCV contrib
#-

message("Patching OpenCV contrib in ${OpenCV_contrib_source}")


file(COPY ${OpenCV_contrib_patch}/sfm/CMakeLists.txt
  DESTINATION ${OpenCV_contrib_source}/modules/sfm/
)

file(COPY ${OpenCV_contrib_patch}/sfm/src/libmv_capi.h
  DESTINATION ${OpenCV_contrib_source}/modules/sfm/src/
)

file(COPY ${OpenCV_contrib_patch}/hdf/hdf5.hpp
  DESTINATION ${OpenCV_contrib_source}/modules/hdf/include/opencv2/hdf/
)

file(COPY ${OpenCV_contrib_patch}/hdf/hdf5.cpp
  DESTINATION ${OpenCV_contrib_source}/modules/hdf/src/
)

file(COPY ${OpenCV_contrib_patch}/sfm/src/libmv_light/libmv/multiview/CMakeLists.txt
  DESTINATION ${OpenCV_contrib_source}/modules/sfm/src/libmv_light/libmv/multiview/
)

file(COPY ${OpenCV_contrib_patch}/modules/xobjdetect/tools/waldboost_detector/CMakeLists.txt
  DESTINATION ${OpenCV_contrib_source}/modules/xobjdetect/tools/waldboost_detector/
)
