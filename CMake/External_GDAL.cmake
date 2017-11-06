if (WIN32)
  set (_gdal_msvc_version )
  if (MSVC60)
    set(_gdal_msvc_version "1200")
  elseif(MSVC71)
    set(_gdal_msvc_version "1310")
  elseif(MSVC70)
    set(_gdal_msvc_version "1300")
  elseif(MSVC80)
    set(_gdal_msvc_version "1400")
  elseif(MSVC90)
    set(_gdal_msvc_version "1500")
  elseif(MSVC10)
    set(_gdal_msvc_version "1600")
  elseif(MSVC11)
    set(_gdal_msvc_version "1700")
  elseif(MSVC12)
    set(_gdal_msvc_version "1800")
  elseif(MSVC14)
    set(_gdal_msvc_version "1900")
  endif()


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

if (WIN32)

  if(fletch_ENABLE_PNG)
    set(_GDAL_ARGS_PNG)
    set(_GDAL_ARGS_PNG PNGDIR=${fletch_BUILD_INSTALL_PREFIX}/include PNG_LIB=${fletch_BUILD_INSTALL_PREFIX}/lib/libpng.lib)
    list(APPEND _GDAL_DEPENDS PNG)
  endif()

  if(fletch_ENABLE_libtiff)
    list(APPEND _GDAL_DEPENDS libtiff)
    set( _GDAL_TIFF_ARGS TIFF_INC=-I${fletch_BUILD_INSTALL_PREFIX}/include TIFF_LIB=${fletch_BUILD_INSTALL_PREFIX}/lib/tiff.lib)
  endif()

  if(fletch_ENABLE_libgeotiff)
    list(APPEND _GDAL_DEPENDS libgeotiff)
    set( _GDAL_GEOTIFF_ARGS GEOTIFF_INC=-I${fletch_BUILD_INSTALL_PREFIX}/include GEOTIFF_LIB=${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_i.lib)
  endif()

  # Here is where you add any new package related args for tiff, so we don't keep repeating them below.
  set (GDAL_PKG_ARGS  ${_GDAL_MSVC_ARGS_LTISDK} ${_GDAL_ARGS_PNG} ${_GDAL_TIFF_ARGS} ${_GDAL_GEOTIFF_ARGS})

  file(TO_NATIVE_PATH ${fletch_BUILD_INSTALL_PREFIX} _gdal_native_fletch_BUILD_INSTALL_PREFIX)
  ExternalProject_Add(GDAL
    DEPENDS ${_GDAL_DEPENDS}
    URL ${GDAL_file}
    URL_MD5 ${GDAL_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DGDAL_patch:PATH=${fletch_SOURCE_DIR}/Patches/GDAL
      -DGDAL_source:PATH=${fletch_BUILD_PREFIX}/src/GDAL
      -P ${fletch_SOURCE_DIR}/Patches/GDAL/Patch.cmake

    CONFIGURE_COMMAND ""

    BUILD_COMMAND nmake -f makefile.vc MSVC_VER=${_gdal_msvc_version} GDAL_HOME=${_gdal_native_fletch_BUILD_INSTALL_PREFIX} ${_gdal_msvc_win64_option} ${GDAL_PKG_ARGS}
    INSTALL_COMMAND nmake -f makefile.vc MSVC_VER=${_gdal_msvc_version} GDAL_HOME=${_gdal_native_fletch_BUILD_INSTALL_PREFIX} ${_gdal_msvc_win64_option} ${GDAL_PKG_ARGS} install
    COMMAND nmake -f makefile.vc MSVC_VER=${_gdal_msvc_version} GDAL_HOME=${_gdal_native_fletch_BUILD_INSTALL_PREFIX} ${_gdal_msvc_win64_option} ${GDAL_PKG_ARGS} devinstall
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
    set(_GDAL_ARGS_APPLE --without-libtool --with-netcdf=no --with-curl=no --with-local=/usr)
  endif()

  # The GDAL python build is sufficiently
  # touchy that default OFF is the only safe course of action.
  set(_GDAL_PYTHON_DEFAULT OFF)

  if (PYTHONINTERP_FOUND)
    option(fletch-GDAL_ENABLE_PYTHON "Build the GDAL Python bindings" ${_GDAL_PYTHON_DEFAULT})
  endif()

  if(fletch_ENABLE_ZLib)
    #If we're building libz, then use it.
    list(APPEND _GDAL_DEPENDS ZLib)
    set(_GDAL_ARGS_ZLIB "--with-libz=${ZLIB_ROOT}")
  endif()

  # For now, I don't see the need for postgresql support in GDAL. If it is required, just add
  # -with-pg=/path/to/pg_config
  set(_GDAL_ARGS_PG "--without-pg")

  if(fletch_ENABLE_PNG)
    list(APPEND _GDAL_DEPENDS PNG)
    set( _GDAL_PNG_ARGS --with-png=${fletch_BUILD_INSTALL_PREFIX})
  endif()

  if(fletch_ENABLE_libtiff)
    list(APPEND _GDAL_DEPENDS libtiff)
    set( _GDAL_TIFF_ARGS --with-libtiff=${libtiff_ROOT})
  endif()

  if(fletch_ENABLE_libgeotiff)
    list(APPEND _GDAL_DEPENDS libgeotiff)
    set( _GDAL_GEOTIFF_ARGS --with-geotiff=${libgeotiff_ROOT})
    find_program(env env)
    if (env STREQUAL env-NOTFOUND)
      message(FATAL_ERROR "env command not found !")
    endif()
    set(env_var LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${fletch_BUILD_INSTALL_PREFIX}/lib)
    set(GDAL_CONFIGURE_COMMAND ${env} ${env_var} ${GDAL_CONFIGURE_COMMAND})
  endif()

  #+
  # For now, we're only going to to support the GDAL python bindings on
  # non-windows platforms.
  #-
  if (fletch-GDAL_ENABLE_PYTHON)
      # Not supported yet
      set(_GDAL_ARGS_PYTHON --with-python=yes )
      set(_GDAL_PYTHON_PREFIX "PYTHON=${PYTHON_EXECUTABLE}")

      # The GDAL Python build is somewhat fussy.  Setting this (causing it
      # to ignore the installed setuptools) is the only way to convince it
      # to honor the "Prefix" settings we provide.
      set(_GDAL_PY_HAVE_SETUPTOOLS_ARG "PY_HAVE_SETUPTOOLS=0")

      find_python_site_packages(GDAL_PYTHON_SITE_PACKAGES ${fletch_BUILD_INSTALL_PREFIX} TRUE)
      if (NOT GDAL_PYTHON_SITE_PACKAGES)
          message(FATAL_ERROR "Could not find site-packages directory for GDAL python build")
      endif()

      file(MAKE_DIRECTORY ${GDAL_PYTHON_SITE_PACKAGES})
      set(_GDAL_PYTHON_PATH_PREFIX "PYTHONPATH=${GDAL_PYTHON_SITE_PACKAGES}")
   endif()

   # Here is where you add any new package related args for tiff, so we don't keep repeating them below.
   set (GDAL_PKG_ARGS
     ${_GDAL_ARGS_PYTHON} ${_GDAL_PNG_ARGS} ${_GDAL_GEOTIFF_ARGS} ${_GDAL_ARGS_PG}
     ${_GDAL_TIFF_ARGS} ${_GDAL_ARGS_SQLITE} ${_GDAL_ARGS_ZLIB} ${_GDAL_ARGS_LTIDSDK}
     --without-jasper
     )

   Fletch_Require_Make()
   ExternalProject_Add(GDAL
    DEPENDS ${_GDAL_DEPENDS}
    URL ${GDAL_file}
    URL_MD5 ${GDAL_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DGDAL_patch:PATH=${fletch_SOURCE_DIR}/Patches/GDAL
      -DGDAL_source:PATH=${fletch_BUILD_PREFIX}/src/GDAL
      -P ${fletch_SOURCE_DIR}/Patches/GDAL/Patch.cmake
    CONFIGURE_COMMAND ${GDAL_CONFIGURE_COMMAND} ${_GDAL_PYTHON_PREFIX} ${_GDAL_PYTHON_PATH_PREFIX} ./configure --with-jpeg12 --prefix=${fletch_BUILD_INSTALL_PREFIX} ${_GDAL_ARGS_APPLE} ${GDAL_PKG_ARGS}
    BUILD_COMMAND ${_GDAL_PYTHON_PREFIX} ${_GDAL_PYTHON_PATH_PREFIX} ${MAKE_EXECUTABLE} ${_GDAL_PY_HAVE_SETUPTOOLS_ARG}
    INSTALL_COMMAND ${_GDAL_PYTHON_PREFIX} ${_GDAL_PYTHON_PATH_PREFIX} ${MAKE_EXECUTABLE} ${_GDAL_PY_HAVE_SETUPTOOLS_ARG} install
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
")

