# Copyright 2015 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

#
# Utilities macros/function
#
include(CMakeParseArguments)

#
# Return the system library prefix and extension.
#
function(get_system_libary_vars prefix extension)
  if(WIN32)
    set(${prefix} "" PARENT_SCOPE)
    set(${extension} "lib" PARENT_SCOPE)
  elseif(APPLE)
    set(${prefix} "lib" PARENT_SCOPE)
    set(${extension} "dylib" PARENT_SCOPE)
  else()
    set(${prefix} "lib" PARENT_SCOPE)
    set(${extension} "so" PARENT_SCOPE)
  endif()
endfunction()

#
# Wrap the given library name with the system library prefix and extension
#
function(get_system_library_name lib_name result)
  get_system_libary_vars(pre ext)
  set(${result} "${pre}${lib_name}.${ext}" PARENT_SCOPE)
endfunction()

#
# Find all variables starting with some string prefix and format them in
# a way which is useful to pass down to subprojects
#
function(format_passdowns _str _varResult)
  set( _tmpResult "" )
  get_cmake_property( _vars VARIABLES )
  string( REGEX MATCHALL "(^|;)${_str}[A-Za-z0-9_]*" _matchedVars "${_vars}" )
  foreach( _match ${_matchedVars} )
    set( _tmpResult ${_tmpResult} "-D${_match}=${${_match}}" )
  endforeach()
  set( ${_varResult} ${_tmpResult} PARENT_SCOPE )
endfunction()

#
# Check whether fletch builds the given package or we should look for
# it in the system.
# Arguments:
# PACKAGE: Name of the package you want to add a dependency to
# PACKAGE_DEPENDENCY: Name of the dependency you want to add to the PACKAGE
# PACKAGE_DEPENDENCY_ALIAS: (Optional) Name used to find the package using
#   find package. Use this when the library build by fletch name differs from
#   the cannonical name used by cmake to find packages.
# OPTIONAL: (Optional) Used when the PACKAGE_DEPENDENCY is optional to build the
#   PACKAGE. This means that not finding the PACKAGE_DEPENDENCY will not prevent
#   the compilation of the PACKAGE, either because it can be built without the
#   functionalities the PACKAGE_DEPENDENCY would provide, or it will build
#   PACKAGE_DEPENDENCY internally (see also EMBEDDED).
# EMBEDDED: (Optional) Used to signal that the PACKAGE has an internal
#   PACKAGE_DEPENDENCY to build if it's not found. A EMBEDDED PACKAGE_DEPENDENCY
#   must be OPTIONAL.
#
# Output variables:
# ${PACKAGE}_DEPENDS: If the dependent package is being built, its name is
#   appended to this variable, intended to be used to list ExternalProject
#   dependencies to ensure correct build order.
# ${PACKAGE}_WITH_${PACKAGE_DEPENDENCY}: Whether the PACKAGE builds against the
#   PACKAGE_DEPENDENCY independently if it's built by fletch or taken from
#   the system.
#
macro(add_package_dependency)
  set(options
      OPTIONAL
      EMBEDDED
      )
  set(oneValueArgs
    PACKAGE
    PACKAGE_DEPENDENCY

    # Optional args
    PACKAGE_DEPENDENCY_ALIAS
    )
  set(multiValueArg)

  cmake_parse_arguments(MY
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  # Developer error. A dependency cannot be EMBEDDED and *not* OPTIONAL.
  if(NOT MY_OPTIONAL AND MY_EMBEDDED)
    message(FATAL_ERROR "EMBEDDED option is ON while ${MY_PACKAGE_DEPENDENCY} is not optional\n"
      "-> ${MY_PACKAGE_DEPENDENCY} should be an optional dependency.")
  endif()

  set(${MY_PACKAGE}_WITH_${MY_PACKAGE_DEPENDENCY})
  if(fletch_ENABLE_${MY_PACKAGE_DEPENDENCY})
    set(${MY_PACKAGE}_DEPENDS ${${MY_PACKAGE}_DEPENDS} ${MY_PACKAGE_DEPENDENCY})
    set(${MY_PACKAGE}_WITH_${MY_PACKAGE_DEPENDENCY} ON)
  else()
    set(dependency_name ${MY_PACKAGE_DEPENDENCY})
    if(MY_PACKAGE_DEPENDENCY_ALIAS)
      set(dependency_name ${MY_PACKAGE_DEPENDENCY_ALIAS})
    endif()

    find_package(${dependency_name})

    # Handle both casing (For package foo, we can have either
    # foo_FOUND or FOO_FOUND defined)
    string(TOUPPER ${dependency_name}_FOUND uppercase_found)
    if(DEFINED ${dependency_name}_FOUND)
      set(dependency_found ${${dependency_name}_FOUND})
    elseif(DEFINED uppercase_found)
      set(dependency_found ${uppercase_found})
    endif()

    if(NOT dependency_found AND MY_OPTIONAL)
      if(MY_EMBEDDED)
        message(STATUS "Warning: ${MY_PACKAGE} will rely on its own internal build of ${dependency_name}.")
      else()
        message(STATUS "Warning: ${dependency_name} disabled for ${MY_PACKAGE} build ")
      endif()
    elseif(NOT dependency_found AND NOT MY_OPTIONAL)
      message(FATAL_ERROR
        " ${dependency_name} is required to build ${MY_PACKAGE}.\n "
        "Either:\n "
        "- Turn on fletch_ENABLE_${MY_PACKAGE_DEPENDENCY}.\n "
        "- Provide the location of an external ${dependency_name}.\n"
        )
    endif()
    set(${MY_PACKAGE}_WITH_${MY_PACKAGE_DEPENDENCY} ${${dependency_name}_FOUND})
  endif()

endmacro()

#
# Factorization function to add a custom command before the target to remove
# a file.
# Arguments:
# TARGET: Target for which the file is removed.
# FILE: Full path to the file to remove.
#
function(remove_file_before)
  set(options)
  set(oneValueArgs TARGET FILE)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT MY_TARGET)
    message(FATAL_ERROR "Error - Unknown target: ${MY_TARGET}")
  endif()
  if(NOT MY_FILE)
    message(FATAL_ERROR "Error - File is not valid")
  endif()

  add_custom_command(TARGET ${MY_TARGET}
    PRE_BUILD
    #COMMAND ${CMAKE_COMMAND} -E echo "${MY_FILE}"
    COMMAND ${CMAKE_COMMAND} -E remove "${MY_FILE}"
    COMMENT "Removing file ${MY_FILE} before target '${MY_TARGET}'"
    )
