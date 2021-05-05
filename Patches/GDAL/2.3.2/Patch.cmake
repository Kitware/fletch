#+
# This file is called as CMake -P script for the patch step of
# External_GDAL.cmake.
# GDAL_patch and GDAL_source are defined on the command line along with the
# call.
#-

message(STATUS "Copying ${GDAL_patch}/data/nitf_spec.xml to ${GDAL_source}/data/nitf_spec.xml")
file(COPY ${GDAL_patch}/data/nitf_spec.xml
  DESTINATION ${GDAL_source}/data/
  )

message(STATUS "Copying ${GDAL_patch}/ogr/ogrsf_frmts/geojson/libjson/GNUmakefile to ${GDAL_source}/ogr/ogrsf_frmts/geojson/libjson/GNUmakefile")
file(COPY ${GDAL_patch}/ogr/ogrsf_frmts/geojson/libjson/GNUmakefile
  DESTINATION ${GDAL_source}/ogr/ogrsf_frmts/geojson/libjson/
  )

# Fix a build issues with gcc 11. Headers need to include <limits>
file(COPY ${GDAL_patch}/ogr/ogrsf_frmts/cad/libopencad/dwg/r2000.cpp
  DESTINATION ${GDAL_source}/ogr/ogrsf_frmts/cad/libopencad/dwg/
  )
