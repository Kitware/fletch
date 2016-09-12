
# The Boost external project for fletch

configure_file(
${CMAKE_SOURCE_DIR}/Patches/Boost/CMakeVars.cmake.in
${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
)

set(_Boost_DIR_ARGS
  -DBoost_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/Boost
  -DBoost_BUILD_DIR=${fletch_BUILD_PREFIX}/src/Boost-build
  -DBoost_INSTALL_DIR=${fletch_BUILD_INSTALL_PREFIX}
)

if(fletch_BUILD_WITH_PYTHON)
  set(fletch_EXTRA_BOOST_LIBS ${fletch_EXTRA_BOOST_LIBS} python)

  set(_Boost_PYTHON_ARGS
    -DPYTHON_VERSION_MAJOR=${PYTHON_VERSION_MAJOR}
    -DPYTHON_VERSION_MINOR=${PYTHON_VERSION_MINOR}
    -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
    -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
    -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
  )
endif()

ExternalProject_Add(Boost
  URL ${Boost_file}
  URL_MD5 ${Boost_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DBoost_patch=${fletch_SOURCE_DIR}/Patches/Boost
    -DBoost_source=${fletch_BUILD_PREFIX}/src/Boost
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Patch.cmake
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    ${_Boost_DIR_ARGS}
    ${_Boost_PYTHON_ARGS}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Configure.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_BUILD_TYPE=$<CONFIGURATION>
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    -DBoost_EXTRA_LIBS=${fletch_EXTRA_BOOST_LIBS}
    ${_Boost_DIR_ARGS}
    ${_Boost_PYTHON_ARGS}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Build.cmake
  INSTALL_COMMAND ${CMAKE_COMMAND}
    -DCMAKE_VARS_FILE=${fletch_BUILD_PREFIX}/tmp/Boost/CMakeVars.cmake
    ${_Boost_DIR_ARGS}
    -P ${fletch_SOURCE_DIR}/Patches/Boost/Install.cmake
)
add_dependencies(Download Boost-download)

set(BOOST_ROOT ${fletch_BUILD_INSTALL_PREFIX})

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Boost
########################################
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
if(WIN32)
  add_definitions(-DBOOST_ALL_NO_LIB)
endif()
set(Boost_ADDITIONAL_VERSIONS @Boost_version@)
set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_NO_BOOST_CMAKE ON)
set(BOOST_ROOT @BOOST_ROOT@)

set(fletch_ENABLED_Boost TRUE)
")
