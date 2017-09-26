
if (fletch_ENABLE_GFlags)
  list(APPEND GLog_pkg_ARGS -DWITH_GFLAGS:BOOL=ON)
  list(APPEND GLog_DEPENDS GFlags)
else()
  list(APPEND GLog_pkg_ARGS -DWITH_GFLAGS:BOOL=OFF)
endif()

ExternalProject_Add(GLog
  DEPENDS ${GLog_DEPENDS}
  URL ${GLog_file}
  URL_MD5 ${GLog_md5}
  DOWNLOAD_NAME ${GLog_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DGLog_patch:PATH=${fletch_SOURCE_DIR}/Patches/GLog
    -DGLog_source:PATH=${fletch_BUILD_PREFIX}/src/GLog
    -P ${fletch_SOURCE_DIR}/Patches/GLog/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${GLog_pkg_ARGS}
  )

fletch_external_project_force_install(PACKAGE GLog)

set(GLog_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# GLog
#######################################
set(GLog_ROOT \${fletch_ROOT})
")
