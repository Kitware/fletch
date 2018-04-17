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


Fletch_Require_Make()
ExternalProject_Add(Protobuf
  URL ${Protobuf_url}
  URL_MD5 ${Protobuf_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    ${Protobuf_PATCH_COMMAND}

  BUILD_IN_SOURCE 1
  ${PROTOBUF_PATCH_ARG}
  CONFIGURE_COMMAND ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

fletch_external_project_force_install(PACKAGE Protobuf)

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

get_system_library_name( protobuf protobuf_libname )
get_system_library_name( protobuf-lite protobuf-lite_libname )
get_system_library_name( protoc protoc_libname )

set(PROTOBUF_INCLUDE_DIR "${Protobuf_ROOT}/include")
set(PROTOBUF_LIBRARY "${Protobuf_ROOT}/lib/${protobuf_libname}")
set(PROTOBUF_LIBRARY_DEBUG "${Protobuf_ROOT}/lib/${protobuf_libname}")
set(PROTOBUF_LITE_LIBRARY "${Protobuf_ROOT}/lib/${protobuf-lite_libname}")
set(PROTOBUF_LITE_LIBRARY_DEBUG "${Protobuf_ROOT}/lib/${protobuf-lite_libname}")
set(PROTOBUF_PROTOC_EXECUTABLE "${Protobuf_ROOT}/bin/protoc")
set(PROTOBUF_PROTOC_LIBRARY "${Protobuf_ROOT}/lib/${protoc_libname}")
set(PROTOBUF_PROTOC_LIBRARY_DEBUG "${Protobuf_ROOT}/lib/${protoc_libname}")


file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT \${fletch_ROOT})
")

