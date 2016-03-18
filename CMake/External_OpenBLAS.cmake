
if (WIN32)

  # Build option for windows not yet generated
  message( FATAL_ERROR "OpenBLAS on windows not yet supported" )

else()

  # Default linux install process for LevelDB
  Fletch_Require_Make()

  set(OpenBLAS_BUILD_DIR
    ${fletch_BUILD_PREFIX}/src/OpenBLAS
    )

  ExternalProject_Add(OpenBLAS
    URL ${OpenBLAS_url}
    URL_MD5 ${OpenBLAS_md5}
    DEPENDS ${OpenBLAS_DEPENDS}
    PREFIX  ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DOpenBLAS_patch:PATH=${fletch_SOURCE_DIR}/Patches/OpenBLAS
      -DOpenBLAS_source:PATH=${fletch_BUILD_PREFIX}/src/OpenBLAS
      -P ${fletch_SOURCE_DIR}/Patches/OpenBLAS/Patch.cmake
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND
    ${MAKE_EXECUTABLE} PREFIX=${fletch_BUILD_INSTALL_PREFIX} install
    )
endif()

set(OpenBLAS_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# OpenBLAS
########################################
set(OpenBLAS_ROOT    @OpenBLAS_ROOT@)
")
