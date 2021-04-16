
if (WIN32)
  set(_suite_sparese_build_shared OFF)
  set (BUILD_CXSPARSE_ONLY ON)
else()
  set(_suite_sparese_build_shared ${BUILD_SHARED_LIBS})
  option (BUILD_CXSPARSE_ONLY "Only build the CXSparse portion of SuiteSpars" OFF)
endif()

if (BUILD_CXSPARSE_ONLY)
  ExternalProject_Add(SuiteSparse
    DEPENDS ${SuiteSparse_DEPENDS}
    URL ${SuiteSparse_file}
    URL_MD5 ${SuiteSparse_md5}
    ${COMMON_EP_ARGS}
    ${COMMON_CMAKE_EP_ARGS}
    SOURCE_DIR ${fletch_BUILD_PREFIX}/src/SuiteSparse
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSuiteSparse_patch=${fletch_SOURCE_DIR}/Patches/SuiteSparse
      -DSuiteSparse_source=${fletch_BUILD_PREFIX}/src/SuiteSparse
      -DBUILD_CXSPARSE_ONLY:BOOL=${BUILD_CXSPARSE_ONLY}
      -P ${fletch_SOURCE_DIR}/Patches/SuiteSparse/Patch.cmake

    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DBUILD_SHARED_LIBS:BOOL=${_suite_sparese_build_shared}
      -DBUILD_TESTING:BOOL=OFF
      ${SuiteSparse_EXTRA_BUILD_FLAGS}
    )

elseif (NOT WIN32 AND NOT BUILD_CXSPARSE_ONLY)
  find_package(LAPACK QUIET)
  if (NOT LAPACK_FOUND)
    if(fletch_ENABLE_OpenBLAS)
      # If we are building OpenBLAS, make sure we have a fortran compiler.
      enable_language(Fortran)
      add_package_dependency(
        PACKAGE SuiteSparse
        PACKAGE_DEPENDENCY OpenBLAS
        PACKAGE_DEPENDENCY_ALIAS OpenBLAS
        )
      get_system_library_name(openblas openblas_libname)
      set(BLAS_LIBRARIES ${fletch_BUILD_INSTALL_PREFIX}/lib/${openblas_libname})
      set(env ${CMAKE_COMMAND} -E env)
      message("env = ${env}")
      set(env_var LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${fletch_BUILD_INSTALL_PREFIX}/lib)
      message("env_var = ${env_var}")
      set(ENV_CMD ${env} ${env_var})

    else()
      find_package(BLAS QUIET)
      if (NOT BLAS_FOUND)
        message(FATAL_ERROR "Building SuiteSparse requires LAPACK or BLAS. \
                Please install or enable OpenBLAS in the Fletch CMake config.")
      endif()
    endif()
  endif()

  if (MISSING_DEPS)
    message(FATAL " SuiteSparse requires the following packages, ${MISSING_DEPS}. Please install and try again")
  endif()

  set(SUITESPARSE_LAPACK ${LAPACK_LIBRARIES})
  if (SUITESPARSE_LAPACK MATCHES "Accelerate.framework")
    set(SUITESPARSE_LAPACK "-framework Accelerate")
  endif()

  set(SUITESPARSE_BLAS ${BLAS_LIBRARIES})
  if (SUITESPARSE_BLAS MATCHES "Accelerate.framework")
    set(SUITESPARSE_BLAS "-framework Accelerate")
  endif()

  find_library(LIBRT_LIBRARY rt)
  mark_as_advanced(LIBRT_LIBRARY)
  set(SUITESPARSE_LIBRT ${LIBRT_LIBRARY})
  if (NOT LIBRT_LIBRARY)
    set(SUITESPARSE_NOTIMER "-DNTIMER")
    unset(SUITESPARSE_LIBRT)
    mark_as_advanced(SUITESPARSE_NOTIMER)
  endif()

  # Make sure the install directories are created, which is not a guarantee with SuiteSparse built alone (first)
  file(MAKE_DIRECTORY ${fletch_BUILD_INSTALL_PREFIX}/include)
  file(MAKE_DIRECTORY ${fletch_BUILD_INSTALL_PREFIX}/lib)
  Fletch_Require_Make()
  ExternalProject_Add(SuiteSparse
    DEPENDS ${SuiteSparse_DEPENDS}
    URL ${SuiteSparse_file}
    URL_MD5 ${SuiteSparse_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSuiteSparse_patch=${fletch_SOURCE_DIR}/Patches/SuiteSparse
      -DSuiteSparse_source=${fletch_BUILD_PREFIX}/src/SuiteSparse
      -DBUILD_CXSPARSE_ONLY:BOOL=${BUILD_CXSPARSE_ONLY}
      -Dfletch_BUILD_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DLAPACK_LIBRARIES=${SUITESPARSE_LAPACK}
      -DBLAS_LIBRARIES=${SUITESPARSE_BLAS}
      -DLIBRT_LIBRARY=${SUITESPARSE_LIBRT}
      -DSUITESPARSE_NOTIMER=${SUITESPARSE_NOTIMER}
      -P ${fletch_SOURCE_DIR}/Patches/SuiteSparse/Patch.cmake

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${ENV_CMD} ${MAKE_EXECUTABLE} -j1
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )

endif()

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
