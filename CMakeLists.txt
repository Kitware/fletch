cmake_minimum_required(VERSION 2.8.12)
project(fletch)

# Policy to address @foo@ variable expansion
if(POLICY CMP0053)
  cmake_policy(SET CMP0053 NEW)
endif()

#+
# A word about Fletch versioning:
#
# The Major version number is reserved for the overall
# fletch version.  It will not change from 1 until, for example,
# the entire fletch strucure is ineveitably rewritten as a collection
# of custom Perl scripts.
#
# The Minor version number will be incremented any time
# a new package or set of packages are included or if one of the already
# included packages has a version number change.
#
# The variant version number is incremented for other minor changes or
# bugfixes that result in adjustments to the fletchConfig.cmake file
# (in other words, non-package changing differences that client projects
# can still detect after the change)
#-
set(fletch_VERSION_MAJOR 1)
set(fletch_VERSION_MINOR 0)
set(fletch_VERSION_PATCH 0)

set(fletch_VERSION "${fletch_VERSION_MAJOR}.${fletch_VERSION_MINOR}.${fletch_VERSION_PATCH}")

set(fletch_CMAKE_DIR "${fletch_SOURCE_DIR}/CMake")
set(CMAKE_MODULE_PATH ${fletch_CMAKE_DIR} ${CMAKE_MODULE_PATH})

# Don't force a build type in mutli-configuration platforms
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()


