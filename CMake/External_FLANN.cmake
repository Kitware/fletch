
ExternalProject_Add(FLANN
  URL ${FLANN_url}
  URL_MD5 ${FLANN_md5}
  DOWNLOAD_NAME ${FLANN_dlname}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
)

fletch_external_project_force_install(PACKAGE FLANN)

set(FLANN_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# FLANN
########################################
set(FLANN_ROOT    \${fletch_ROOT})
set(fletch_ENABLED_FLANN TRUE)
")
