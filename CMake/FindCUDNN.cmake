#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed CUDNN library from nVidia
#
# The following variables will guide the build:
#
# CUDNN_ROOT_DIR  - Set to the install prefix of the CUDNN library
#
# The following variables will be set:
#
# CUDNN_FOUND       - Set to true if CUDNN can be found
# CUDNN_INCLUDE_DIR - The path to the CUDNN header files
# CUDNN_LIBRARIES  - The full path to the CUDNN libraries

find_package( CUDA QUIET REQUIRED )

find_library( CUDNN_LIBRARIES
      NAMES cudnn libcudnn
      HINTS ${CUDA_TOOLKIT_ROOT_DIR}
            ${CUDNN_ROOT_DIR}
      PATH_SUFFIXES lib lib64 lib/x64 lib/x86 targets/aarch64-linux
    )
if( NOT CUDNN_LIBRARIES )
  set(CUDNN_FOUND FALSE)
  message(FATAL_ERROR "Unable to find cudnn libraries, please ensure CUDA_TOOLKIT_ROOT_DIR has cudnn or the CUDNN_ROOT_DIR variable is properly set or set CUDNN_LIBRARIES")
else()
  set(CUDNN_FOUND TRUE)
  # We found cudnn with out CUDNN_ROOT_DIR, CUDA and CUDNN must be co-located
  if(NOT CUDNN_ROOT_DIR)
    set(CUDNN_ROOT_DIR ${CUDA_TOOLKIT_ROOT_DIR})
  endif()
  set(CUDNN_INCLUDE_DIR ${CUDNN_ROOT_DIR}/include)
endif()

