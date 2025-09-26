
# If a patch file exists for this version, apply it
set (GDAL_patch ${fletch_SOURCE_DIR}/Patches/GDAL/${GDAL_SELECT_VERSION})
if (EXISTS ${GDAL_patch})
  set(GDAL_PATCH_COMMAND ${CMAKE_COMMAND}
    -DGDAL_patch:PATH=${GDAL_patch}
    -DGDAL_source:PATH=${fletch_BUILD_PREFIX}/src/GDAL
    -P ${GDAL_patch}/Patch.cmake
    )
endif()

if (WIN32)
  set(_gdal_msvc_win64_option )
  include(CheckTypeSize)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)  # 64 Bits
    set(_gdal_msvc_win64_option "WIN64=YES")
  endif()
endif()


# We will allow a user to pass in the unpacked MrSID files in fletch_LTIDSDK_ROOT
if(fletch_LTIDSDK_ROOT)
  set(_GDAL_ARGS_LTIDSDK --with-mrsid=${fletch_LTIDSDK_ROOT} --with-jp2mrsid=yes)
  set(_GDAL_MSVC_ARGS_LTISDK MRSID_DIR=${fletch_LTIDSDK_ROOT} MRSID_JP2=YES)
endif()

if (GDAL_SELECT_VERSION VERSION_GREATER_EQUAL 3.5)
  if (NOT UNIX)
    message(ERROR "Fletch currenly only supports building GDAL Version \"${GDAL_SELECT_VERSION}\" for Linux.")
  else()
    if(fletch_ENABLE_PROJ)
      set(_GDAL_ARGS_PROJ
        -DPROJ_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/proj
        )
      list(APPEND _GDAL_DEPENDS PROJ)
    else()
      find_package(PROJ REQUIRED)
    endif()

    Fletch_Require_Make()
    ExternalProject_Add(GDAL
      DEPENDS ${_GDAL_DEPENDS}
      URL ${GDAL_file}
      URL_MD5 ${GDAL_md5}
      ${COMMON_EP_ARGS}
        CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        ${_GDAL_ARGS_PROJ}
        -DCMAKE_CXX_STANDARD=17
      )
  endif()

