#+
# This file is called as CMake -P script for the patch step of
# External_GDAL.cmake.
# GDAL_patch and GDAL_source are defined on the command line along with the
# call.
#-

message("Copying ${GDAL_patch}/data/nitf_spec.xml to ${GDAL_source}/data/nitf_spec.xml")
file(COPY ${GDAL_patch}/data/nitf_spec.xml DESTINATION ${GDAL_source}/data/)

