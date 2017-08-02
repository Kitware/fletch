
# TinyXML must be static on Windows since they provide no exports
if (WIN32)
  set(tinyxml_build_shared FALSE)
else()
  set(tinyxml_build_shared TRUE)
endif()

ExternalProject_Add(TinyXML
  URL ${TinyXML_url}
  URL_MD5 ${TinyXML_md5}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DTinyXML_patch=${fletch_SOURCE_DIR}/Patches/TinyXML
    -DTinyXML_source=${fletch_BUILD_PREFIX}/src/TinyXML
    -P ${fletch_SOURCE_DIR}/Patches/TinyXML/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${tinyxml_build_shared}
)

fletch_external_project_force_install(PACKAGE TinyXML)

set(TinyXML_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# TinyXML
########################################
set(TinyXML_ROOT \${fletch_ROOT})

set(fletch_ENABLED_TinyXML TRUE)
")
