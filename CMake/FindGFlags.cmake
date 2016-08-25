#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed GFlags
#
# The following variables will guide the build:
#
# GFlags_ROOT        - Set to the install prefix of the GFlags library
#
# The following variables will be set:
#
# GFlags_FOUND       - Set to true if GFlags can be found
# GFlags_INCLUDE_DIR - The path to the GFlags header files
# GFlags_LIBRARY     - The full path to the GFlags library

if(GFlags_DIR)
  find_package(GFlags NO_MODULE)
elseif(NOT GFlags_FOUND)
  include(CommonFindMacros)

  SET(GFlags_INCLUDE_PATHS ${GFlags_ROOT}/include
    ${GFlags_ROOT}/include/gflags
    ${GFlags_ROOT}
    /usr/include
    /usr/include/gflags
    /usr/include/gflags-base
    /usr/local/include
    /usr/local/include/gflags
    /usr/local/include/gflags-base
    /opt/gflags/include )
  SET(GFlags_LIB_PATHS ${GFlags_ROOT}/lib
    ${GFlags_ROOT}
    /lib/
    /lib/gflags-base
    /lib64/
    /usr/lib
    /usr/lib/gflags-base
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/gflags/lib )

  setup_find_root_context(GFlags)
  find_path(GFlags_INCLUDE_DIR gflags.h ${GFlags_FIND_OPTS} PATHS ${GFlags_INCLUDE_PATHS})
  find_library(GFlags_LIBRARY gflags ${GFlags_FIND_OPTS} PATHS ${GFlags_LIB_PATHS})
  restore_find_root_context(GFlags)

  include(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(GFlags GFlags_INCLUDE_DIR GFlags_LIBRARY)
  if(GFlags_FOUND)
    set(GFlags_FOUND True)
  else()
    set(GFlags_FOUND False)
  endif()
endif()