elseif (WIN32)
  if(fletch_ENABLE_PNG)
    set(_GDAL_ARGS_PNG)
    set(_GDAL_ARGS_PNG PNGDIR=${fletch_BUILD_INSTALL_PREFIX}/include PNG_LIB=${PNG_LIBRARY})
    list(APPEND _GDAL_DEPENDS PNG)
  endif()

  if(fletch_ENABLE_libtiff)
    list(APPEND _GDAL_DEPENDS libtiff)
    set( _GDAL_TIFF_ARGS TIFF_INC=-I${fletch_BUILD_INSTALL_PREFIX}/include TIFF_LIB=${TIFF_LIBRARY})
  endif()

  if(fletch_ENABLE_libgeotiff)
    list(APPEND _GDAL_DEPENDS libgeotiff)
    set( _GDAL_GEOTIFF_ARGS GEOTIFF_INC=-I${fletch_BUILD_INSTALL_PREFIX}/include GEOTIFF_LIB=${libgeotiff_LIBRARY})
  endif()

  if(fletch_ENABLE_GEOS)
    list(APPEND _GDAL_DEPENDS GEOS)
    set( _GDAL_GEOS_ARGS GEOS_INC=-I${fletch_BUILD_INSTALL_PREFIX}/include GEOS_LIB=${GEOS_C_LIBRARY})
  endif()

  # Here is where you add any new package related args for tiff, so we don't keep repeating them below.
  set (GDAL_PKG_ARGS  ${_GDAL_MSVC_ARGS_LTISDK} ${_GDAL_ARGS_PNG}
                      ${_GDAL_TIFF_ARGS} ${_GDAL_GEOTIFF_ARGS}
                      ${_GDAL_GEOS_ARGS})
  file(TO_NATIVE_PATH ${fletch_BUILD_INSTALL_PREFIX} _gdal_native_fletch_BUILD_INSTALL_PREFIX)
  set (GDAL_ARGS MSVC_VER=${MSVC_VERSION}
    DATADIR=${_gdal_native_fletch_BUILD_INSTALL_PREFIX}\\share\\gdal
    GDAL_HOME=${_gdal_native_fletch_BUILD_INSTALL_PREFIX}
    ${_gdal_msvc_win64_option}
    ${GDAL_PKG_ARGS}
    )

  ExternalProject_Add(GDAL
    DEPENDS ${_GDAL_DEPENDS}
    URL ${GDAL_file}
    URL_MD5 ${GDAL_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${GDAL_PATCH_COMMAND}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND nmake -f makefile.vc ${GDAL_ARGS}
    INSTALL_COMMAND nmake -f makefile.vc ${GDAL_ARGS} install
    COMMAND nmake -f makefile.vc ${GDAL_ARGS} devinstall
    )
else()

  if(APPLE)
    # Builds fail on Mavericks when using libtool.
    # GDAL's build finds system versions of netcdf and curl but doesn't check the version until
    # runtime at which point things go bad fast.
    #
    # Also set '--with-local=/usr' to force selection of /usr/lib/libiconv over e.g. /opt/local/lib
    # from macports.  GDAL's '--with-libiconv-prefix' option looks like it should handle
    # this but in fact seems to do nothing.
    #
    # Note: previously this var disabled curl and netcdf which are now handled
    # by _GDAL_ARGS_UNSUPPORTED
    set(_GDAL_ARGS_APPLE --without-libtool --with-local=/usr)
  else ()
    list(INSERT GDAL_CONFIGURE_COMMAND 0
      LDFLAGS=-Wl,-rpath,<INSTALL_DIR>/lib)
  endif()

  # GDAL uses a configure based build system, so its important to disable
  # anything that is not explicitly built or provided through fletch. If these
  # are not disabled then it may find a system version of these libs. If the
  # system also includes a conflicting version of another library provided by
  # fletch, that can cause errors. For example, if you have a conda environment
  # with curl and proj, just by adding curl to the include search paths, GDAL
  # will ignore the fletch version of proj (even though we do specify it
  # explicitly here) and use the conda version.
  set(_GDAL_ARGS_UNSUPPORTED --with-curl=no --with-netcdf=no --with-kea=no)

  if(fletch_ENABLE_ZLib)
    #If we're building libz, then use it.
    list(APPEND _GDAL_DEPENDS ZLib)
    set(_GDAL_ARGS_ZLIB "--with-libz=${ZLIB_ROOT}")
  endif()

  if(fletch_ENABLE_PROJ)
    #If we're building libproj, then use it.
    list(APPEND _GDAL_DEPENDS PROJ )
    set(_GDAL_ARGS_PROJ "--with-proj=${PROJ_ROOT}")
  endif()

  # For now, I don't see the need for postgresql support in GDAL. If it is required, just add
  # -with-pg=/path/to/pg_config
  set(_GDAL_ARGS_PG "--without-pg")

  if(fletch_ENABLE_PNG)
    list(APPEND _GDAL_DEPENDS PNG)
    set( _GDAL_PNG_ARGS --with-png=${fletch_BUILD_INSTALL_PREFIX})
    set( _GDAL_PKG_CONFIG_PATH "PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig" )
  endif()

  if(fletch_ENABLE_libtiff)
    list(APPEND _GDAL_DEPENDS libtiff)
    set( _GDAL_TIFF_ARGS --with-libtiff=${libtiff_ROOT})
    set( _GDAL_PKG_CONFIG_PATH "PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig" )
  endif()

  if(fletch_ENABLE_libgeotiff)
    list(APPEND _GDAL_DEPENDS libgeotiff)
    set( _GDAL_GEOTIFF_ARGS --with-geotiff=${libgeotiff_ROOT})
    set(env ${CMAKE_COMMAND} -E env)
    set(env_var LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${fletch_BUILD_INSTALL_PREFIX}/lib)
    set(GDAL_CONFIGURE_COMMAND ${env} ${env_var} ${GDAL_CONFIGURE_COMMAND})
  endif()

  if(fletch_ENABLE_libxml2)
    list(APPEND _GDAL_DEPENDS libxml2)
    set(_GDAL_ARGS_XML2 "--with-xml2=${LIBXML2_ROOT}/bin/xml2-config")
  endif()

  if(fletch_ENABLE_GEOS)
    list(APPEND _GDAL_DEPENDS GEOS)
    set( _GDAL_GEOS_ARGS "--with-geos=${GEOS_ROOT}")
  else()
    # TODO: should we allow use of system geos?
    set(_GDAL_GEOS_ARGS --with-geos=no)
  endif()

  # GDAL has a tendency to pick up old libkml versions and fail.
  #   Thus, disable GDAL with libkml.
  set(_GDAL_ARGS_libKML "--with-libkml=no")

  #+
  # GDAL Python dosen't work well for GDAL 1, nor does it work well on Apple at the moment
  #-
  if (NOT APPLE AND fletch_BUILD_WITH_PYTHON AND NOT GDAL_SELECT_VERSION VERSION_LESS 2.0)
    if (fletch_ENABLE_CPython)
      list(APPEND _GDAL_DEPENDS CPython)
    endif()
    set(_GDAL_ARGS_PYTHON --with-python=${PYTHON_EXECUTABLE} )
  endif()

  if (GDAL_SELECT_VERSION VERSION_LESS 2.0)
    list( APPEND _GDAL_ARGS_UNSUPPORTED --with-libjson-c=internal )
  endif()

  # If we're not using LTIDSDK and we are building openjpeg, use that for jpeg2k decoding
  # OpenJPEG support is not valid for GDAL 1, it requires an older version than we provide.
  if (fletch_ENABLE_openjpeg AND NOT fletch_LTIDSDK_ROOT AND NOT GDAL_SELECT_VERSION VERSION_LESS 2.0)
    set(JPEG_ARG "--with-openjpeg=${openjpeg_ROOT}")
    list(APPEND _GDAL_DEPENDS openjpeg)
    set( _GDAL_PKG_CONFIG_PATH "PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig" )
  else()
    set(JPEG_ARG "--without-openjpeg")
  endif()

  # Here is where you add any new package related args for tiff, so we don't keep repeating them below.
  set (GDAL_PKG_ARGS
    ${_GDAL_ARGS_PYTHON} ${_GDAL_PNG_ARGS} ${_GDAL_GEOTIFF_ARGS} ${_GDAL_ARGS_PG}
    ${_GDAL_ARGS_PROJ} ${_GDAL_ARGS_XML2} ${_GDAL_TIFF_ARGS} ${_GDAL_ARGS_SQLITE}
    ${_GDAL_ARGS_ZLIB} ${_GDAL_ARGS_LTIDSDK} ${JPEG_ARG} ${_GDAL_ARGS_libKML}
    ${_GDAL_GEOS_ARGS} ${_GDAL_ARGS_UNSUPPORTED} --without-jasper
    )


  Fletch_Require_Make()
  ExternalProject_Add(GDAL
    DEPENDS ${_GDAL_DEPENDS}
    URL ${GDAL_file}
    URL_MD5 ${GDAL_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${GDAL_PATCH_COMMAND}
    CONFIGURE_COMMAND ${GDAL_CONFIGURE_COMMAND} ${_GDAL_PKG_CONFIG_PATH} ./configure --with-jpeg12 --prefix=${fletch_BUILD_INSTALL_PREFIX} ${_GDAL_ARGS_APPLE} ${GDAL_PKG_ARGS}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
endif()

fletch_external_project_force_install(PACKAGE GDAL)

set(GDAL_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GDAL
########################################
set(GDAL_ROOT    \${fletch_ROOT})
set(ENV{GDAL_ROOT} \${fletch_ROOT})
set(fletch_ENABLED_GDAL TRUE)
")
