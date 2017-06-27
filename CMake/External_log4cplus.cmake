ExternalProject_Add(log4cplus
    URL ${log4cplus_url}
    URL_MD5 ${log4cplus_md5}
    DOWNLOAD_NAME ${log4cplus_dlname}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    CMAKE_COMMAND
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    )

fletch_external_project_force_install(PACKAGE log4cplus)

set(LOG4CPLUS_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(LOG4CPLUS_DIR "${LOG4CPLUS_ROOT}/lib/cmake/log4cplus" CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# log4cplus
########################################
set(LOG4CPLUS_ROOT    @LOG4CPLUS_ROOT@)
set(LOG4CPLUS_DIR    @LOG4CPLUS_DIR@)
set(fletch_ENABLED_log4cplus TRUE)
")
