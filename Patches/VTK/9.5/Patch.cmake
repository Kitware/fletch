#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake for VTK 9.5
#-

# Fix for CMake 4 compatibility - CMP0022 policy cannot be set to OLD
file(COPY ${VTK_PATCH_DIR}/ThirdParty/libproj4/vtklibproj4/cmake/policies.cmake
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/libproj4/vtklibproj4/cmake/
)
