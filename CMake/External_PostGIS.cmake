if(WIN32)
  message(FATAL_ERROR "PostGIS build is not currently support on Windows")
endif()

if(fletch_ENABLE_PROJ)
  set(_PostGIS_ARGS_PROJ --with-projdir=${PROJ_ROOT})
  list(APPEND _PostGIS_DEPENDS PROJ)
else()
  find_package(PROJ4 REQUIRED)
endif()

if(fletch_ENABLE_GEOS)
  set(_PostGIS_ARGS_GEOS --with-geosconfig=${GEOS_ROOT}/bin/geos-config)
  list(APPEND _PostGIS_DEPENDS GEOS)
else()
  find_program(_GEOS_CONFIG geos-config)
  if(NOT _GEOS_CONFIG)
    message(FATAL_ERROR "Unable to find a suitable GEOS.")
  endif()
  set(_PostGIS_ARGS_GEOS --with-geosconfig=${_GEOS_CONFIG})
endif()

if(fletch_ENABLE_PostgreSQL)
  set(_PostGIS_ARGS_PostgreSQL --with-pgconfig=${PostgreSQL_ROOT}/bin/pg_config)
  list(APPEND _PostGIS_DEPENDS PostgreSQL)
else()
  find_program(_PostgreSQL_CONFIG pg_config)
  if(NOT PostgreSQL_FOUND)
    message(FATAL_ERROR "Unable to find a suitable PostgreSQL.")
  endif()
  set(_PostGIS_ARGS_PostgreSQL --with-pgconfig=${_PostgreSQL_CONFIG})
endif()

if(fletch_ENABLE_libxml2)
  set(_PostGIS_ARGS_LIBXML2 "--with-xml2config=${LIBXML2_ROOT}/bin/xml2-config")
  list(APPEND _PostGIS_DEPENDS libxml2)
else()
  find_program(_libxml2_config xml2-config)
  if(NOT _libxml2_config)
    message(FATAL_ERROR "Unable to find a suitable libxml2. Please enable libxml2 project")
  endif()
  set(_PostGIS_ARGS_LIBXML2 --with-xml2config=${_libxml2_config})
endif()

# When raster support is desired in PostGIS (i.e. when enabling OSM2PGSQL), one
# can populate the args with --with-gdalconfig=/path-to-gdal
if (fletch_ENABLE_GDAL)
  set(_PostGIS_ARGS_GDAL --with-gdalconfig=${GDAL_ROOT}/bin/gdal-config)
  list(APPEND _PostGIS_DEPENDS GDAL)
else()
  find_program(_gdal_config gdal-config)
  if (NOT _gdal_config)
    message(ERROR " GDAL is required to build PostGIS with raster support. Please enable or install." )
  else()
    set(_PostGIS_ARGS_GDAL --with-gdalconfig=${_gdal_config})
  endif()
endif()

set(_PostGIS_CONFIGURE_COMMAND
  ./configure
  --prefix=${fletch_BUILD_INSTALL_PREFIX}
  ${_PostGIS_ARGS_PROJ}
  ${_PostGIS_ARGS_GEOS}
  ${_PostGIS_ARGS_PostgreSQL}
  ${_PostGIS_ARGS_GDAL}
  ${_PostGIS_ARGS_LIBXML2}
  --without-json
  )


# PostGIS with GDAL uses one of GDAL's functions.
# GDAL might be unable to find LTIDSDK and cause to fail its
# configuration. Adding the library path solves this.
if( fletch_ENABLE_GDAL )
  find_program(env env)
  if (env STREQUAL env-NOTFOUND)
    message(FATAL_ERROR "env command not found !")
  endif()
  set(env_var LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${fletch_BUILD_INSTALL_PREFIX}/lib)
  set(_PostGIS_CONFIGURE_COMMAND ${env} ${env_var} ${_PostGIS_CONFIGURE_COMMAND})
endif()

Fletch_Require_Make()
ExternalProject_Add(PostGIS
  DEPENDS ${_PostGIS_DEPENDS}
  URL ${PostGIS_file}
  URL_MD5 ${PostGIS_md5}
  ${COMMON_EP_ARGS}
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ${_PostGIS_CONFIGURE_COMMAND}
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )

# PostGIS doesn't have any library components to search for so no additions
# to the Config.cmake file
