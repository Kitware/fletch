#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)