set(CPACK_PACKAGE_VERSION_MAJOR ${fletch_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${fletch_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${fletch_VERSION_PATCH})

set(fletch_DOWNLOAD_DIR ${fletch_SOURCE_DIR}/Downloads CACHE PATH
    "Directory to download tarballs into.")

include(${fletch_CMAKE_DIR}/Utils.cmake)

add_custom_target(Download)

# Option to control GPU support
option(fletch_DISABLE_GPU_SUPPORT "" FALSE)

# Include CXX11 support
set(fletch_CXX_STANDARD_VERSION "98")
option(fletch_BUILD_CXX11 "" TRUE)
if (fletch_ENABLE_CXX11)
  set(fletch_CXX_STANDARD_VERSION "11")
endif()

#
# Do we want to build in Python support where available
#
option(fletch_BUILD_WITH_PYTHON "Build with Python support where appropriate" FALSE)
<<<<<<< viame/master
if (fletch_BUILD_WITH_PYTHON)
  find_package(PythonInterp 2.7 REQUIRED)
  find_package(PythonLibs 2.7 REQUIRED)
endif()
=======
>>>>>>> viame/update-vxl

#
# Convenience Option for Dashboards to turn on ALL available Packages
#
option(fletch_ENABLE_ALL_PACKAGES "Enable all available packages" FALSE)

<<<<<<< viame/master
=======
if (fletch_BUILD_WITH_PYTHON)
  find_package(PythonInterp)
  find_package(PythonLibs)
endif()

>>>>>>> viame/update-vxl
#
# Create a CMake Version file
#
configure_file(
  ${fletch_SOURCE_DIR}/fletchConfig-version.cmake.in
  ${fletch_BINARY_DIR}/fletchConfig-version.cmake
  @ONLY IMMEDIATE)

# If fletch is being configured from the outside ( e.g. from a super-build)
# allow the configuring package to set the install prefix.
if (NOT fletch_BUILD_INSTALL_PREFIX)
  set(fletch_BUILD_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/install)
endif()

#+
# Each External_xxx is responsible for updating this file with their
# package information.  The goal is to insure that the file contains
# any variables (e.g. FOO_DIR) that would help a dependent project find
# packages that are built by Fletch.
#-

set(fletch_CONFIG_INPUT ${fletch_BINARY_DIR}/fletchConfig.cmake.in )
set(fletch_CONFIG_OUTPUT ${fletch_BINARY_DIR}/fletchConfig.cmake )
set(fletch_BUILD_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build)


# We don't really need to install this file, but doing so allows us
# to call make install on fletch, which is useful when installing
# to a custom location.
#install( FILES ${fletch_BINARY_DIR}/fletchConfig-version.cmake
#  DESTINATION ${fletch_BUILD_INSTALL_SHARE_CMAKE_PREFIX} )


file(WRITE ${fletch_CONFIG_INPUT} "
# Configuration file for the fletch build
set(fletch_VERSION ${fletch_VERSION})
set(fletch_ROOT ${fletch_BUILD_INSTALL_PREFIX})
set(fletch_WITH_PYTHON ${fletch_BUILD_WITH_PYTHON})
")


# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND UNIX)
  message(STATUS "Setting build type is set to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
endif()

option(BUILD_SHARED_LIBS "Build shared libraries where possible." ON)

# Since much of KWIVER is plugin based, shared libs are the default
mark_as_advanced(BUILD_SHARED_LIBS)

# Enable /MP flag for Visual Studio 2008 and greater
if(MSVC_VERSION GREATER 1400)
  # Allow the MP flag to get set externally. If not set, default to OFF.
  if(NOT fletch_ENABLE_MULTI_PROCESS_BUILDS)
    set(fletch_ENABLE_MULTI_PROCESS_BUILDS OFF)
  endif()
  set(ENABLE_MULTI_PROCESS_BUILDS ${fletch_ENABLE_MULTI_PROCESS_BUILDS} CACHE BOOL "Enable multi-process builds")
  set(PROCESSOR_COUNT "$ENV{NUMBER_OF_PROCESSORS}")
  set(CMAKE_CXX_MP_NUM_PROCESSORS ${PROCESSOR_COUNT} CACHE STRING "The maximum number of processes for the /MP flag")
  if (ENABLE_MULTI_PROCESS_BUILDS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${CMAKE_CXX_MP_NUM_PROCESSORS}")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP${CMAKE_CXX_MP_NUM_PROCESSORS}")
  endif ()
endif()

include(fletch-tarballs)
include(ExternalProject)

#+
# Various packages that are not CMake-based need to use Make for their build
# steps. When we ourselves are using Make, we want to invoke it in the proper
# recursive manner via '$(MAKE)'; otherwise we need to use the actual
# executable. Decide which, here, rather than replicating this logic all over
# the place.
#-
set(fletch_requires_make)
macro(Fletch_Require_Make)
  list(APPEND fletch_requires_make ${fletch_current_package})
endmacro()

if (CMAKE_GENERATOR MATCHES ".*Makefiles")
  set(MAKE_EXECUTABLE "$(MAKE)")
elseif(NOT "#@$ENV{MAKE}" STREQUAL "#@")
  set(MAKE_EXECUTABLE $ENV{MAKE})
else()
  find_program(MAKE_EXECUTABLE make)
endif()

# Collect the set of common CMake args so we can push them to each project
set (COMMON_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_INSTALL_LIBDIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib
  -DCMAKE_PREFIX_PATH:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DCMAKE_CXX_STANDARD:STRING=${fletch_CXX_STANDARD_VERSION}
  )

#
#  Set up a download target
#
set_property(DIRECTORY PROPERTY EP_STEP_TARGETS download)
foreach(source ${fletch_external_sources})
  if (fletch_ENABLE_ALL_PACKAGES)
    set(fletch_ENABLE_${source} TRUE CACHE BOOL "" FORCE)
  endif()

  if(fletch_ENABLE_${source})
    include(External_${source})
    set(fletch_current_package ${source})
    add_dependencies(Download ${source}-download)

    # Workaround for a bug in Visual Studio generators
    set_target_properties(${source}-download PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD True)
    set_target_properties(${source}-download PROPERTIES EXCLUDE_FROM_ALL True)
  endif()

endforeach()

#+
# A common use case is to turn on everything and then turn a few things off in ccmake or
# cmake-gui.  Unless we reset ENABLE_ALL, it'll just "fix" things again
#-
set(fletch_ENABLE_ALL_PACKAGES FALSE CACHE BOOL "" FORCE)

if (NOT "#@${fletch_requires_make}" STREQUAL "#@")
  if (NOT MAKE_EXECUTABLE)
    message(FATAL_ERROR "Could not find 'make', required to build ${fletch_requires_make}.")
  endif()
endif()


configure_file(${fletch_CONFIG_INPUT} ${fletch_CONFIG_OUTPUT} @ONLY )
