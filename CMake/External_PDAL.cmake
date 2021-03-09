
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
  if(WIN32)
    set(GDAL_LIB_NAME "gdal_i.lib")
  else()
    set(GDAL_LIB_NAME "${CMAKE_SHARED_LIBRARY_PREFIX}gdal${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -DGDAL_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/${GDAL_LIB_NAME}
    -DGDAL_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
  )
else()
  message(FATAL_ERROR "GDAL is required for PDAL, please enable")
endif()

# Set GeoTiff dependency
if (fletch_ENABLE_libgeotiff)
  message(STATUS "PDAL depending on internal libgeotiff")
  list(APPEND PDAL_DEPENDS libgeotiff)
  if(WIN32)
    set(GEOTIFF_LIB_NAME "geotiff_i.lib")
  else()
    set(GEOTIFF_LIB_NAME "${CMAKE_SHARED_LIBRARY_PREFIX}geotiff${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -DGEOTIFF_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/${GEOTIFF_LIB_NAME}
    -DGEOTIFF_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
  )
else()
  message(FATAL_ERROR "libgeotiff is required for PDAL, please enable")
endif()

# Set Proj.4 dependency
if (fletch_ENABLE_PROJ)
  message(STATUS "PDAL depending on internal PROJ")
  list(APPEND PDAL_DEPENDS PROJ)
else()
  find_package(PROJ4 REQUIRED)
endif()

# Set libxml2 dependency
if (fletch_ENABLE_libxml2)
  message(STATUS "PDAL depending on internal libxml2")
  list(APPEND PDAL_DEPENDS libxml2)
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -Dpkgcfg_lib_PC_LIBXML_xml2=${fletch_BUILD_INSTALL_PREFIX}/lib/libxml2${CMAKE_SHARED_LIBRARY_SUFFIX}
  )
else()
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
         -DBUILD_PLUGIN_PGPOINTCLOUD:BOOL=OFF
      )
endif()

# Set GEOS dependency
if (fletch_ENABLE_GEOS)
  message(STATUS "PDAL depending on internal GEOS")
  list(APPEND PDAL_DEPENDS GEOS)
  if(WIN32)
    set(GEOS_LIB_NAME "geos_c.lib")
  else()
    set(GEOS_LIB_NAME "${CMAKE_SHARED_LIBRARY_PREFIX}geos_c${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -DGEOS_LIBRARY=${fletch_BUILD_INSTALL_PREFIX}/lib/${GEOS_LIB_NAME}
    -DGEOS_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include)
else()
  message(FATAL_ERROR "GEOS is required for PDAL, please enable")
endif()

if(WIN32)
# Windows needs help finding dependency libs/includes
  list(APPEND PDAL_EXTRA_BUILD_FLAGS
    -DZLIB_LIBRARY_RELEASE=${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib
    -DZLIB_INCLUDE_DIR=${fletch_BUILD_INSTALL_PREFIX}/include
  )
endif()

set(JSON_ARGS
  -DJSONCPP_INCLUDE_DIR:PATH=IGNORE
  -DJSONCPP_LIBRARY:FILEPATH=IGNORE
  )

ExternalProject_Add(PDAL
  DEPENDS ${PDAL_DEPENDS}
  URL ${PDAL_file}
  URL_MD5 ${PDAL_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${PDAL_PATCH_COMMAND}
  CMAKE_ARGS
    ${JSON_ARGS}
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

