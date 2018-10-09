#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV.cmake to change optimization setting for old gcc
#-

message("Patching OpenCV in ${OpenCV_source}")

file(COPY ${OpenCV_patch}/CMakeLists.txt
  DESTINATION ${OpenCV_source}/modules/features2d/
)

file(COPY ${OpenCV_patch}/OpenCVModule.cmake
  DESTINATION ${OpenCV_source}/cmake/
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

file(COPY ${OpenCV_patch}/OpenCVConfig.cmake.in
  DESTINATION ${OpenCV_source}/cmake/templates/
)

file(COPY ${OpenCV_patch}/graphcuts.cpp
  DESTINATION ${OpenCV_source}/modules/gpu/src/
)

file(COPY ${OpenCV_patch}/cv2.cpp
  DESTINATION ${OpenCV_source}/modules/python/src2/
)

# Patch FindCUDA to split out nppi libraries
file(COPY ${OpenCV_patch}/FindCUDA.cmake
  DESTINATION ${OpenCV_source}/cmake
)

# Patch the generating file to use the correct location when using MSVC 2017 and later
file(COPY ${OpenCV_patch}/run_nvcc.cmake
  DESTINATION ${OpenCV_source}/cmake/FindCUDA
)

# Set link-directories for 4 executables that have trouble finding FFmpeg
file(COPY ${OpenCV_patch}/apps/annotation/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/annotation/
)

# Patch helps OpenCV define HAVE_SWSCALE when lib is found
# The patch is required for highgui
file(COPY ${OpenCV_patch}/OpenCVFindLibsVideo.cmake
  DESTINATION ${OpenCV_source}/cmake
)

file(COPY ${OpenCV_patch}/apps/haartraining/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/haartraining
)

file(COPY ${OpenCV_patch}/apps/traincascade/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/traincascade/
)

file(COPY ${OpenCV_patch}/apps/visualisation/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/visualisation/
)

file(COPY ${OpenCV_patch}/modules/gpu/perf4au/CMakeLists.txt
  DESTINATION ${OpenCV_source}/modules/gpu/perf4au/
)
