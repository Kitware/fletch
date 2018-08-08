fletch_Require_Make()
ExternalProject_Add(ZeroMQ
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  URL ${ZeroMQ_url}
  URL_MD5 ${ZeroMQ_md5}
  CONFIGURE_COMMAND
    ./configure --prefix=${fletch_BUILD_INSTALL_PREFIX} --enable-static=yes
  BUILD_IN_SOURCE 1
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

set(ZeroMQ_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")
file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# ZeroMQ
#######################################
set(ZeroMQ_ROOT @ZeroMQ_ROOT@)
")