endfunction()

#
# Add a separte install step for external projects. This will re-run the install
# step of the external project whenever the target is built.
# Arguments:
# PACKAGE: Name of the package you want to install after each build.
# STEP_NAMES: (Optional) List here the name each of the install steps you want to
#   ensure will be run after the build. If nothings, this default to "install".
#
# The global property fletch_INSTALL_STAMP_FILES is appended with the list of
# stamp files that need to be deleted in order to re-run the install for each project
# that call this function.
#
function(fletch_external_project_force_install)
  set(options)
  set(oneValueArgs PACKAGE)
  set(multiValueArgs STEP_NAMES)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT MY_STEP_NAMES)
    set(MY_STEP_NAMES "install")
  endif()

  ExternalProject_Add_StepTargets(${MY_PACKAGE} install)

  foreach(step_name ${MY_STEP_NAMES})
    set(stamp_file_root "${fletch_BINARY_DIR}/build/src/${MY_PACKAGE}-stamp")
    if(CMAKE_CONFIGURATION_TYPES)
      set(install_stamp_file "${stamp_file_root}/${CMAKE_CFG_INTDIR}/${MY_PACKAGE}-${step_name}")
    else()
      set(install_stamp_file "${stamp_file_root}//${MY_PACKAGE}-${step_name}")
    endif()

    remove_file_before(TARGET ${MY_PACKAGE}-install FILE ${install_stamp_file})
    set_property(GLOBAL APPEND PROPERTY fletch_INSTALL_STAMP_FILES ${install_stamp_file})
  endforeach()
endfunction()
