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
  if(BUILD_SHARED_LIBS)
    set (jpeg_lib_name "libjpeg.so")
    set (zlib_library_name "libzlib.so")
  else()
    set (jpeg_lib_name "libjpeg.a")
    set (zlib_library_name "libz.a")
  endif()
endif()

if(libtiff_WITH_libjpeg-turbo AND NOT JPEG_FOUND)
  set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
  set(JPEG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${jpeg_lib_name})
endif()
list(APPEND libtiff_args
  -DJPEG_INCLUDE=${JPEG_INCLUDE_DIR}
  -DJPEG_LIBRARY=${JPEG_LIBRARY}
  )

if(libtiff_WITH_ZLIB AND NOT ZLIB_FOUND)
  set(ZLIB_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
  set(ZLIB_LIBRARY_DEBUG ${fletch_BUILD_INSTALL_PREFIX}/lib/${zlib_library_name})
endif()
list(APPEND libtiff_args
  -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIRS}
  -DZLIB_LIBRARY_DEBUG=${ZLIB_LIBRARY_DEBUG}
  -DZLIB_LIBRARY_RELEASE=${ZLIB_LIBRARY_DEBUG}
  )

option(libtiff_ENABLE_OPENGL "" ON)
mark_as_advanced(libtiff_ENABLE_OPENGL)
list(APPEND libtiff_args "-DENABLE_OPENGL:BOOL=${libtiff_ENABLE_OPENGL}")

ExternalProject_Add(libtiff
  DEPENDS ${libtiff_DEPENDS}
  URL ${libtiff_url}
  URL_MD5 ${libtiff_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibtiff_source:STRING=${fletch_BUILD_PREFIX}/src/libtiff
    -Dlibtiff_patch:STRING=${fletch_SOURCE_DIR}/Patches/libtiff
    -P ${fletch_SOURCE_DIR}/Patches/libtiff/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    ${libtiff_args}
  )

fletch_external_project_force_install(PACKAGE libtiff)

set(libtiff_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
get_system_library_name(tiff tiff_libname)
set(TIFF_LIBRARY "${fletch_BUILD_INSTALL_PREFIX}/lib/${tiff_libname}")

file(APPEND ${fletch_CONFIG_INPUT} "
################################
# libtiff
################################
set(libtiff_ROOT \${fletch_ROOT})

set(fletch_ENABLED_libtiff TRUE)
")
