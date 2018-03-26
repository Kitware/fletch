#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV_contrib.cmake when building with OpenCV contrib
#-

message("Patching OpenCV contrib in ${OpenCV_contrib_source}")


file(COPY ${OpenCV_contrib_patch}/modules/xobjdetect/tools/waldboost_detector/CMakeLists.txt
  DESTINATION ${OpenCV_contrib_source}/modules/xobjdetect/tools/waldboost_detector/
)
