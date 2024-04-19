
# TinyXML must be static on Windows since they provide no exports
if (WIN32)
  set(tinyxml2_build_shared FALSE)
else()
  set(tinyxml2_build_shared TRUE)
endif()

ExternalProject_Add(TinyXML2
  URL ${TinyXML2_url}
  URL_MD5 ${TinyXML2_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${tinyxml2_build_shared}
)

fletch_external_project_force_install(PACKAGE TinyXML2)

set(TinyXML2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# TinyXML
########################################
set(TinyXML2_ROOT \${fletch_ROOT})

set(fletch_ENABLED_TinyXML2 TRUE)
")
