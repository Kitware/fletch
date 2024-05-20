
# TinyXML must be static on Windows since they provide no exports
if (WIN32)
  set(tinyxml1_build_shared FALSE)
else()
  set(tinyxml1_build_shared TRUE)
endif()

ExternalProject_Add(TinyXML1
  URL ${TinyXML1_url}
  URL_MD5 ${TinyXML1_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DTinyXML1_patch=${fletch_SOURCE_DIR}/Patches/TinyXML1
    -DTinyXML1_source=${fletch_BUILD_PREFIX}/src/TinyXML1
    -P ${fletch_SOURCE_DIR}/Patches/TinyXML1/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${tinyxml1_build_shared}
)

fletch_external_project_force_install(PACKAGE TinyXML1)

set(TinyXML1_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# TinyXML
########################################
set(TinyXML1_ROOT \${fletch_ROOT})

set(fletch_ENABLED_TinyXML1 TRUE)
")
