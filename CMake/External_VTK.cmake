# The VTK external project for fletch

include(${fletch_CMAKE_DIR}/Utils.cmake)

# Variable for VTK configuration
set(vtk_cmake_args)
set(install_include_dir ${fletch_BUILD_INSTALL_PREFIX}/include)
set(install_library_dir ${fletch_BUILD_INSTALL_PREFIX}/lib)
set(install_binary_dir ${fletch_BUILD_INSTALL_PREFIX}/bin)

# Rendering backend
if(VTK_SELECT_VERSION VERSION_LESS 8.1)
  set(vtk_cmake_args ${vtk_cmake_args}
      -DVTK_RENDERING_BACKEND:STRING=OpenGL
      )
else()
  set(vtk_cmake_args ${vtk_cmake_args}
      -DVTK_RENDERING_BACKEND:STRING=OpenGL2
      )
endif()

# Boost
# Do not use boost with VTK. It's unecessary and causes build errors.
set(vtk_cmake_args ${vtk_cmake_args}
  -DModule_vtkInfovisBoost:BOOL=OFF
  -DModule_vtkInfovisBoostGraphAlgorithms:BOOL=OFF
)

# libxml2
if(NOT WIN32)
  add_package_dependency(
    PACKAGE VTK
    PACKAGE_DEPENDENCY libxml2
    PACKAGE_DEPENDENCY_ALIAS LibXml2
  )
  if(NOT LIBXML2_FOUND)
    get_system_library_name(xml2 xml2_lib)
    set(LIBXML2_INCLUDE_DIR ${install_include_dir}/libxml2)
    set(LIBXML2_LIBRARIES ${install_library_dir}/${xml2_lib})
    set(LIBXML2_XMLLINT_EXECUTABLE ${install_binary_dir}/xmllint)
  endif()
  set(vtk_cmake_args ${vtk_cmake_args}
    -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON
    -DLIBXML2_INCLUDE_DIR:PATH=${LIBXML2_INCLUDE_DIR}
    -DLIBXML2_LIBRARIES:FILEPATH=${LIBXML2_LIBRARIES}
    -DLIBXML2_XMLLINT_EXECUTABLE:FILEPATH=${LIBXML2_XMLLINT_EXECUTABLE}
    )
endif()

# libjpeg-turbo
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
)
if(NOT JPEG_FOUND)
  get_system_library_name(jpeg jpeg_lib)
  set(JPEG_INCLUDE_DIR ${install_include_dir})
  set(JPEG_LIBRARY ${install_library_dir}/${jpeg_lib})
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_USE_SYSTEM_JPEG:BOOL=ON
  -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
  -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
  )

# Qt
if(Qt_version_major EQUAL 4)
  add_package_dependency(
    PACKAGE VTK
    PACKAGE_DEPENDENCY Qt
    PACKAGE_DEPENDENCY_ALIAS Qt4
  )
  if(QT_QMAKE_EXECUTABLE)
    set(BUILD_QT_WEBKIT ${QT_QTWEBKIT_FOUND})
    set(vtk_cmake_args ${vtk_cmake_args}
      -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
      -DVTK_QT_VERSION:STRING=4
    )
  endif()
else()
  add_package_dependency(
    PACKAGE VTK
    PACKAGE_DEPENDENCY Qt
    PACKAGE_DEPENDENCY_ALIAS Qt5
    PACKAGE_DEPENDENCY_COMPONENTS
      Core Gui Widgets OpenGL Designer UiPlugin
  )
  set(vtk_cmake_args ${vtk_cmake_args}
    -DQt5_DIR:PATH=${Qt5_DIR}
    -DVTK_QT_VERSION:STRING=5
  )
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_Group_Qt:BOOL=OFF
  -DModule_vtkGUISupportQt:BOOL=ON
  -DModule_vtkGUISupportQtOpenGL:BOOL=ON
  -DModule_vtkGUISupportQtSQL:BOOL=ON
  -DModule_vtkGUISupportQtWebkit:BOOL=${BUILD_QT_WEBKIT}
  -DModule_vtkRenderingQt:BOOL=ON
  -DModule_vtkViewsQt:BOOL=ON
  -DVTK_QT_VERSION:STRING=${Qt_version_major}
)

# PostgreSQL
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY PostgreSQL
  OPTIONAL
)
set(vtk_cmake_args ${vtk_cmake_args}
  -DModule_vtkIOPostgreSQL:BOOL=${VTK_WITH_PostgreSQL}
)
set(PostgreSQL_LIBRARY)
if(NOT PostgreSQL_FOUND)
  # PostgreSQL is always libpq, even on windows !
  get_system_libary_vars(prefix extension)
  set(PostgreSQL_INCLUDE_DIR ${install_include_dir})
  set(PostgreSQL_LIBRARY ${install_library_dir}/libpq.${extension})
endif()
if(VTK_WITH_PostgreSQL)
  set(vtk_cmake_args ${vtk_cmake_args}
  -DPostgreSQL_INCLUDE_DIR:PATH=${PostgreSQL_INCLUDE_DIR}
  -DPostgreSQL_LIBRARY:FILEPATH=${PostgreSQL_LIBRARY})
endif()

# Proj4
# VTK doesn't accept PROJ4 that have include files that are called differently
# than lib_proj.h.
if(fletch_ENABLE_PROJ4)
  message(STATUS "VTK will not build against this project PROJ4. "
    "VTK doesn't accept PROJ4 that have include files that are named differently "
    "than lib_proj.h.")
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_USE_SYSTEM_LIBPROJ4:BOOL=OFF
  )

