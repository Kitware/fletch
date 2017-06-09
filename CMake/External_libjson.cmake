
# libjson must be static on Windows since they provide no exports
if (WIN32)
  set(json_build_shared FALSE)
else()
  set(json_build_shared TRUE)
endif()

# The libjson external project for fletch
ExternalProject_Add(libjson
  URL ${libjson_url}
  URL_MD5 ${libjson_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibjson_source:STRING=${fletch_BUILD_PREFIX}/src/libjson
    -Dlibjson_patch:STRING=${fletch_SOURCE_DIR}/Patches/libjson
    -P ${fletch_SOURCE_DIR}/Patches/libjson/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${json_build_shared}
)

fletch_external_project_force_install(PACKAGE libjson)

set(LIBJSON_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(LIBJSON_LIBNAME json)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libjson
########################################
set(LIBJSON_ROOT    @LIBJSON_ROOT@)
set(LIBJSON_LIBNAME @LIBJSON_LIBNAME@)

set(fletch_ENABLED_libjson TRUE)
")

