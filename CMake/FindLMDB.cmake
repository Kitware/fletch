#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed LMDB
#
# The following variables will guide the build:
#
# LMDB_ROOT        - Set to the install prefix of the LMDB library
#
# The following variables will be set:
#
# LMDB_FOUND       - Set to true if LMDB can be found
# LMDB_INCLUDE_DIR - The path to the LMDB header files
# LMDB_LIBRARY     - The full path to the LMDB library

if(LMDB_DIR)
  find_package(LMDB NO_MODULE)
elseif(NOT LMDB_FOUND)
  include(CommonFindMacros)

  SET(LMDB_INCLUDE_PATHS ${LMDB_ROOT}/include
    ${LMDB_ROOT}/include/lmdb
    ${LMDB_ROOT}
    /usr/include
    /usr/include/lmdb
    /usr/include/lmdb-base
    /usr/local/include
    /usr/local/include/lmdb
    /usr/local/include/lmdb-base
    /opt/lmdb/include )
  SET(LMDB_LIB_PATHS ${LMDB_ROOT}/lib
    ${LMDB_ROOT}
    /lib/
    /lib/lmdb-base
    /lib64/
    /usr/lib
    /usr/lib/lmdb-base
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/lmdb/lib )

  setup_find_root_context(LMDB)
  find_path(LMDB_INCLUDE_DIR lmdb.h ${LMDB_FIND_OPTS} PATHS ${LMDB_INCLUDE_PATHS})
  find_library(LMDB_LIBRARY lmdb ${LMDB_FIND_OPTS} PATHS ${LMDB_LIB_PATHS})
  restore_find_root_context(LMDB)

  include(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(LMDB LMDB_INCLUDE_DIR LMDB_LIBRARY)
  if(LMDB_FOUND)
    set(LMDB_FOUND True)
  else()
    set(LMDB_FOUND False)
  endif()
endif()
