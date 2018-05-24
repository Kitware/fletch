
ExternalProject_Add(SuiteSparse
    DEPENDS ${SuiteSparse_DEPENDS}
    URL ${SuiteSparse_file}
    URL_MD5 ${SuiteSparse_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    CMAKE_GENERATOR ${gen}

    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DSHARED:BOOL=${BUILD_SHARED_LIBS}
      -DLIBRARY_OUTPUT_PATH:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib
    )

  fletch_external_project_force_install(PACKAGE SuiteSparse)

  set(SuiteSparse_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
  set(SuiteSparse_INCLUDE_DIR ${SuiteSparse_ROOT}/include CACHE PATH "" FORCE)

  file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# SuiteSparse
########################################
set(SuiteSparse_ROOT \${fletch_ROOT})
set(SuiteSparse_INCLUDE_DIR \${fletch_ROOT}/include)
set(fletch_ENABLED_SuiteSparse TRUE)
")
