if (WIN32)
  # Build option for windows not yet generated
  message( FATAL_ERROR "Protobuf on windows not yet supported" )
endif()

Fletch_Require_Make()
ExternalProject_Add(Protobuf
  URL ${Protobuf_url}
  URL_MD5 ${Protobuf_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  BUILD_IN_SOURCE 1
  ${PROTOBUF_PATCH_ARG}
  CONFIGURE_COMMAND ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

fletch_external_project_force_install(PACKAGE Protobuf)

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT @Protobuf_ROOT@)
")

