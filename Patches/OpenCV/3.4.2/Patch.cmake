#+
# This file is called as CMake -P script for the patch step of
# External_OpenCV.cmake when building with OpenCV 3.X
#-

message("Patching OpenCV in ${OpenCV_source}")


# Patch FindCUDA to unset CUDA_HOST_COMPILER before it figures out what it should be
file(COPY ${OpenCV_patch}/cmake/FindCUDA.cmake
  DESTINATION ${OpenCV_source}/cmake
)

if(fletch_PYTHON_MAJOR_VERSION STREQUAL "2")
  # Patch python 2 bindings to build when using MSVC Debug configuration
  file(COPY ${OpenCV_patch}/modules/python/src2/cv2.cpp
    DESTINATION ${OpenCV_source}/modules/python/src2
  )
endif()