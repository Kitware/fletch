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
# Check whether vision-tpl builds the given package or we should look for
# it in the system.
# Arguments:
# PACKAGE: Name of the package you want to add a dependency to
# PACKAGE_DEPENDENCY: Name of the dependency you want to add to the PACKAGE
# PACKAGE_DEPENDENCY_ALIAS: (Optional) Name used to find the package using
#   find package. Use this when the library build by vision-tpl name differs from
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
#   PACKAGE_DEPENDENCY independently if it's built by vision-tpl or taken from
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
  if(vision-tpl_ENABLE_${MY_PACKAGE_DEPENDENCY})
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
        "- Turn on vision-tpl_ENABLE_${MY_PACKAGE_DEPENDENCY}.\n "
        "- Provide the location of an external ${dependency_name}.\n"
        )
    endif()
    set(${MY_PACKAGE}_WITH_${MY_PACKAGE_DEPENDENCY} ${${dependency_name}_FOUND})
  endif()

endmacro()
