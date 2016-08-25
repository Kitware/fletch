#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed LevelDB
#
# The following variables will guide the build:
#
# LevelDB_ROOT        - Set to the install prefix of the LevelDB library
#
# The following variables will be set:
#
# LevelDB_FOUND       - Set to true if LevelDB can be found
# LevelDB_INCLUDE_DIR - The path to the LevelDB header files
# LevelDB_LIBRARY     - The full path to the LevelDB library

if(LevelDB_DIR)
  find_package(LevelDB NO_MODULE)
elseif(NOT LevelDB_FOUND)
  include(CommonFindMacros)

  SET(LevelDB_INCLUDE_PATHS ${LevelDB_ROOT}/include
    ${LevelDB_ROOT}/include/leveldb
    ${LevelDB_ROOT}
    /usr/include
    /usr/include/leveldb
    /usr/include/leveldb-base
    /usr/local/include
    /usr/local/include/leveldb
    /usr/local/include/leveldb-base
    /opt/leveldb/include )
  SET(LevelDB_LIB_PATHS ${LevelDB_ROOT}/lib
    ${LevelDB_ROOT}
    /lib/
    /lib/leveldb-base
    /lib64/
    /usr/lib
    /usr/lib/leveldb-base
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/leveldb/lib )

  setup_find_root_context(LevelDB)
  find_path(LevelDB_INCLUDE_DIR db.h ${LevelDB_FIND_OPTS} PATHS ${LevelDB_INCLUDE_PATHS})
  find_library(LevelDB_LIBRARY leveldb ${LevelDB_FIND_OPTS} PATHS ${LevelDB_LIB_PATHS})
  restore_find_root_context(LevelDB)

  include(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(LevelDB LevelDB_INCLUDE_DIR LevelDB_LIBRARY)
  if(LevelDB_FOUND)
    set(LevelDB_FOUND True)
  else()
    set(LevelDB_FOUND False)
  endif()
endif()
