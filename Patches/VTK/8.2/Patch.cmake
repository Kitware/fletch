#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake for VTK 8.2
#-

file(COPY ${VTK_PATCH_DIR}/ThirdParty/netcdf/vtknetcdf/CMakeLists.txt
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/netcdf/vtknetcdf/
)
