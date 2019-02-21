# The uriparser external project for fletch

ExternalProject_Add(uriparser
  URL ${uriparser_file}
  URL_MD5 ${uriparser_md5}
  DOWNLOAD_NAME ${uriparser_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS=ON
    -DURIPARSER_BUILD_DOCS=OFF
    -DURIPARSER_BUILD_TESTS=OFF
)

fletch_external_project_force_install(PACKAGE uriparser)

set(URIPARSER_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# URIPARSER
########################################
set(URIPARSER_ROOT \${fletch_ROOT})

set(fletch_ENABLED_uriparser TRUE)
")

