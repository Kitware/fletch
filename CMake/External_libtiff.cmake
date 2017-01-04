# libtiff External project

# We need -fPIC when building statically
if( UNIX AND NOT BUILD_SHARED_LIBS)
  set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)
endif()

# JPEG
add_package_dependency(
  PACKAGE libtiff
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
  )

# ZLIB
add_package_dependency(
  PACKAGE libtiff
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  )

if (WIN32)
  set (jpeg_lib_name "jpeg.lib")
  set (zlib_library_name "zlib.lib")
elseif (APPLE)
  set (jpeg_lib_name "libjpeg.dylib")
  set (zlib_library_name "libzlib.dylib")
else()
  set (jpeg_lib_name "libjpeg.so")
  set (zlib_library_name "libzlib.so")
endif()

if(NOT JPEG_FOUND)
  set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
  set(JPEG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${jpeg_lib_name})
endif()
list(APPEND libtiff_args
  -DJPEG_INCLUDE=${JPEG_INCLUDE_DIR}
  -DJPEG_LIBRARY=${JPEG_LIBRARY}
  )

if(NOT ZLIB_FOUND)
  set(ZLIB_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
  set(ZLIB_LIBRARY_DEBUG ${fletch_BUILD_INSTALL_PREFIX}/lib/${zlib_library_name})
endif()
list(APPEND libtiff_args
  -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIRS}
  -DZLIB_LIBRARY_DEBUG=${ZLIB_LIBRARY_DEBUG}
  -DZLIB_LIBRARY_RELEASE=${ZLIB_LIBRARY_DEBUG}
  )

ExternalProject_Add(libtiff
  DEPENDS ${libtiff_DEPENDS}
  URL ${libtiff_url}
  URL_MD5 ${libtiff_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibtiff_source:STRING=${fletch_BUILD_PREFIX}/src/libtiff
    -Dlibtiff_patch:STRING=${fletch_SOURCE_DIR}/Patches/libtiff
    -P ${fletch_SOURCE_DIR}/Patches/libtiff/Patch.cmake

  # Build with cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=TRUE
    ${libtiff_args}
  )


set(libtiff_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# libtiff
################################
set(libtiff_ROOT @libtiff_ROOT@)

set(fletch_ENABLED_libtiff TRUE)
")
