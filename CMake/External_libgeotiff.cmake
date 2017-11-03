# The libgeotiff external project for fletch

# JPEG
add_package_dependency(
  PACKAGE libgeotiff
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
  OPTIONAL
)

# libgeotiff_WITH_* means it was either enabled or found. Dsicover which below.
if (libgeotiff_WITH_libjpeg-turbo)
  #Not FOUND means we enabled it explicitly
  if(NOT JPEG_FOUND)
    get_system_library_name(jpeg jpeg_lib)
    set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(JPEG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${jpeg_lib})
  endif()
  list(APPEND libgeotiff_pkg_args
    -DWITH_JPEG:BOOL=ON
    -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
    -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
    )
else()
  # We aren't using JPEG, disable it.
  list(APPEND libgeotiff_pkg_args -DWITH_JPEG:BOOL=OFF)
endif()

if (NOT fletch_ENABLE_PROJ4)
  message(FATAL " You must enable PROJ4 from fletch to build libgeotiff. There are issues with the system version")
endif()

# Proj4
add_package_dependency(
  PACKAGE libgeotiff
  PACKAGE_DEPENDENCY PROJ4
  OPTIONAL
)

# libgeotiff_WITH_* means it was either enabled or found. Dsicover which below.
if (libgeotiff_WITH_PROJ4)
  #Not FOUND means we enabled it explicitly
  if(NOT PROJ4_FOUND)
    set(PROJ4_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    get_system_library_name(proj proj_lib)
    set(PROJ4_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${proj_lib})
  endif()
  list(APPEND libgeotiff_pkg_args
    -DWITH_PROJ4:BOOL=ON
    -DPROJ4_INCLUDE_DIR:PATH=${PROJ4_INCLUDE_DIRS}
    -DPROJ4_LIBRARY:PATH=${PROJ4_LIBRARY}
    )
else()
  # We aren't using PROJ, disable it.
  list(APPEND libgeotiff_pkg_args -DWITH_PROJ4:BOOL=OFF)
endif()

# ZLIB
add_package_dependency(
  PACKAGE libgeotiff
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  OPTIONAL
)
if (libgeotiff_WITH_zlib)
  if(NOT ZLIB_FOUND)
    get_system_library_name(zlib zlib_lib)
    set(ZLIB_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(ZLIB_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${zlib_lib})
  endif()
  list(APPEND libgeotiff_pkg_args
    -DWITH_ZLIB:BOOL=ON
    -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
    -DZLIB_LIBRARY:PATH=${ZLIB_LIBRARY}
    )
else()
  list(APPEND libgeotiff_pkg_args -DWITH_ZLIB:BOOL=OFF)
endif()

# libtiff
add_package_dependency(
  PACKAGE libgeotiff
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
  OPTIONAL
)

if (libgeotiff_WITH_libtiff)
  if(NOT TIFF_FOUND)
    get_system_library_name(tiff tiff_lib)
    set(TIFF_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(TIFF_LIBRARY_DEBUG ${fletch_BUILD_INSTALL_PREFIX}/lib/${tiff_lib})
    set(TIFF_LIBRARY_RELEASE ${fletch_BUILD_INSTALL_PREFIX}/lib/${tiff_lib})
  endif()

  list(APPEND libgeotiff_pkg_args
    -DWITH_TIFF:BOOL=ON
    -DTIFF_INCLUDE_DIR:PATH=${TIFF_INCLUDE_DIR}
    -DTIFF_LIBRARY_DEBUG:FILEPATH=${TIFF_LIBRARY_DEBUG}
    -DTIFF_LIBRARY_RELEASE:FILEPATH=${TIFF_LIBRARY_RELEASE}
    )
else()
  list(APPEND libgeotiff_pkg_args -DWITH_TIFF:BOOL=OFF)
endif()


#
# libgeotiff
#
ExternalProject_Add(libgeotiff
  DEPENDS ${libgeotiff_DEPENDS}
  URL ${libgeotiff_file}
  URL_MD5 ${libgeotiff_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    ${libgeotiff_pkg_args}
    )

  if(WIN32)
    # Copy libgeotiff_d_i to libgeotiff_i for GDAL
    ExternalProject_Add_Step(libgeotiff fixup-install
      COMMAND ${CMAKE_COMMAND}
      -Dfletch_BUILD_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -P ${fletch_SOURCE_DIR}/Patches/libgeotiff/fixup_install.cmake
      DEPENDEES install
      )
  endif()

  set(libgeotiff_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
  file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libgeotiff
########################################
set(libgeotiff_ROOT \${fletch_ROOT})
")
