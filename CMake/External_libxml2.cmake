
if(APPLE)
  set(_libxml2_args_pthreads --without-threads)
endif()

Fletch_Require_Make()
ExternalProject_Add(libxml2
  DEPENDS ${_XML2_DEPENDS}
  URL ${libxml2_url}
  URL_MD5 ${libxml2_md5}
  ${COMMON_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibxml2_patch:PATH=${fletch_SOURCE_DIR}/Patches/libxml2
    -Dlibxml2_source:PATH=${fletch_BUILD_PREFIX}/src/libxml2
    -P ${fletch_SOURCE_DIR}/Patches/libxml2/Patch.cmake
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    ${_libxml2_args_pthreads}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
)

fletch_external_project_force_install(PACKAGE libxml2)

set(LIBXML2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(LIBXML2_LIBNAME xml2)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libxml2
########################################
set(LIBXML2_ROOT    \${fletch_ROOT})
set(LIBXML2_LIBNAME @LIBXML2_LIBNAME@)

set(fletch_ENABLED_libxml2 TRUE)
")
