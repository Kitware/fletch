# If we're building Boost, use that one.
if(fletch_ENABLE_Boost)
  set(_YAMLCPP_DEPENDS ${_YAMLCPP_DEPENDS} Boost)
else()
  message(FATAL_ERROR "YAMLcpp requires the Boost library.")
endif()

# YAMLcpp has some sort of odd build error (with clang, at least)
# if you build the tools.

ExternalProject_Add(YAMLcpp
  DEPENDS ${_YAMLCPP_DEPENDS}
  URL ${YAMLcpp_url}
  URL_MD5 ${YAMPcpp_md5}
  DOWNLOAD_NAME ${YAMLcpp_dlname}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DYAMLcpp_patch:PATH=${fletch_SOURCE_DIR}/Patches/YAMLcpp
    -DYAMLcpp_source:PATH=${fletch_BUILD_PREFIX}/src/YAMLcpp
    -P ${fletch_SOURCE_DIR}/Patches/YAMLcpp/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DYAML_CPP_BUILD_CONTRIB:BOOL=OFF
    -DYAML_CPP_BUILD_TOOLS:BOOL=OFF
)

fletch_external_project_force_install(PACKAGE YAMLcpp)

set(YAMLCPP_ROOT ${fletch_BUILD_INSTALL_PREFIX})
set(YAMLCPP_DIR ${fletch_BUILD_INSTALL_PREFIX}/CMake  CACHE STRING "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# YAMLcpp
########################################
set(YAMLCPP_ROOT    \${YAMLCPP_ROOT})
set(YAMLCPP_DIR     \${YAMLCPP_DIR})

set(fletch_ENABLED_YAMLCPP TRUE)
")

