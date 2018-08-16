#
# Script to find a ZeroMQ installation
#
# On return, the following variables will be defined:
#   ZeroMQ_FOUND       - True if ZeroMQ was found
#   ZeroMQ_INCLUDE_DIR - ZeroMQ include directories
#   ZeroMQ_LIBRARY     - ZeroMQ library file
#
# Variables that guide search:
#   ZeroMQ_ROOT - Hint install root to look for ZeroMQ installation files
#

include(CommonFindMacros)

setup_find_root_context(ZeroMQ)

find_path(ZeroMQ_INCLUDE_DIR zmq.h
  ${ZeroMQ_FIND_OPTS}
  )
find_library(ZeroMQ_LIBRARY zmq
  ${ZeroMQ_FIND_OPTS}
  )

restore_find_root_context(ZeroMQ)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( ZeroMQ
  FOUND_VAR ZeroMQ_FOUND
  REQUIRED_VARS ZeroMQ_INCLUDE_DIR ZeroMQ_LIBRARY
  )
