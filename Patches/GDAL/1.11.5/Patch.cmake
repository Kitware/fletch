#+
# This file is called as CMake -P script for the patch step of
# External_GDAL.cmake.
# GDAL_patch and GDAL_source are defined on the command line along with the
# call.
#-

# Fix the version number to not contain "dev" and add a SOVERSION
# for the public C API
message("Copying ${GDAL_patch}/frmts/mrsid/nmake.opts to ${GDAL_source}/frmts/mrsid")
file(COPY ${GDAL_patch}/frmts/mrsid/nmake.opt DESTINATION ${GDAL_source}/frmts/mrsid)
file(COPY ${GDAL_patch}/nmake.opt DESTINATION ${GDAL_source})

# External_GDAL.cmake GDAL_patch and GDAL_source are defined on the command
# line along with the call.
#-

message("Patching GDAL ${GDAL_patch} AND ${GDAL_source}")
configure_file(
  ${GDAL_patch}/frmts/nitf/nitfwritejpeg.cpp
  ${GDAL_source}/frmts/nitf/nitfwritejpeg.cpp
  COPYONLY
  )

configure_file(
  ${GDAL_patch}/frmts/wms/gdalwmsdataset.cpp
  ${GDAL_source}/frmts/wms/gdalwmsdataset.cpp
  COPYONLY
  )

configure_file(
  ${GDAL_patch}/apps/gdalserver.c
  ${GDAL_source}/apps/gdalserver.c
  COPYONLY
  )

configure_file(
  ${GDAL_patch}/port/cpl_config.h.vc
  ${GDAL_source}/port/cpl_config.h.vc
  COPYONLY
  )

configure_file(
  ${GDAL_patch}/config.guess
  ${GDAL_source}/
  COPYONLY
  )
