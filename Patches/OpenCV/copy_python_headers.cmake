# copy_python_headers.cmake
# Copies Python headers from include/ to include/python3.xx/ for OpenCV on Windows.
# CPython on Windows installs headers directly to include/, but OpenCV's FindPythonLibs
# expects them in a version-specific subdirectory.
#
# Required variables:
#   PYTHON_INCLUDE_DIR    - Target directory (e.g., .../include/python3.10)
#   PYTHON_INCLUDE_PARENT - Source directory where headers are (e.g., .../include)

if(NOT DEFINED PYTHON_INCLUDE_DIR)
  message(FATAL_ERROR "PYTHON_INCLUDE_DIR not defined")
endif()
if(NOT DEFINED PYTHON_INCLUDE_PARENT)
  message(FATAL_ERROR "PYTHON_INCLUDE_PARENT not defined")
endif()

# Only copy if Python.h exists in source but not in destination
if(NOT EXISTS "${PYTHON_INCLUDE_PARENT}/Python.h")
  message(STATUS "Python.h not found in ${PYTHON_INCLUDE_PARENT}, skipping")
  return()
endif()

if(EXISTS "${PYTHON_INCLUDE_DIR}/Python.h")
  message(STATUS "Python.h already exists in ${PYTHON_INCLUDE_DIR}, skipping")
  return()
endif()

message(STATUS "Copying Python headers from ${PYTHON_INCLUDE_PARENT} to ${PYTHON_INCLUDE_DIR}")

# Create the target directory
file(MAKE_DIRECTORY "${PYTHON_INCLUDE_DIR}")

# Copy all header files
file(GLOB PYTHON_HEADERS "${PYTHON_INCLUDE_PARENT}/*.h")
if(PYTHON_HEADERS)
  file(COPY ${PYTHON_HEADERS} DESTINATION "${PYTHON_INCLUDE_DIR}")
endif()

# Copy cpython subdirectory if it exists
if(EXISTS "${PYTHON_INCLUDE_PARENT}/cpython")
  file(COPY "${PYTHON_INCLUDE_PARENT}/cpython" DESTINATION "${PYTHON_INCLUDE_DIR}")
endif()

# Copy internal subdirectory if it exists (Python 3.11+)
if(EXISTS "${PYTHON_INCLUDE_PARENT}/internal")
  file(COPY "${PYTHON_INCLUDE_PARENT}/internal" DESTINATION "${PYTHON_INCLUDE_DIR}")
endif()

message(STATUS "Python headers copied successfully")
