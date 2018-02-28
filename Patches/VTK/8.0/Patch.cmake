#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake
#-

# This patch is temporary and gets around a moc issue on newer gcc
# If the patch is integrated into VTK or fixed in Qt then we can remove.
# Also note, this patch


file(COPY ${VTK_PATCH_DIR}/GUISupport/Qt/CMakeLists.txt
  DESTINATION ${VTK_SOURCE_DIR}/GUISupport/Qt/
  )
file(COPY ${VTK_PATCH_DIR}/GUISupport/Qt/vtkQtTreeModelAdapter.h
  DESTINATION ${VTK_SOURCE_DIR}/GUISupport/Qt/
)
