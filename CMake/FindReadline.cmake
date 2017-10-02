# - Try to find readline include dirs and libraries
#
# Usage of this module as follows:
#
# find_package(Readline)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
# Readline_ROOT Set this variable to the root installation of
# readline if the module has problems finding the
# proper installation path.
#
# Variables defined by this module:
#
# READLINE_FOUND System has readline, include and lib dirs found
# Readline_INCLUDE_DIR The readline include directories.
# Readline_LIBRARY The readline library.

if(Readline_DIR)
  find_package(Readline NO_MODULE)
elseif(NOT Readline_FOUND)
  include(CommonFindMacros)

  setup_find_root_context(Readline)
  find_path(Readline_INCLUDE_DIR readline.h ${Readline_FIND_OPTS})
  find_library(Readline_LIBRARY readline ${Readline_FIND_OPTS})
  restore_find_root_context(Readline)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Readline Readline_INCLUDE_DIR Readline_LIBRARY)
endif()
