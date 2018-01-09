#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV.cmake when building with OpenCV 3.X
#-

message("Patching OpenCV in ${OpenCV_source}")


# Patch FindCUDA to unset CUDA_HOST_COMPILER before it figures out what it should be
file(COPY ${OpenCV_patch}/FindCUDA.cmake
  DESTINATION ${OpenCV_source}/cmake
)
# Patch the generating file to use the correct location when using MSVC 2017 and later
file(COPY ${OpenCV_patch}/run_nvcc.cmake
  DESTINATION ${OpenCV_source}/cmake/FindCUDA
)

# Patch detection of msvc compiler version
file(COPY ${OpenCV_patch}/OpenCVDetectCXXCompiler.cmake
  DESTINATION ${OpenCV_source}/cmake
)

# Set link-directories for 6 executables that have trouble finding FFmpeg
file(COPY ${OpenCV_patch}/apps/annotation/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/annotation
)
file(COPY ${OpenCV_patch}/apps/createsamples/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/createsamples
)
file(COPY ${OpenCV_patch}/apps/interactive-calibration/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/interactive-calibration
)
file(COPY ${OpenCV_patch}/apps/traincascade/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/traincascade
)
file(COPY ${OpenCV_patch}/apps/version/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/version
)
file(COPY ${OpenCV_patch}/apps/visualisation/CMakeLists.txt
  DESTINATION ${OpenCV_source}/apps/visualisation
)
