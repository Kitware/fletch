
# The Boost external project for fletch
if(MSVC AND (NOT MSVC_VERSION LESS 1910))
  # Get the CMAKE version string and make sure it's not a release candidate and >= 3.8.0
  if( (CMAKE_VERSION MATCHES "^3\\.8\\.0-rc") OR (CMAKE_VERSION VERSION_LESS 3.8.0))
    message(FATAL_ERROR "CMake 3.8.0 is the minimum version required to use Boost with Visual Studio 2017 or greater")
  endif()
endif()

configure_file(
${CMAKE_SOURCE_DIR}/Patches/Boost/CMakeVars.cmake.in
${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
)

set(_Boost_DIR_ARGS
  -DBoost_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/Boost
  -DBoost_BUILD_DIR=${fletch_BUILD_PREFIX}/src/Boost-build
  -DBoost_INSTALL_DIR=${fletch_BUILD_INSTALL_PREFIX}
)

set(fletch_EXTRA_BOOST_LIBS "" CACHE STRING "Additional Boost libraries to install")

if(fletch_BUILD_WITH_PYTHON)
  option(ENABLE_Boost_PYTHON "" FALSE)
  mark_as_advanced(ENABLE_Boost_PYTHON)
  if (ENABLE_Boost_PYTHON)
    set(fletch_EXTRA_BOOST_LIBS ${fletch_EXTRA_BOOST_LIBS} python)

    set(_Boost_PYTHON_ARGS
      -DPYTHON_VERSION_MAJOR=${PYTHON_VERSION_MAJOR}
      -DPYTHON_VERSION_MINOR=${PYTHON_VERSION_MINOR}
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      )
    endif()
endif()

set (Boost_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/Boost/${Boost_SELECT_VERSION})
if (EXISTS ${Boost_PATCH_DIR})
  set(Boost_PATCH_COMMAND ${CMAKE_COMMAND}
    -DBoost_patch=${Boost_PATCH_DIR}
    -DBoost_source=${fletch_BUILD_PREFIX}/src/Boost
    -P ${Boost_PATCH_DIR}/Patch.cmake)
else()
  set(Boost_PATCH_COMMAND "")
endif()

ExternalProject_Add(Boost
  URL ${Boost_file}
  URL_MD5 ${Boost_md5}
  ${COMMON_EP_ARGS}
  PATCH_COMMAND
    ${Boost_PATCH_COMMAND}
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    -DBoost_EXTRA_LIBS=${fletch_EXTRA_BOOST_LIBS}
    ${_Boost_DIR_ARGS}
    ${_Boost_PYTHON_ARGS}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Configure.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_BUILD_TYPE=$<CONFIGURATION>
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    ${_Boost_DIR_ARGS}
    ${_Boost_PYTHON_ARGS}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Build.cmake
  INSTALL_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    ${_Boost_DIR_ARGS}
    -DBoost_source=${fletch_BUILD_PREFIX}/src/Boost
    -DENABLE_Boost_PYTHON=${ENABLE_Boost_PYTHON}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Install.cmake
)
add_dependencies(Download Boost-download)

fletch_external_project_force_install(PACKAGE Boost)

set(BOOST_ROOT ${fletch_BUILD_INSTALL_PREFIX})

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Boost
########################################
# If we are using MSVC 2017 make sure the CMake version is sufficient
if(MSVC AND (NOT MSVC_VERSION LESS 1910))
  # Get the CMAKE version string and make sure it's not a release candidate and >= 3.8.0
  if( (CMAKE_VERSION MATCHES \"^3\\\\.8\\\\.0-rc\") OR (CMAKE_VERSION VERSION_LESS 3.8.0))
    message(FATAL_ERROR \"CMake 3.8.0 is the minimum version required to use Boost with Visual Studio 2017 or greater\")
  endif()
endif()

set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
if(WIN32)
  add_definitions(-DBOOST_ALL_NO_LIB)
  add_definitions(-DBOOST_PROGRAM_OPTIONS_DYN_LINK)
endif()
set(Boost_ADDITIONAL_VERSIONS @Boost_version@)
set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_NO_BOOST_CMAKE ON)
set(BOOST_ROOT \${fletch_ROOT})

set(fletch_ENABLED_Boost TRUE)
")
