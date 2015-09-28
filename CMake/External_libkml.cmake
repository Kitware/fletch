
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
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibkml_patch:PATH=${fletch_SOURCE_DIR}/Patches/libkml
    -Dlibkml_source:PATH=${fletch_BUILD_PREFIX}/src/libkml
    -P ${fletch_SOURCE_DIR}/Patches/libkml/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    ${libkml_use_external_expat}
    ${libkml_use_external_boost}
)

set(LIBKML_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "" FORCE)
set(LIBKML_LIBNAME kml)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libkml
########################################
set(LIBKML_ROOT    @LIBKML_ROOT@)
set(LIBKML_LIBNAME @LIBKML_LIBNAME@)

set(fletch_ENABLED_libml TRUE)
")

