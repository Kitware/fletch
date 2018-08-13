ExternalProject_Add(Leptonica
  URL ${Leptonica_url}
  URL_MD5 ${Leptonica_md5}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_NAME ${lep_dlname}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_INSTALL_PREFIX}

  CMAKE_GENERATOR${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_LIBDIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/}
  )

set(Leptonica_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Leptonica
########################################
set(Leptonica_ROOT    \${fletch_ROOT})
")

