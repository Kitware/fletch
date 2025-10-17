cmake_minimum_required(VERSION 3.6.0)
project(fletch)

# Policy to address @foo@ variable expansion
# https://cmake.org/cmake/help/git-stage/policy/CMP0053.html
if(POLICY CMP0053)
  cmake_policy(SET CMP0053 NEW)
endif()

# Policy CMP0074 allows CMake to search
# "prefixes specified by the <PackageName>_ROOT in find_package"
# https://cmake.org/cmake/help/git-stage/policy/CMP0074.html
if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

# Policy CMP0114
# "allows CMake ExternalProject step targets to fully adopt their steps."
# The need for this policy comes from our
# fletch_external_project_force_install(PACKAGE pkg)
# We're setting to OLD for now because we're not ready to remove
# fletch_external_project_force_install before a release. Once we
# remove fletch_external_project_force_install, we can set this to NEW or remove.
if(POLICY CMP0114)
  cmake_policy(SET CMP0114 OLD)
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
set(fletch_VERSION_MINOR 6)
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

# If fletch is being configured from the outside ( e.g. from a super-build)
# allow the configuring package to set the install prefix.
if (NOT fletch_BUILD_INSTALL_PREFIX)
  set(fletch_BUILD_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/install)
endif()

set(fletch_DOWNLOAD_DIR ${fletch_SOURCE_DIR}/Downloads CACHE PATH
    "Directory to download tarballs into.")

include(${fletch_CMAKE_DIR}/Utils.cmake)

add_custom_target(Download)
add_custom_target(fletch-build-install)

# Include CXX11 support
set(fletch_CXX_STANDARD_VERSION "98")
option(fletch_BUILD_CXX11 "" TRUE)
if (fletch_BUILD_CXX11)
  set(fletch_CXX_STANDARD_VERSION "11")
endif()

#
# Do we want to build in Python support into packages where available
#
option(fletch_BUILD_WITH_PYTHON "Build with Python support where appropriate" FALSE)

set(fletch_PYTHON_MAJOR_VERSION "3" CACHE STRING
  "Python version to use: 3, 2, or empty")
set_property(CACHE fletch_PYTHON_MAJOR_VERSION PROPERTY STRINGS "3" "2")

# Find python if using an external python and not the internal version
if (fletch_BUILD_WITH_PYTHON AND NOT fletch_ENABLE_CPython)
  # If we change python versions re-find the bin, include, and libs
  if (NOT _prev_fletch_pymajor_version STREQUAL fletch_PYTHON_MAJOR_VERSION)
    # but dont clobber initial settings in the instance they are specified via
    # commandline (e.g  cmake -DPYTHON_EXECUTABLE=/my/special/python)
    if (_prev_fletch_pymajor_version)
      message(STATUS "The Python version changed; refinding the interpreter")
      message(STATUS "Previous python version was ${_prev_fletch_pymajor_version}")
      unset(_prev_fletch_pymajor_version CACHE)
      unset(PYTHON_EXECUTABLE CACHE)
      unset(PYTHON_INCLUDE_DIR CACHE)
      unset(PYTHON_LIBRARY CACHE)
      unset(PYTHON_LIBRARY_DEBUG CACHE)
    endif()
  endif()

  # Make a copy so we can determine if the user changes python versions
  set(_prev_fletch_pymajor_version "${fletch_PYTHON_MAJOR_VERSION}" CACHE INTERNAL
    "allows us to determine if the user changes python version")
  if (fletch_PYTHON_MAJOR_VERSION STREQUAL "3")
    find_package(PythonInterp 3.4 REQUIRED)
    find_package(PythonLibs 3.4 REQUIRED)
  else()
    find_package(PythonInterp 2.7 REQUIRED)
    find_package(PythonLibs 2.7 REQUIRED)
  endif()

  # Check to ensure that the python executable agrees with the major version
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" -c "import sys; print(sys.version[0:3])"
    RESULT_VARIABLE _exitcode
    OUTPUT_VARIABLE _python_version)
  if(NOT ${_exitcode} EQUAL 0)
    message(FATAL_ERROR "Python command to get version failed with error code: ${_exitcode}")
  endif()

  # Remove supurflous newlines (artifacts of print)
  string(STRIP "${_python_version}" _python_version)

  if(NOT _python_version MATCHES "^${fletch_PYTHON_MAJOR_VERSION}.*")
    message(FATAL_ERROR "Requested python \"${fletch_PYTHON_MAJOR_VERSION}\" but got \"${_python_version}\"")
  endif()

  # Check PYTHON_LIBRARY to see if we need to split it up
  # For example if you installed python3 with debug libs
  # PYTHON_LIBRARY = optimized:path/to/python3.lib:debug:path/to/python3_d.lib
  list(LENGTH PYTHON_LIBRARY len)
  if(${len} GREATER 1)
    set(lib_config)
    foreach(value ${PYTHON_LIBRARY})
      if(lib_config STREQUAL "optimized" AND
         NOT value STREQUAL "optimized" AND NOT value STREQUAL "debug")
        set(lib_config)
        set(PYTHON_LIBRARY ${value} CACHE PATH "Python Library" FORCE)
        break()
      else()
        set(lib_config ${value})
      endif()
    endforeach()
    set(lib_config)
    foreach(value ${PYTHON_LIBRARY})
      if(lib_config STREQUAL "debug" AND
         NOT value STREQUAL "optimized" AND NOT value STREQUAL "debug")
        set(lib_config)
        set(PYTHON_LIBRARY_DEBUG ${value} CACHE  PATH "Python Debug Library" FORCE)
        break()
      else()
        set(lib_config ${value})
      endif()
    endforeach()
    message(STATUS "PYTHON_LIBRARY : ${PYTHON_LIBRARY}")
    message(STATUS "PYTHON_LIBRARY_DEBUG : ${PYTHON_LIBRARY_DEBUG}")
  endif()
