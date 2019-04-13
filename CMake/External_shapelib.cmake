
ExternalProject_Add(shapelib
  DEPENDS ${_SHAPE_DEPENDS}
  URL ${shapelib_url}
  URL_MD5 ${shapelib_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  BUILD_IN_SOURCE 1
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
)

fletch_external_project_force_install(PACKAGE shapelib)

set(SHAPELIB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(SHAPELIB_LIBNAME shp)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# shapelib
########################################
set(SHAPELIB_ROOT    \${fletch_ROOT})
set(SHAPELIB_LIBNAME @SHAPELIB_LIBNAME@)

set(fletch_ENABLED_shapelib TRUE)
")
