
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

if(${Protobuf_use_cmake})
  ExternalProject_Add(Protobuf
    URL ${Protobuf_url}
    URL_MD5 ${Protobuf_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    SOURCE_SUBDIR ./cmake
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
      ${Protobuf_PATCH_COMMAND}

    CMAKE_ARGS 
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
      -Dprotobuf_BUILD_TESTS:BOOL=OFF
      -Dprotobuf_BUILD_EXAMPLES:BOOL=OFF
      -Dprotobuf_BUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF#Don't change MSVC runtime settings (/MD or /MT)
      -DCMAKE_INSTALL_PREFIX:STRING=${fletch_BUILD_INSTALL_PREFIX}
  )
else()
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
endif()

set(Protobuf_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google Protobuf
#######################################
set(Protobuf_ROOT \${fletch_ROOT})
")

