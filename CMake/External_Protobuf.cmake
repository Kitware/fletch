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
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DProtobuf_patch:PATH=${fletch_SOURCE_DIR}/Patches/Protobuf
    -DProtobuf_source:PATH=${fletch_BUILD_PREFIX}/src/Protobuf
    -P ${fletch_SOURCE_DIR}/Patches/Protobuf/Patch.cmake
  BUILD_IN_SOURCE 1
  ${PROTOBUF_PATCH_ARG}
  CONFIGURE_COMMAND ./autogen.sh
            COMMAND ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT @Protobuf_ROOT@)
")

