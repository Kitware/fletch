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

if(WIN32)
  set(libtiff_nmake_args
    JPEG_SUPPORT=1
    ZIP_SUPPORT=1
    )

  if(NOT JPEG_FOUND)
    set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(JPEG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/jpeg.lib)
  endif()
  set(libtiff_nmake_args
    JPEG_INCLUDE=-I${JPEG_INCLUDE_DIR}
    JPEG_LIB=${JPEG_LIBRARY}
    ${libtiff_nmake_args}
    )

  if(NOT ZLIB_FOUND)
    set(ZLIB_INCLUDE_DIRS ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(ZLIB_LIBRARIES ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib)
  endif()
  set(libtiff_nmake_args
    ZLIB_INCLUDE=-I${ZLIB_INCLUDE_DIRS}
    ZLIB_LIB=${ZLIB_LIBRARIES}
    ${libtiff_nmake_args}
    )

  ExternalProject_Add(libtiff
    DEPENDS ${libtiff_DEPENDS}
    URL ${libtiff_url}
    URL_MD5 ${libtiff_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    DOWNLOAD_COMMAND ${libtiff_download_command}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    # Build with nmake
    BUILD_COMMAND nmake -f Makefile.vc clean
          COMMAND nmake -f Makefile.vc ${libtiff_nmake_args}
    # Custom install
    INSTALL_COMMAND ${CMAKE_COMMAND}
      -DBUILD_DIR:PATH=${fletch_BUILD_PREFIX}/src/libtiff
      -DINSTALL_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -P ${fletch_SOURCE_DIR}/Patches/libtiff/Install.cmake
    )

else()
  # variables to configure libtiff
  set(libtiff_configure_args)

  # JPEG
  if (fletch_ENABLE_libjpeg-turbo)
    set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(JPEG_LIBRARY_PATH ${fletch_BUILD_INSTALL_PREFIX}/lib)
  else()
    get_filename_component(JPEG_LIBRARY_PATH JPEG_LIBRARY PATH)
  endif()
  set(libtiff_configure_args ${libtiff_configure_args}
    "--with-jpeg-include-dir=${JPEG_INCLUDE_DIR}"
    "--with-jpeg-lib-dir=${JPEG_LIBRARY_PATH}"
    )

  if (fletch_ENABLE_ZLib)
    set(ZLIB_INCLUDE_DIRS ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(ZLIB_LIBRARY_PATH ${fletch_BUILD_INSTALL_PREFIX}/lib)
  else()
    get_filename_component(ZLIB_LIBRARY_PATH ZLIB_LIBRARY PATH)
  endif()
  set(libtiff_configure_args ${libtiff_configure_args}
      "--with-zlib-include-dir=${ZLIB_INCLUDE_DIRS}"
      "--with-zlib-lib-dir=${ZLIB_LIBRARY_PATH}"
      )

  Fletch_Require_Make()
  ExternalProject_Add(libtiff
    DEPENDS ${libtiff_DEPENDS}
    URL ${libtiff_url}
    URL_MD5 ${libtiff_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
      ${libtiff_configure_args}

    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )
endif()

set(libtiff_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# libtiff
################################
set(libtiff_ROOT @libtiff_ROOT@)
")
