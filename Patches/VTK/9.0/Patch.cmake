#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake for VTK 8.2
#-



# Fix for GCC 11. Many files missing #include <limits>
file(COPY ${VTK_PATCH_DIR}/Common/Core/vtkGenericDataArrayLookupHelper.h
  DESTINATION ${VTK_SOURCE_DIR}/Common/Core/
 )

file(COPY ${VTK_PATCH_DIR}/Common/DataModel/vtkPiecewiseFunction.cxx
  DESTINATION ${VTK_SOURCE_DIR}/Common/DataModel/
 )

file(COPY ${VTK_PATCH_DIR}/Rendering/Core/vtkColorTransferFunction.cxx
  DESTINATION ${VTK_SOURCE_DIR}/Rendering/Core
 )

file(COPY ${VTK_PATCH_DIR}/Filters/HyperTree/vtkHyperTreeGridThreshold.cxx
  DESTINATION ${VTK_SOURCE_DIR}/Filters/HyperTree/
 )

# Fix for CMake 4 compatibility - CMP0022 policy cannot be set to OLD
file(COPY ${VTK_PATCH_DIR}/ThirdParty/libproj4/vtklibproj4/cmake/policies.cmake
  DESTINATION ${VTK_SOURCE_DIR}/ThirdParty/libproj4/vtklibproj4/cmake/
)
