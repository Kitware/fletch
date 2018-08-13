ExternalProject_Add(ZeroMQ
  PREFIX ${fletch_BUILD_PREFIX}
  URL ${ZeroMQ_url}
  URL_MD5 ${ZeroMQ_md5}
  DOWNLOAD_NAME ${ZeroMQ_dlname}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}

  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}

)

set(ZeroMQ_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")
file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# ZeroMQ
#######################################
set(ZeroMQ_ROOT   \${fletch_ROOT})
")
