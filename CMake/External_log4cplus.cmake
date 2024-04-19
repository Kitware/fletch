ExternalProject_Add(log4cplus
    URL ${log4cplus_url}
    URL_MD5 ${log4cplus_md5}
    ${COMMON_EP_ARGS}
    ${COMMON_CMAKE_EP_ARGS}
    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DUNICODE:BOOL=OFF
      -DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF
      -DLOG4CPLUS_BUILD_TESTING=OFF
      -DWITH_UNIT_TESTS=OFF
    )

fletch_external_project_force_install(PACKAGE log4cplus)

set(log4cplus_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# log4cplus
########################################
set(log4cplus_ROOT   \${fletch_ROOT})
set(log4cplus_DIR    \${fletch_ROOT}/lib/cmake/log4cplus)
set(fletch_ENABLED_log4cplus TRUE)
")
