
ExternalProject_Add(GEOS
  URL ${GEOS_file}
  URL_MD5 ${GEOS_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DGEOS_patch:PATH=${fletch_SOURCE_DIR}/Patches/GEOS
    -DGEOS_source:PATH=${fletch_BUILD_PREFIX}/src/GEOS
    -P ${fletch_SOURCE_DIR}/Patches/GEOS/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DGEOS_ENABLE_MACOSX_FRAMEWORK:BOOL=OFF
    -BUILD_TESTING:BOOL=OFF
    -DGEOS_ENABLE_TESTS:BOOL=OFF
)

set(GEOS_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

if (WIN32)
  set(GEOS_C_LIBRARY "${GEOS_ROOT}/lib/geos_c.lib")
elseif(NOT APPLE)
  set(GEOS_C_LIBRARY "${GEOS_ROOT}/lib/libgeos_c.so")
else()
  set(GEOS_C_LIBRARY "${GEOS_ROOT}/lib/libgeos_c.dylib")
endif()


file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GEOS
########################################
set(GEOS_ROOT \${fletch_ROOT})
set(GEOS_C_LIBRARY @GEOS_C_LIBRARY@)
")
