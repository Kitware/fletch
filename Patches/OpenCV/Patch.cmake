#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV.cmake to change optimization setting for old gcc
#-

message("Patching OpenCV in ${OpenVC_source}")

file(COPY ${OpenCV_patch}/CMakeLists.txt
  DESTINATION ${OpenCV_source}/modules/features2d/
)

file(COPY ${OpenCV_patch}/OpenCVDetectCUDA.cmake
  DESTINATION ${OpenCV_source}/cmake/
)

file(COPY ${OpenCV_patch}/OpenCVDetectCXXCompiler.cmake
  DESTINATION ${OpenCV_source}/cmake/
)

file(COPY ${OpenCV_patch}/OpenCVConfig.cmake
  DESTINATION ${OpenCV_source}/cmake/
)
