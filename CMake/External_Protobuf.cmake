if (WIN32)
  # Build option for windows not yet generated
  message( FATAL_ERROR "Protobuf on windows not yet supported" )
endif()

# Check that python and protobuf versions are compatible
if(fletch_BUILD_WITH_PYTHON AND fletch_ENABLE_Protobuf)
  # Note the python protobuf wrapper is not installed here.
  # Instead it must be installed via `pip install protobuf`
  if (${Protobuf_version} LESS 3.0 AND fletch_PYTHON_MAJOR_VERSION MATCHES "^3.*")
    message(ERROR " Must use Protobuf >= 3.x with Python 3.x")
  endif()
endif()



set (Protobuf_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/Protobuf/${Protobuf_SELECT_VERSION})
if (EXISTS ${Protobuf_PATCH_DIR})
  set(Protobuf_PATCH_COMMAND ${CMAKE_COMMAND}
    -DProtobuf_PATCH_DIR=${Protobuf_PATCH_DIR}
    -DProtobuf_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/Protobuf
    -P ${Protobuf_PATCH_DIR}/Patch.cmake)
else()
  set(Protobuf_PATCH_COMMAND "")
endif()

if(NOT BUILD_SHARED_LIBS)
  set(_shared_lib_params --disable-shared
                         --enable-static
                         --enable-pic
                         CFLAGS=-fPIC
                         CXXFLAGS=-fPIC
      )
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
    ${_shared_lib_params}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

fletch_external_project_force_install(PACKAGE Protobuf)

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT \${fletch_ROOT})
")

