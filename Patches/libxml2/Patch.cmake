#+
# This file is called as CMake -P script for the patch step of
# External_libxml2.cmake libxml2_patch and libxml2_source are defined on the command
# line along with the call.
#-
# The purpose of this is to add CMake build to libsvm
message("Patching libxml2 ${libxml2_patch} AND ${libxml2_source}")

# Path config.guess for arm board support, e.g. TX2
file(COPY
  ${libxml2_patch}/config.guess
  DESTINATION ${libxml2_source}/
)
