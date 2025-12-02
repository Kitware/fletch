ExternalProject_Add(freeimage
  URL ${freeimage_file}
  URL_MD5 ${freeimage_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
)

set(freeimage_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(freeimage_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/FreeImage CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# FreeImage
#######################################
set(freeimage_ROOT \${fletch_ROOT})
set(fletch_ENABLED_freeimage TRUE)
")
