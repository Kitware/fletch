ExternalProject_Add(CUB

  DEPENDS ${CUB2_DEPENDS}
  URL ${CUB2_url}
  URL_MD5 ${CUB2_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  )

fletch_external_project_force_install(PACKAGE CUB)

set(CUB2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# CUB
########################################
set(CUB2_ROOT    \${fletch_ROOT})
")
