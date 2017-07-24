
ExternalProject_Add(shapelib
  DEPENDS ${_SHAPE_DEPENDS}
  URL ${shapelib_url}
  URL_MD5 ${shapelib_md5}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  BUILD_IN_SOURCE 1

  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dshapelib_patch=${fletch_SOURCE_DIR}/Patches/shapelib
    -Dshapelib_source=${fletch_BUILD_PREFIX}/src/shapelib
    -P ${fletch_SOURCE_DIR}/Patches/shapelib/Patch.cmake

  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
)

fletch_external_project_force_install(PACKAGE shapelib)

set(SHAPELIB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(SHAPELIB_LIBNAME shp)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# shapelib
########################################
set(SHAPELIB_ROOT    \$\{fletch_ROOT\})
set(SHAPELIB_LIBNAME @SHAPELIB_LIBNAME@)

set(fletch_ENABLED_shapelib TRUE)
")
