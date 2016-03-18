#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed OpenBLAS
#
# The following variables will guide the build:
#
# OpenBLAS_ROOT        - Set to the install prefix of the OpenBLAS library
#
# The following variables will be set:
#
# OpenBLAS_FOUND       - Set to true if OpenBLAS can be found
# OpenBLAS_INCLUDE_DIR - The path to the OpenBLAS header files
# OpenBLAS_LIBRARY     - The full path to the OpenBLAS library

if(OpenBLAS_DIR)
  find_package(OpenBLAS NO_MODULE)
elseif(NOT OpenBLAS_FOUND)
  include(CommonFindMacros)

  SET(OpenBLAS_INCLUDE_PATHS ${OpenBLAS_ROOT}/include
    ${OpenBLAS_ROOT}
    /usr/include
    /usr/include/openblas
    /usr/include/openblas-base
    /usr/local/include
    /usr/local/include/openblas
    /usr/local/include/openblas-base
    /opt/OpenBLAS/include )
  SET(OpenBLAS_LIB_PATHS ${OpenBLAS_ROOT}/lib
    ${OpenBLAS_ROOT}
    /lib/
    /lib/openblas-base
    /lib64/
    /usr/lib
    /usr/lib/openblas-base
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/OpenBLAS/lib )

  setup_find_root_context(OpenBLAS)
  find_path(OpenBLAS_INCLUDE_DIR openblas_config.h ${OpenBLAS_FIND_OPTS} PATHS ${OpenBLAS_INCLUDE_PATHS})
  find_library(OpenBLAS_LIBRARY openblas ${OpenBLAS_FIND_OPTS} PATHS ${OpenBLAS_LIB_PATHS})
  restore_find_root_context(OpenBLAS)

  include(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenBLAS OpenBLAS_INCLUDE_DIR OpenBLAS_LIBRARY)
  if(OPENBLAS_FOUND)
    set(OpenBLAS_FOUND True)
  else()
    set(OpenBLAS_FOUND False)
  endif()
endif()
