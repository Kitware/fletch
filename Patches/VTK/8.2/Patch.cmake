#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake for VTK 8.2
#-

file(COPY ${VTK_PATCH_DIR}/ThirdParty/netcdf/vtknetcdf/CMakeLists.txt
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/netcdf/vtknetcdf/
)

# Patch vtkExodusII build for gcc 10.
# Bug report is posted here:
# https://gitlab.kitware.com/vtk/vtk/-/issues/17774
# Details of the patch are posted here:
# https://discourse.slicer.org/t/build-fails-in-vtkexodus-on-linux/12018/5
file(COPY ${VTK_PATCH_DIR}/ThirdParty/exodusII/update.sh
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/exodusII/
  )
file(COPY ${VTK_PATCH_DIR}/ThirdParty/exodusII/vtkexodusII/src/ex_create_par.c
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/exodusII/vtkexodusII/src
)
file(COPY ${VTK_PATCH_DIR}/ThirdParty/exodusII/vtkexodusII/src/ex_open_par.c
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/exodusII/vtkexodusII/src
)

# Patch to allow VTK 8.2 to build correctly with gcc 10.2
file(COPY ${VTK_PATCH_DIR}/CMake/VTKGenerateExportHeader.cmake
  DESTINATION ${VTK_SOURCE_DIR}/CMake
)
