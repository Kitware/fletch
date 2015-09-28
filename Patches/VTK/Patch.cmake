#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake
#-

# Note: This patch should be removed once VTK has this issue integrated:
# https://gitlab.kitware.com/vtk/vtk/merge_requests/185
file(COPY ${VTK_PATCH_DIR}/vtkGraph.h
  DESTINATION ${VTK_SOURCE_DIR}/Common/DataModel
)
