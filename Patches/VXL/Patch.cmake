#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

message(STATUS "Patching VXL in ${VXL_SOURCE_DIR}")

file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)

# Fix CMake 4.x compatibility: cmake_minimum_required version too old
file(COPY ${VXL_PATCH_DIR}/config/cmake/config/vxl_shared_link_test/CMakeLists.txt
  DESTINATION ${VXL_SOURCE_DIR}/config/cmake/config/vxl_shared_link_test/
)

# fixes an issue with duplicate definition of lrintf() on Windows
file(COPY ${VXL_PATCH_DIR}/v3p/openjpeg2/opj_includes.h
  DESTINATION ${VXL_SOURCE_DIR}/v3p/openjpeg2/
)
