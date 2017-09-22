
if (WIN32)

  # Build option for windows not yet generated
  message( FATAL_ERROR "GLog on windows not yet supported" )

else ()

  Fletch_Require_Make()

  ExternalProject_Add(GLog
    URL ${GLog_file}
    URL_MD5 ${GLog_md5}
    DOWNLOAD_NAME ${GLog_dlname}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DGLog_patch:PATH=${fletch_SOURCE_DIR}/Patches/GLog
      -DGLog_source:PATH=${fletch_BUILD_PREFIX}/src/GLog
      -P ${fletch_SOURCE_DIR}/Patches/GLog/Patch.cmake
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND
      ${fletch_BUILD_PREFIX}/src/GLog/configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
      --enable-shared
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
endif ()

fletch_external_project_force_install(PACKAGE GLog)

set(GLog_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# GLog
#######################################
set(GLog_ROOT \${fletch_ROOT})
")
