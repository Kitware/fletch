#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake
#-

# Note: This patch should be removed once VTK has this issue integrated:
# https://gitlab.kitware.com/vtk/vtk/merge_requests/185
file(COPY ${VTK_PATCH_DIR}/vtkGraph.h
  DESTINATION ${VTK_SOURCE_DIR}/Common/DataModel
)

set(VS_2015_FILES
  Common/Math/Testing/Cxx/TestQuaternion.cxx
  Domains/Chemistry/Testing/Cxx/TestPeriodicTable.cxx
  IO/EnSight/vtkEnSightReader.cxx
  IO/Import/vtk3DSImporter.cxx
  IO/XML/vtkXMLUnstructuredDataReader.cxx
  Rendering/ContextOpenGL/vtkOpenGLContextDevice2DPrivate.h
  Rendering/ContextOpenGL2/vtkOpenGLContextDevice2DPrivate.h
  Rendering/Core/Testing/Cxx/RGrid.cxx
  Rendering/FreeType/vtkFreeTypeTools.cxx
  Rendering/FreeType/vtkFreeTypeTools.h
  Rendering/FreeType/vtkVectorText.cxx
  Rendering/OpenGL2/vtkWin32OpenGLRenderWindow.cxx
  ThirdParty/hdf5/vtkhdf5/config/cmake/ConfigureChecks.cmake
  ThirdParty/hdf5/vtkhdf5/config/cmake/HDF5Tests.c
  ThirdParty/libxml2/vtklibxml2/config_cmake.h.in
  ThirdParty/tiff/vtktiff/CMakeLists.txt
  ThirdParty/tiff/vtktiff/tif_config.h.in
)

foreach(f ${VS_2015_FILES})
  get_filename_component(dest ${VTK_SOURCE_DIR}/${f} DIRECTORY)
  message("COPY  ${VTK_PATCH_DIR}/${f}    DESTINATION ${dest}")
  file(COPY ${VTK_PATCH_DIR}/${f} DESTINATION ${dest})
endforeach()