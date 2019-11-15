
if (Protobuf_SELECT_VERSION STREQUAL "3.9.0")
  ExternalProject_Add(Protobuf
#    PREFIX protobuf
    URL ${Protobuf_url}
    URL_MD5 ${Protobuf_md5}
    SOURCE_SUBDIR ./cmake
    ${COMMON_EP_ARGS}
    ${COMMON_CMAKE_EP_ARGS}
    CMAKE_ARGS
       ${COMMON_CMAKE_ARGS}
       -Dprotobuf_BUILD_TESTS:BOOL=OFF
       -Dprotobuf_BUILD_EXAMPLES:BOOL=OFF
       -Dprotobuf_BUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
       -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF#Don't change MSVC runtime settings (/MD or /MT)
       -Dprotobuf_WITH_ZLIB:BOOL=OFF
    )
elseif (NOT WIN32)
  set (Protobuf_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/Protobuf/${Protobuf_SELECT_VERSION})
  if (EXISTS ${Protobuf_PATCH_DIR})
    set(Protobuf_PATCH_COMMAND ${CMAKE_COMMAND}
      -DProtobuf_PATCH_DIR=${Protobuf_PATCH_DIR}
      -DProtobuf_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/Protobuf
      -P ${Protobuf_PATCH_DIR}/Patch.cmake)
  else()
    set(Protobuf_PATCH_COMMAND "")
  endif()

  Fletch_Require_Make()
  ExternalProject_Add(Protobuf
    URL ${Protobuf_url}
    URL_MD5 ${Protobuf_md5}
    ${COMMON_EP_ARGS}
    PATCH_COMMAND ${CMAKE_COMMAND}
    ${Protobuf_PATCH_COMMAND}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
else()
  # Build option for windows not yet generated
  message( FATAL_ERROR "Protobuf 2 not yet supported on windows" )
endif()

fletch_external_project_force_install(PACKAGE Protobuf)

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT \${fletch_ROOT})
")

