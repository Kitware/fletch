# This repo consists of a single hpp header file that wraps the ZeroMQ header.
# If someone wants this, they probably want ZeroMQ also, however this is not a
# dependency to "install" the cppzmq header. If ZeroMQ is not enabled, a
# warning is shown.

add_package_dependency(
  PACKAGE cppzmq
  PACKAGE_DEPENDENCY ZeroMQ
)

ExternalProject_Add(cppzmq
  URL ${cppzmq_url}
  URL_MD5 ${cppzmq_md5}
  DOWNLOAD_NAME ${cppzmq_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
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