endif()

#
# Convenience Option for Dashboards to turn on ALL available Packages
#
option(fletch_ENABLE_ALL_PACKAGES "Enable all available packages" FALSE)

set(fletch_CONFIG_OUTPUT ${fletch_BINARY_DIR}/fletchConfig.cmake )

#
# Create a CMake Version file
#
set(fletch_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
configure_file(
  ${fletch_SOURCE_DIR}/fletchConfig-version.cmake.in
  ${fletch_BUILD_DIR}/fletchConfig-version.cmake
  @ONLY IMMEDIATE)

#+
# Each External_xxx is responsible for updating this file with their
# package information.  The goal is to insure that the file contains
# any variables (e.g. FOO_DIR) that would help a dependent project find
# packages that are built by Fletch.
#-

set(fletch_CONFIG_INPUT ${fletch_BINARY_DIR}/fletchConfig.cmake.in )
set(fletch_BUILD_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/build)


# We don't really need to install this file, but doing so allows us
# to call make install on fletch, which is useful when installing
# to a custom location.
#install( FILES ${fletch_BINARY_DIR}/fletchConfig-version.cmake
#  DESTINATION ${fletch_BUILD_INSTALL_SHARE_CMAKE_PREFIX} )


# We are using fletch_INSTALL_BUILD_DIR to define where Fletch_ROOT is at configure time
# If installed, it is set to CMAKE_PREFIX before configure, otherwise, set to fletch_ROOT
set(fletch_INSTALL_BUILD_DIR ${fletch_BUILD_INSTALL_PREFIX})
file(WRITE ${fletch_CONFIG_INPUT} "
# Configuration file for the fletch build
set(fletch_VERSION ${fletch_VERSION})
set(fletch_ROOT \"@fletch_INSTALL_BUILD_DIR@\")
set(fletch_WITH_PYTHON ${fletch_BUILD_WITH_PYTHON})
set(fletch_PYTHON_MAJOR_VERSION ${fletch_PYTHON_MAJOR_VERSION})
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

# Options to control GPU support
option(fletch_BUILD_WITH_CUDA "Build with CUDA support" FALSE)

if (fletch_BUILD_WITH_CUDA)
  find_package( CUDA QUIET REQUIRED )

  file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# CUDA
########################################
set(CUDA_TOOLKIT_ROOT_DIR    \"${CUDA_TOOLKIT_ROOT_DIR}\")
set(fletch_BUILT_WITH_CUDA TRUE)
set(fletch_CUDA_VERSION_MAJOR ${CUDA_VERSION_MAJOR})
set(fletch_CUDA_VERSION_MINOR ${CUDA_VERSION_MINOR})
set(fletch_CUDA_VERSION ${CUDA_VERSION})
set(fletch_CUDA_VERSION_STRING ${CUDA_VERSION_STRING})
  ")

  option(fletch_BUILD_WITH_CUDNN "Build with CUDNN support" FALSE)
  if (fletch_BUILD_WITH_CUDNN)
    set( CUDNN_ROOT_DIR "" CACHE PATH "CUDNN root folder" )
    mark_as_advanced( CUDNN_ROOT_DIR )
    find_package( CUDNN QUIET REQUIRED)

    file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# CUDNN
########################################
set(CUDNN_ROOT_DIR    ${CUDNN_ROOT_DIR})
set(fletch_BUILT_WITH_CUDNN TRUE)
")

  endif()
elseif(fletch_BUILD_WITH_CUDNN)
  unset(fletch_BUILD_WITH_CUDNN CACHE)
  message(WARNING "Disabling fletch_BUILD_WITH_CUDNN, You must have fletch_BUILD_WITH_CUDA enabled for this to be enabled")
endif()

#
# Include external project identifiers and version numbers
#
include(fletch-tarballs)

# Set up universal python paths used across the build
if(fletch_BUILD_WITH_PYTHON OR fletch_ENABLE_CPython)
  # Default fletch python package install location
  #
  # If a library supports setting the install location of their python libraries (i.e. opencv)
  # This is where we would like it to go. (Not all libs support this)
  if(fletch_ENABLE_CPython)
    set(fletch_PYTHON_LIB_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/python${CPython_version})
  else()
    set(fletch_PYTHON_LIB_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/python${PYTHON_VERSION})
  endif()
  set(fletch_PYTHON_PACKAGES_DIR ${fletch_PYTHON_LIB_DIR}/site-packages)

  # Enable flags for python 2 or 3
  if(fletch_PYTHON_MAJOR_VERSION MATCHES "^3.*")
    set(fletch_ENABLE_PYTHON2 False)
    set(fletch_ENABLE_PYTHON3 True)
  elseif(fletch_PYTHON_MAJOR_VERSION MATCHES "^2.*")
    message( WARNING "Python 2 is at end of life. Please upgrade to Python 3")
    set(fletch_ENABLE_PYTHON2 True)
    set(fletch_ENABLE_PYTHON3 False)
  else()
    message("Unknown Python version")
  endif()
endif()

#
# Include external project add cmake command used for all projects
#
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

# Passing down configuration types requires special formatting since it is a list
string( REPLACE ";" "$<SEMICOLON>" CMAKE_SS_CONF_TYPES "${CMAKE_CONFIGURATION_TYPES}" )

# Collect some sets of common external project arguments so we can push them to
# each project:
# General arguments for all projects
set (COMMON_EP_ARGS
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  PREFIX ${fletch_BUILD_PREFIX}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  )
set (COMMON_CMAKE_EP_ARGS
  CMAKE_GENERATOR ${CMAKE_GENERATOR}
  CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM}
  CMAKE_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET}
  )

if(CMAKE_GENERATOR STREQUAL Ninja)
  # When building with Ninja, force each external project to use the terminal.
  # This prevents exponential job spawning and allows seeing the output for
  # each external project in real time, rather than buffering it until the
  # entire external project build is completed.
  list(APPEND COMMON_CMAKE_EP_ARGS USES_TERMINAL_BUILD 1)
endif()
# General arguments for CMake projects
# Arguments to pass to each project's CMake
set (COMMON_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  "-DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_SS_CONF_TYPES}"
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DCMAKE_POLICY_DEFAULT_CMP0042=NEW
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_INSTALL_LIBDIR:PATH=lib
  -DCMAKE_INSTALL_RPATH:PATH=<INSTALL_DIR>/lib
  -DCMAKE_PREFIX_PATH:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DCMAKE_CXX_STANDARD:STRING=${fletch_CXX_STANDARD_VERSION}
  -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=TRUE
  -DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:BOOL=TRUE
  )

#
#  Set up fletch targets
#
set_property(DIRECTORY PROPERTY EP_STEP_TARGETS download)
foreach(source ${fletch_external_sources})

  # fletch_ENABLE_ALL_PACKAGES will automatically enable all commonly used packages
  # Avoid building unused packages by adding an _experimental flag in CMake/fletch-tarballs.cmake
  # For example, "set(ITK_experimental TRUE)" to avoid building ITK
  if (fletch_ENABLE_ALL_PACKAGES  AND NOT ${source}_experimental)
    set(fletch_ENABLE_${source} TRUE CACHE BOOL "" FORCE)
  endif()

  if(fletch_ENABLE_${source})
    include(External_${source})
    set(fletch_current_package ${source})
    add_dependencies(Download ${source}-download)

    # Workaround for a bug in Visual Studio generators
    set_target_properties(${source}-download PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD True)
    set_target_properties(${source}-download PROPERTIES EXCLUDE_FROM_ALL True)

    # Add the ${source}-install as a target to build to fletch-build-install
    # if it exists
    if (TARGET ${source}-install)
      add_dependencies(fletch-build-install ${source}-install)
      add_custom_command(TARGET fletch-build-install
        COMMAND ${CMAKE_COMMAND} --build ${fletch_BINARY_DIR} --target ${source}-install
        )
      set_target_properties(${source}-install PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD True)
      set_target_properties(${source}-install PROPERTIES EXCLUDE_FROM_ALL True)
    endif()

    # append the value of any existing variable suffixed with _SELECT_VERSION
    set(select_version_key ${source}_SELECT_VERSION)
    set(select_version_val ${${select_version_key}})
    if(select_version_val)
      file(APPEND ${fletch_CONFIG_INPUT} "set(${select_version_key} ${select_version_val})")
    endif()
  endif()
endforeach()

# Setup fletch-build-install target
get_property(fletch_INSTALL_STAMP_FILES GLOBAL PROPERTY fletch_INSTALL_STAMP_FILES)
foreach(install_stamp_file ${fletch_INSTALL_STAMP_FILES})
  remove_file_before(TARGET fletch-build-install FILE ${install_stamp_file})
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

set(fletch_CONFIG_INSTALL ${fletch_BUILD_INSTALL_PREFIX}/share/cmake/fletchConfig.cmake )
configure_file(${fletch_CONFIG_INPUT} ${fletch_CONFIG_INSTALL} @ONLY )


# Last step, prepare install of fletch.
include(${fletch_SOURCE_DIR}/CMake/fletch-install.cmake)
