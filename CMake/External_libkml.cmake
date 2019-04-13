
# Use the expat library that comes with Unix systems, else go ahead and build
# it on windows.
if(WIN32)
  set(libkml_use_external_expat
    -DLIBKML_USE_EXTERNAL_EXPAT:BOOL=OFF
    )
else()
  set(libkml_use_external_expat
    -DLIBKML_USE_EXTERNAL_EXPAT:BOOL=ON
    )
endif()

# If we're building Boost, use that one.
if(fletch_ENABLE_Boost)
  set(libkml_use_external_boost
    -DLIBKML_USE_EXTERNAL_BOOST:BOOL=ON
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    )
  set(_KML_DEPENDS ${_KML_DEPENDS} Boost)
else()
  set(libkml_use_external_boost
    -DLIBKML_USE_EXTERNAL_BOOST:BOOL=OFF
    )
endif()

ExternalProject_Add(libkml
  DEPENDS ${_KML_DEPENDS}
  URL ${libkml_url}
  URL_MD5 ${libkml_md5}
  DOWNLOAD_NAME ${libkml_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibkml_patch:PATH=${fletch_SOURCE_DIR}/Patches/libkml
    -Dlibkml_source:PATH=${fletch_BUILD_PREFIX}/src/libkml
    -P ${fletch_SOURCE_DIR}/Patches/libkml/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${libkml_use_external_expat}
    ${libkml_use_external_boost}
)

fletch_external_project_force_install(PACKAGE libkml)

set(KML_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "" FORCE)
set(KML_DIR "${fletch_BUILD_INSTALL_PREFIX}/lib/cmake" CACHE PATH "" FORCE)
set(KML_LIBNAME kml)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libkml
########################################
set(KML_ROOT    \${fletch_ROOT})
set(KML_DIR     \${fletch_ROOT}/lib/cmake)
set(KML_LIBNAME @KML_LIBNAME@)

set(fletch_ENABLED_libkml TRUE)
")

