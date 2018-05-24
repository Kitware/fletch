
ExternalProject_Add(SuiteSparse
    DEPENDS ${SuiteSparse_DEPENDS}
    URL ${SuiteSparse_file}
    URL_MD5 ${SuiteSparse_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    CMAKE_GENERATOR ${gen}
    SOURCE_DIR ${fletch_BUILD_PREFIX}/src/SuiteSparse
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSuiteSparse_patch=${fletch_SOURCE_DIR}/Patches/SuiteSparse
      -DSuiteSparse_source=${fletch_BUILD_PREFIX}/src/SuiteSparse
      -DBUILD_CXSPARSE_ONLY:BOOL=${BUILD_CXSPARSE_ONLY}
      -P ${fletch_SOURCE_DIR}/Patches/SuiteSparse/Patch.cmake

    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DBUILD_SHARED_LIBS:BOOL=${_suite_sparese_build_shared}
      -BUILD_TESTING:BOOL=OFF
      ${SuiteSparse_EXTRA_BUILD_FLAGS}
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
