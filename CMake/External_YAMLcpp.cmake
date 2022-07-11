# YAMLcpp has some sort of odd build error (with clang, at least)
# if you build the tools.

ExternalProject_Add(YAMLcpp
  DEPENDS ${_YAMLCPP_DEPENDS}
  URL ${YAMLcpp_url}
  URL_MD5 ${YAMLcpp_md5}
  DOWNLOAD_NAME ${YAMLcpp_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DYAML_CPP_BUILD_CONTRIB:BOOL=OFF
    -DYAML_CPP_BUILD_TESTS:BOOL=OFF
    -DYAML_CPP_BUILD_TOOLS:BOOL=OFF
    -DEXPORT_TARGETS:STRING=yaml-cpp
)

fletch_external_project_force_install(PACKAGE YAMLcpp)

set(yaml-cpp_ROOT ${fletch_BUILD_INSTALL_PREFIX})
if(WIN32 AND NOT CYGWIN)
  set(yaml-cpp_DIR ${fletch_BUILD_INSTALL_PREFIX}/CMake  CACHE STRING "" FORCE)
else()
  set(yaml-cpp_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/yaml-cpp  CACHE STRING "" FORCE)
endif()

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# YAMLcpp
########################################
set(yaml-cpp_ROOT    \${fletch_ROOT})
if(WIN32 AND NOT CYGWIN)
  set(yaml-cpp_DIR     \${fletch_ROOT}/CMake)
else()
  set(yaml-cpp_DIR     \${fletch_ROOT}/lib/cmake/yaml-cpp)
endif()

set(fletch_ENABLED_YAMLCPP TRUE)
")
