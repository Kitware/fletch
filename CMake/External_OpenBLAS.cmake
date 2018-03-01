
if (WIN32)

  # Build option for windows not yet generated
  message( FATAL_ERROR "OpenBLAS on windows not yet supported" )

else()

  # Default linux install process for LevelDB
  Fletch_Require_Make()

  set(OpenBLAS_BUILD_DIR
    ${fletch_BUILD_PREFIX}/src/OpenBLAS
    )

  # Add a patch if one exists for the requested version
  set(OpenBLAS_patch ${fletch_SOURCE_DIR}/Patches/OpenBLAS/${OpenBLAS_version})
  if (EXISTS ${OpenBLAS_patch})
    set(OpenBLAS_PATCH_COMMAND ${CMAKE_COMMAND}
      -DOpenBLAS_patch:PATH=${OpenBLAS_patch}
      -DOpenBLAS_source:PATH=${fletch_BUILD_PREFIX}/src/OpenBLAS
      -P ${OpenBLAS_patch}/Patch.cmake
      )
  elseif()
    set(OpenBLAS_PATCH_COMMAND "")
  endif()

  ExternalProject_Add(OpenBLAS
    URL ${OpenBLAS_url}
    URL_MD5 ${OpenBLAS_md5}
    DOWNLOAD_NAME ${OpenBLAS_dlname}
    DEPENDS ${OpenBLAS_DEPENDS}
    PREFIX  ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${OpenBLAS_PATCH_COMMAND}
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND
    ${MAKE_EXECUTABLE} PREFIX=${fletch_BUILD_INSTALL_PREFIX} install
    )
endif()

fletch_external_project_force_install(PACKAGE OpenBLAS)


set(OpenBLAS_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

# Find the OpenBLAS library name that will be passed to OpenCV / Caffe / etc..
# Note: the lib does not exist yet, but we can be pretty sure what it will be
get_system_library_name(openblas openblas_libname)
set(OpenBLAS_LIB ${OpenBLAS_ROOT}/lib/${openblas_libname})
set(OpenBLAS_INCLUDE_DIR ${OpenBLAS_ROOT}/include)

# OpenBLAS implements both the LAPACK and BLAS API
set(LAPACK_LIBRARIES ${OpenBLAS_LIB})
set(BLAS_LIBRARIES ${OpenBLAS_LIB})

message(STATUS "OpenBLAS_LIB = ${OpenBLAS_LIB}")
message(STATUS "OpenBLAS_INCLUDE_DIR = ${OpenBLAS_INCLUDE_DIR}")
message(STATUS "openblas_libname = ${openblas_libname}")
message(STATUS "LAPACK_LIBRARIES = ${LAPACK_LIBRARIES}")
message(STATUS "BLAS_LIBRARIES = ${BLAS_LIBRARIES}")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# OpenBLAS
########################################
set(OpenBLAS_ROOT    \${fletch_ROOT})
")
