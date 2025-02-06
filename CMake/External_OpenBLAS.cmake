
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

  set(OpenBLAS_ENV DYNAMIC_ARCH=1 NO_AFFINITY=1 NUM_THREADS=32)

  ExternalProject_Add(OpenBLAS
    URL ${OpenBLAS_url}
    URL_MD5 ${OpenBLAS_md5}
    DEPENDS ${OpenBLAS_DEPENDS}
    ${COMMON_EP_ARGS}
    PATCH_COMMAND ${OpenBLAS_PATCH_COMMAND}
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ${OpenBLAS_ENV} ${MAKE_EXECUTABLE}
    INSTALL_COMMAND
    ${MAKE_EXECUTABLE} PREFIX=${fletch_BUILD_INSTALL_PREFIX} install
    )
endif()

fletch_external_project_force_install(PACKAGE OpenBLAS)

set(OpenBLAS_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# OpenBLAS
########################################
set(OpenBLAS_ROOT    \${fletch_ROOT})
")
