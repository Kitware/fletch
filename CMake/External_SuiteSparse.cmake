option (BUILD_CXSPARSE_ONLY "Only build the CXSparse portion of SuiteSpars" ON)

if (WIN32)
  set(_suite_sparese_build_shared OFF)
else()
  set(_suite_sparese_build_shared ${BUILD_SHARED_LIBS})
endif()

if (BUILD_CXSPARSE_ONLY)
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
      -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DBUILD_SHARED_LIBS:BOOL=${_suite_sparese_build_shared}
      -BUILD_TESTING:BOOL=OFF
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      ${SuiteSparse_EXTRA_BUILD_FLAGS}
    )

elseif (NOT WIN32 AND NOT BUILD_CXSPARSE_ONLY)

  find_library(LAPACK_FOUND lapack)
  find_library(OPENBLAS_FOUND openblas)
  if (NOT LAPACK_FOUND AND NOT OPENBLAS_FOUND)
    message(FATAL "SuiteSparse requires lapack and openblas. Please install and try again")
  endif()

  Fletch_Require_Make()
  ExternalProject_Add(SuiteSparse
    DEPENDS ${SuiteSparse_DEPENDS}
    URL ${SuiteSparse_file}
    URL_MD5 ${SuiteSparse_md5}
    PREFIX  ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSuiteSparse_patch=${fletch_SOURCE_DIR}/Patches/SuiteSparse
      -DSuiteSparse_source=${fletch_BUILD_PREFIX}/src/SuiteSparse
      -DBUILD_CXSPARSE_ONLY:BOOL=${BUILD_CXSPARSE_ONLY}
      -Dfletch_BUILD_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -P ${fletch_SOURCE_DIR}/Patches/SuiteSparse/Patch.cmake

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${MAKE_EXECUTABLE} -j1
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )

endif()


set(SuiteSparse_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(SuiteSparse_INCLUDE_DIR ${SuiteSparse_ROOT}/include CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# SuiteSparse
########################################
set(SuiteSparse_ROOT @SuiteSparse_ROOT@)
set(SuiteSparse_INCLUDE_DIR @SuiteSparse_INCLUDE_DIR@)
")
