
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
    ${COMMON_CMAKE_ARGS}
    #GeographicLIb cannot build with standard 98 anymore. Force 11
    -DCMAKE_CXX_STANDARD:STRING=11
)

fletch_external_project_force_install(PACKAGE GeographicLib)

set(GeographicLib_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GeographicLib
########################################
set(GeographicLib_ROOT \${fletch_ROOT})

set(fletch_ENABLED_GeographicLib TRUE)
")
