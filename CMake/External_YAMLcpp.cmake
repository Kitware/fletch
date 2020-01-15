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
  URL_MD5 ${YAMLcpp_md5}
  DOWNLOAD_NAME ${YAMLcpp_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DYAMLcpp_patch:PATH=${fletch_SOURCE_DIR}/Patches/YAMLcpp
    -DYAMLcpp_source:PATH=${fletch_BUILD_PREFIX}/src/YAMLcpp
    -P ${fletch_SOURCE_DIR}/Patches/YAMLcpp/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DYAML_CPP_BUILD_CONTRIB:BOOL=OFF
    -DYAML_CPP_BUILD_TOOLS:BOOL=OFF
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

