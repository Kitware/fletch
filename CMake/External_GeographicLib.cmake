
# The GeographicLib external project for fletch
ExternalProject_Add(GeographicLib
  URL ${GeographicLib_file}
  URL_MD5 ${GeographicLib_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
     -DGeographicLib_patch=${fletch_SOURCE_DIR}/Patches/GeographicLib
     -DGeographicLib_source=${fletch_BUILD_PREFIX}/src/GeographicLib
     -P ${fletch_SOURCE_DIR}/Patches/GeographicLib/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DBUILD_SHARED_LIBS:BOOL="${BUILD_SHARED_LIBS}"
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
)

set(GeographicLib_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GeographicLib
########################################
set(GeographicLib_ROOT @GeographicLib_ROOT@)
")
