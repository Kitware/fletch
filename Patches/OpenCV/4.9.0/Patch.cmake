# Patch to allow support for MSVC 2022 and 2026
file(COPY ${OpenCV_patch}/cmake/OpenCVDetectCXXCompiler.cmake
  DESTINATION ${OpenCV_source}/cmake
)
file(COPY ${OpenCV_patch}/cmake/templates/OpenCVConfig.root-WIN32.cmake.in
  DESTINATION ${OpenCV_source}/cmake/templates/
)

# Patch gen2.py to fix hdr_parser import issue on Windows
# The build system runs gen2.py from a different directory, so hdr_parser.py
# (in the same directory as gen2.py) cannot be found. The patch adds the
# script's directory to sys.path before the import.
file(COPY ${OpenCV_patch}/modules/python/src2/gen2.py
  DESTINATION ${OpenCV_source}/modules/python/src2/
)
