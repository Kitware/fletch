
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

# Latest libKML depends on boost.
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
  message(FATAL_ERROR "boost is required for libkml, please enable")
endif()

# Latest libKML depends on ZLib.
if(fletch_ENABLE_ZLib)
  set(libkml_use_external_zlib
	  -DLIBKML_USE_EXTERNAL_ZLIB:BOOL=ON
	  -DZLIB_ROOT:PATH=${ZLIB_ROOT}
    )
  set(_KML_DEPENDS ${_KML_DEPENDS} ZLib)
else()
  set(libkml_use_external_zlib
    -DLIBKML_USE_EXTERNAL_ZLIB:BOOL=OFF
    )
  message(FATAL_ERROR "zlib is required for libkml, please enable")
endif()

# Latest libKML depends on minizip.
if(fletch_ENABLE_minizip)
  set(libkml_use_external_minizip
          -DMINIZIP_ROOT=${MINIZIP_ROOT}
	  #-DMINIZIP_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
	  #-DMINIZIP_LIBRARIES=${fletch_BUILD_INSTALL_PREFIX}/lib
    )
  set(_KML_DEPENDS ${_KML_DEPENDS} minizip) 
else()
  message(FATAL_ERROR "minizip is required for libkml, please enable")
endif()

# Latest libKML depends on uriparser.
if(fletch_ENABLE_uriparser)
  set(libkml_use_external_uriparser
          -DURIPARSER_ROOT=${URIPARSER_ROOT}
	  #-DURIPARSER_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
	  #-DURIPARSER_LIBRARIES=${fletch_BUILD_INSTALL_PREFIX}/lib
    )
  set(_KML_DEPENDS ${_KML_DEPENDS} uriparser)
else()
  message(FATAL_ERROR "uriparser is required for libkml, please enable")
endif()

# Can't build libkml dynamic libs on APPLE
# see: https://github.com/libkml/libkml/issues/251

if(APPLE)
  set(extra_cmake_args -DBUILD_SHARED_LIBS=OFF)
else()
  set(extra_cmake_args -DBUILD_SHARED_LIBS=ON)
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
    ${libkml_use_external_zlib}
    ${libkml_use_external_minizip}
    ${libkml_use_external_uriparser}
    ${extra_cmake_args}
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

