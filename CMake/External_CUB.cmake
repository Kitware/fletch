
# Hacks around lack of caffe2 submodules.
# Simply add the source directory so we can point Caffe2 to it.
ExternalProject_Add(CUB
  DEPENDS ${CUB_DEPENDS}
  URL ${CUB_url}
  URL_MD5 ${CUB_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  )

fletch_external_project_force_install(PACKAGE CUB)

set(CUB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

# might be a better way of installing the required CUB headers
set(CUB_INCLUDE_DIR "${CMAKE_BINARY_DIR}/build/src/CUB")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# CUB
########################################
set(CUB_ROOT    \${fletch_ROOT})
")
