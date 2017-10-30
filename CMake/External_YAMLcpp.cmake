# If we're building Boost, use that one.
if(fletch_ENABLE_Boost)
  set(yamlcpp_use_external_boost
    -DYAMLCPP_USE_EXTERNAL_BOOST:BOOL=ON
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    )
  set(_YAMLCPP_DEPENDS ${_YAMLCPP_DEPENDS} Boost)
else()
  set(yamlcpp_use_external_boost
    -DYAMLCPP_USE_EXTERNAL_BOOST:BOOL=OFF
    )
endif()

# YAMLcpp has some sort of odd build error (with clang, at least)
# if you build the tools.

ExternalProject_Add(YAMLcpp
  DEPENDS ${_YAMPCPP_DEPENDS}
  URL ${YAMLcpp_url}
  URL_MD5 ${YAMPcpp_md5}
  DOWNLOAD_NAME ${YAMLcpp_dlname}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${libkml_use_external_boost}
    -DYAML_CPP_BUILD_CONTRIB:BOOL=OFF
    -DYAML_CPP_BUILD_TOOLS:BOOL=OFF
)

fletch_external_project_force_install(PACKAGE YAMLcpp)

set(YAMLCPP_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "" FORCE)
set(YAMLCPP_DIR "${LIBKML_ROOT}/lib/cmake" CACHE PATH "" FORCE)
set(YAMLCPP_LIBNAME yaml-cpp)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# YAMLcpp
########################################
set(YAMPCPP__ROOT    \${fletch_ROOT})
set(YAMLCPP_DIR     \${fletch_ROOT}/lib/cmake)
set(YAMLCPP_LIBNAME @LIBYAMLCPP_LIBNAME@)

set(fletch_ENABLED_YAMLCPP TRUE)
")