# ZLib
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
)
if(NOT ZLIB_FOUND)
  get_system_library_name(zlib zlib_lib)
  set(ZLIB_INCLUDE_DIRS ${install_include_dir})
  set(ZLIB_LIBRARIES ${install_library_dir}/${zlib_lib})
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_USE_SYSTEM_ZLib:BOOL=ON
  -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIRS}
  -DZLIB_LIBRARY:PATH=${ZLIB_LIBRARIES}
  )

# TIFF
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
)
if(NOT TIFF_FOUND)
  get_system_libary_vars(prefix extension)
  set(TIFF_INCLUDE_DIR ${install_include_dir})
  set(TIFF_LIBRARY ${install_library_dir}/${prefix}tiff.${extension})
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_USE_SYSTEM_TIFF:BOOL=ON
  -DTIFF_INCLUDE_DIR:PATH=${TIFF_INCLUDE_DIR}
  -DTIFF_LIBRARY:PATH=${TIFF_LIBRARY}
  )

# PNG
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY PNG
)
if(NOT PNG_FOUND)
  get_system_libary_vars(prefix extension)
  set(PNG_INCLUDE_DIR ${install_include_dir})
  set(PNG_LIBRARY ${install_library_dir}/libpng.${extension})
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_USE_SYSTEM_PNG:BOOL=ON
  -DPNG_INCLUDE_DIR:PATH=${PNG_INCLUDE_DIR}
  -DPNG_LIBRARY:FILEPATH=${PNG_LIBRARY}
  )

# PYTHON
if(fletch_BUILD_WITH_PYTHON AND NOT MSVC14 )
  option(fletch_ENABLE_VTK_PYTHON "Enable Python wrappings for VTK" ON)
  mark_as_advanced(fletch_ENABLE_VTK_PYTHON)

  find_package(PythonInterp)
  find_package(PythonLibs)

  if(PythonInterp_FOUND AND PythonLibs_FOUND AND fletch_ENABLE_VTK_PYTHON)
    set(VTK_WRAP_PYTHON ON)
    message(STATUS "VTK building with python support")
  else()
    set(VTK_WRAP_PYTHON OFF)
    if(fletch_ENABLE_VTK_PYTHON)
      message(WARNING "VTK building without python support. Python NOT found.")
    endif()
  endif()
elseif(fletch_BUILD_WITH_PYTHON AND MSVC14)
  message(WARNING "VTK Python will not build correctly on Visual Studio 2015. VTK 7.0 of higher is required.")
endif()

if(fletch_ENABLE_VTK AND VTK_WRAP_PYTHON AND VTK_SELECT_VERSION VERSION_LESS 7.0.0)
  if(NOT fletch_PYTHON_MAJOR_VERSION VERSION_LESS 3)
    if(fletch_BUILD_WITH_PYTHON)
      message(WARNING "Enabling Python 3 in VTK requires VTK 7.0 or greater")
    endif()
    # Enabling Python 3 in VTK requires VTK 7.0 or greater
    set(VTK_WRAP_PYTHON OFF)
  endif()
endif()

#
# VTK
#

option(VTK_ENABLE_DEBUG_LEAKS "Enable DEBUG LEAKS in VTK" OFF)
mark_as_advanced(VTK_ENABLE_DEBUG_LEAKS)

# General VTK flags
list(APPEND vtk_cmake_args
  -DBUILD_TESTING:BOOL=OFF
  -DVTK_Group_Imaging:BOOL=ON
  -DVTK_Group_Rendering:BOOL=ON
  -DVTK_Group_StandAlone:BOOL=ON
  -DVTK_Group_Views:BOOL=ON
  -DVTK_WRAP_PYTHON:BOOL=${VTK_WRAP_PYTHON}
  -DVTK_DEBUG_LEAKS:BOOL=${VTK_ENABLE_DEBUG_LEAKS}
  -DVTK_REQUIRED_OBJCXX_FLAGS:STRING=""
  -DVTK_Group_Web:BOOL=OFF
  -DVTK_PYTHON_VERSION=${fletch_PYTHON_MAJOR_VERSION}
  -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
  -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
  -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
  )

set (VTK_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/VTK/${VTK_SELECT_VERSION})
if(EXISTS ${VTK_PATCH_DIR})
  set(VTK_PATCH_COMMAND ${CMAKE_COMMAND}
    -DVTK_PATCH_DIR=${VTK_PATCH_DIR}
    -DVTK_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/VTK
    -P ${VTK_PATCH_DIR}/Patch.cmake)
else()
  set(VTK_PATCH_COMMAND "")
endif()

ExternalProject_Add(VTK
  DEPENDS ${VTK_DEPENDS}
  URL ${VTK_file}
  URL_MD5 ${VTK_md5}
  ${VTK_DOWNLOAD_NAME}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${VTK_PATCH_COMMAND}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${vtk_cmake_args}
)

fletch_external_project_force_install(PACKAGE VTK)

set(VTK_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(VTK_DIR "${VTK_ROOT}/lib/cmake/vtk-${VTK_SELECT_VERSION}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# VTK
########################################
set(VTK_ROOT \${fletch_ROOT})
set(VTK_DIR \${fletch_ROOT}/lib/cmake/vtk-${VTK_SELECT_VERSION})

set(fletch_ENABLED_VTK TRUE)
")
