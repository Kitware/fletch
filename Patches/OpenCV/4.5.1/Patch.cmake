# Patch to allow support for MSVC 2019 and 2022
file(COPY ${OpenCV_patch}/cmake/OpenCVDetectCXXCompiler.cmake
  DESTINATION ${OpenCV_source}/cmake
)
file(COPY ${OpenCV_patch}/cmake/templates/OpenCVConfig.root-WIN32.cmake.in
  DESTINATION ${OpenCV_source}/cmake/templates/
)
