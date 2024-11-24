ExternalProject_Add(ZeroMQ
  URL ${ZeroMQ_url}
  URL_MD5 ${ZeroMQ_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
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
