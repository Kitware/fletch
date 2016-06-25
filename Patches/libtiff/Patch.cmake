#This patch is used to correct snprintf errors.
#Visual Studio 2015 added in snprintf, so libtiff's declaration
#conflicts with the compiler's existing definition

file(COPY ${libtiff_patch}/tif_config.vc.h
  DESTINATION ${libtiff_source}/libtiff
)