# This repo consists of a single hpp header file that wraps the ZeroMQ header.
# If someone wants this, they probably want ZeroMQ also, however this is not a
# dependency to "install" the cppzmq header. If ZeroMQ is not enabled, a
# warning is shown.

if(NOT fletch_ENABLE_ZeroMQ)
  message(WARNING "cppzmq module enabled without ZeroMQ! Only the header will be installed!")
endif()

ExternalProject_Add(cppzmq
  URL ${cppzmq_url}
  URL_MD5 ${cppzmq_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_NAME ${cppzmq_dlname}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  PATCH_COMMAND ${CMAKE_COMMAND}
   -Dcppzmq_patch:PATH=${fletch_SOURCE_DIR}/Patches/cppzmq
   -Dcppzmq_source:PATH=${fletch_BUILD_PREFIX}/src/cppzmq
   -P ${fletch_SOURCE_DIR}/Patches/cppzmq/Patch.cmake

  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
)

# CMake build configuration additions

set(cppzmq_ROOT ${fletch_BUILD_INSTALL_PREFIX}/include CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# cppzmq
#######################################
set(cppzmq_ROOT   \${fletch_ROOT})
set(cppzmq_INCLUDE_DIR @cppzmq_INCLUDE_DIR@)
")
