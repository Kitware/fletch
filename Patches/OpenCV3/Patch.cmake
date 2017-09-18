#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV.cmake when building with OpenCV 3.X
#-

message("Patching OpenCV in ${OpenCV_source}")

# support CUDA 8.0
file(COPY ${OpenCV_patch}/graphcuts.cpp
  DESTINATION ${OpenCV_source}/modules/cudalegacy/src/
)

# fix issues with OpenCV using FFmpeg libraries
file(COPY ${OpenCV_patch}/OpenCVFindLibsVideo.cmake
  DESTINATION ${OpenCV_source}/cmake
)

# Support MSVC 2017
file(COPY ${OpenCV_patch}/OpenCVConfig.cmake
  DESTINATION ${OpenCV_source}/cmake
)
file(COPY ${OpenCV_patch}/OpenCVDetectCXXCompiler.cmake
  DESTINATION ${OpenCV_source}/cmake
)


# Fix MacOS linkage by removing INSTALL_NAME_DIR
file(COPY ${OpenCV_patch}/OpenCVModule.cmake
  DESTINATION ${OpenCV_source}/cmake/
)


# Fix issue with Debug MSVC linking to undistributed python27_d.lib
file(COPY ${OpenCV_patch}/cv2.cpp
  DESTINATION ${OpenCV_source}/modules/python/src2
)