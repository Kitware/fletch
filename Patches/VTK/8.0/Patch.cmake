#+
# This file is called as CMake -P script for the patch step of
# External_VTK.cmake
#-

# This patch brings in the following two commits from VTK's release branch to
# VTK v8.0
#
# commit 6a5509af338680c169a0b95aef92eac7bda953c6
# Author: Sankhesh Jhaveri <sankhesh.jhaveri@kitware.com>
# Date:   Fri Jul 6 17:41:51 2018 -0400
#
#     Fix bug where re-enabling seed widget wouldn't move existing seeds
#
#     The widget waited for a left click when re-enabled. This leads to an
#     additional seed placed at the site of the existing seed before
#     registering that there is already a seed present.
#
#
# commit 585aeb84796fa87da58c3129ec242fc37500dc4a
# Author: Sankhesh Jhaveri <sankhesh.jhaveri@kitware.com>
# Date:   Wed Jul 11 17:32:18 2018 -0400
#
#     Invoke DeletePointEvent before deleting vtkSeedWidget seed

file(COPY ${VTK_PATCH_DIR}/Common/Core/vtkCommand.h
  DESTINATION ${VTK_SOURCE_DIR}/Common/Core/
)
file(COPY ${VTK_PATCH_DIR}/Interaction/Widgets/vtkSeedWidget.h
  DESTINATION ${VTK_SOURCE_DIR}/Interaction/Widgets/
)
file(COPY ${VTK_PATCH_DIR}/Interaction/Widgets/vtkSeedWidget.cxx
  DESTINATION ${VTK_SOURCE_DIR}/Interaction/Widgets/
)

file(COPY ${VTK_PATCH_DIR}/Wrapping/PythonCore/vtkPythonArgs.cxx
  DESTINATION ${VTK_SOURCE_DIR}/Wrapping/PythonCore/
)

file(COPY ${VTK_PATCH_DIR}/CMake/VTKGenerateExportHeader.cmake
  DESTINATION ${VTK_SOURCE_DIR}/CMake/
)
