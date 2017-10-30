#ckwg +4
# Copyright 2016 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed GLog
#
# The following variables will guide the build:
#
# GLog_ROOT        - Set to the install prefix of the GLog library
#
# The following variables will be set:
#
# GLog_FOUND       - Set to true if GLog can be found
# GLog_INCLUDE_DIR - The path to the GLog header files
# GLog_LIBRARY     - The full path to the GLog library

if(GLog_DIR)
  find_package(GLog NO_MODULE)
elseif(NOT GLog_FOUND)
  include(CommonFindMacros)

  SET(GLog_INCLUDE_PATHS ${GLog_ROOT}/include
    ${GLog_ROOT}/include/glog
    ${GLog_ROOT}
    /usr/include
    /usr/include/glog
    /usr/include/glog-base
    /usr/local/include
    /usr/local/include/glog
    /usr/local/include/glog-base
    /opt/gLog/include )
  SET(GLog_LIB_PATHS ${GLog_ROOT}/lib
    ${GLog_ROOT}
    /lib/
    /lib/glog-base
    /lib64/
    /usr/lib
    /usr/lib/glog-base
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/glog/lib )

  setup_find_root_context(GLog)
  find_path(GLog_INCLUDE_DIR logging.h ${GLog_FIND_OPTS} PATHS ${GLog_INCLUDE_PATHS})
  find_library(GLog_LIBRARY glog ${GLog_FIND_OPTS} PATHS ${GLog_LIB_PATHS})
  restore_find_root_context(GLog)

  include(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(GLog GLog_INCLUDE_DIR GLog_LIBRARY)
  if(GLog_FOUND)
    set(GLog_FOUND True)
  else()
    set(GLog_FOUND False)
  endif()
endif()
