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

# Fix for GCC with 2-digit version numbers.
# Patch fixes the regex assumption that we're looking for version gcc 3-9
# Patch taken from https://723374.bugs.gentoo.org/attachment.cgi?id=641488
file(COPY ${VTK_PATCH_DIR}/CMake/VTKGenerateExportHeader.cmake
  DESTINATION ${VTK_SOURCE_DIR}/CMake
)
