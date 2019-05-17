
# If a patch file exists for this version, apply it
set (PDAL_patch ${fletch_SOURCE_DIR}/Patches/PDAL/${PDAL_version})
if (EXISTS ${PDAL_patch})
  set(PDAL_PATCH_COMMAND ${CMAKE_COMMAND}
    -DPDAL_patch:PATH=${PDAL_patch}
    -DPDAL_source:PATH=${fletch_BUILD_PREFIX}/src/PDAL
    -P ${PDAL_patch}/Patch.cmake
    )
endif()


# Set GDAL dependency
if (fletch_ENABLE_GDAL)
  message(STATUS "PDAL depending on internal GDAL")
  list(APPEND PDAL_DEPENDS GDAL)
else()
  message(FATAL_ERROR "GDAL is required for PDAL, please enable")
endif()

# Set GeoTiff dependency
if (fletch_ENABLE_libgeotiff)
  message(STATUS "PDAL depending on internal libgeotiff")
  list(APPEND PDAL_DEPENDS libgeotiff)
else()
  message(FATAL_ERROR "libgeotiff is required for PDAL, please enable")
endif()

# Set Proj.4 dependency
if (fletch_ENABLE_PROJ4)
  message(STATUS "PDAL depending on internal PROJ4")
  list(APPEND PDAL_DEPENDS PROJ4)
else()
  message(FATAL_ERROR "PROJ4 is required for PDAL, please enable")
endif()

# Set libxml2 dependency
if (fletch_ENABLE_libxml2)
  message(STATUS "PDAL depending on internal libxml2")
  list(APPEND PDAL_DEPENDS libxml2)
else()
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
         -DBUILD_PLUGIN_PGPOINTCLOUD:BOOL=OFF
      )
endif()

# Set GEOS dependency
if (fletch_ENABLE_GEOS)
  message(STATUS "PDAL depending on internal GEOS")
  list(APPEND PDAL_DEPENDS GEOS)
else()
  message(FATAL_ERROR "GEOS is required for PDAL, please enable")
endif()

if(WIN32)
# Windows needs help finding dependency libs/includes
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -DGEOS_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/geos_c.lib
    -DGEOS_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/includes
	
    -DGDAL_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/gdal_i.lib
    -DGDAL_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include

    -DZLIB_LIBRARY_RELEASE=${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib
    -DZLIB_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include

    -DGEOTIFF_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_i.lib
    -DGEOTIFF_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
  )
endif()

ExternalProject_Add(PDAL
  DEPENDS ${PDAL_DEPENDS}
  URL ${PDAL_file}
  URL_MD5 ${PDAL_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${PDAL_PATCH_COMMAND}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=ON
    ${PDAL_EXTRA_BUILD_FLAGS}
  )


fletch_external_project_force_install(PACKAGE PDAL)

set(PDAL_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# PDAL
########################################
set(PDAL_ROOT    \${fletch_ROOT})
set(PDAL_DIR \${fletch_ROOT}/lib/pdal/cmake)
set(PDAL_INCLUDE_DIR \${fletch_ROOT}/include)

set(fletch_ENABLED_PDAL TRUE)
")

