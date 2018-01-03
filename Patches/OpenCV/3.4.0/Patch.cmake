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

