# The VTK external project for fletch

include(${fletch_CMAKE_DIR}/Utils.cmake)

# Variable for VTK configuration
set(vtk_cmake_args)
set(install_include_dir ${fletch_BUILD_INSTALL_PREFIX}/include)
set(install_library_dir ${fletch_BUILD_INSTALL_PREFIX}/lib)
set(install_binary_dir ${fletch_BUILD_INSTALL_PREFIX}/bin)

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
add_package_dependency(
  PACKAGE VTK
  PACKAGE_DEPENDENCY Qt
  PACKAGE_DEPENDENCY_ALIAS Qt4
)
if(QT_QMAKE_EXECUTABLE)
  set(BUILD_QT_WEBKIT ${QT_QTWEBKIT_FOUND})
endif()
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_Group_Qt:BOOL=OFF
  -DModule_vtkGUISupportQt:BOOL=ON
  -DModule_vtkGUISupportQtOpenGL:BOOL=ON
  -DModule_vtkGUISupportQtSQL:BOOL=ON
  -DModule_vtkGUISupportQtWebkit:BOOL=${BUILD_QT_WEBKIT}
  -DModule_vtkRenderingQt:BOOL=ON
  -DModule_vtkViewsQt:BOOL=ON
  -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
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
  message(STATUS "VTK will not build against this project PROJ4."
    "VTK doesn't accept PROJ4 that have include files that are called differently"
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
  # Libtiff is always libtiff, even on windows !
  get_system_libary_vars(prefix extension)
  set(TIFF_INCLUDE_DIR ${install_include_dir})
  set(TIFF_LIBRARY ${install_library_dir}/libtiff.${extension})
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
find_package(PythonInterp)
find_package(PythonLibs)

if(PythonInterp_FOUND AND PythonLibs_FOUND)
  set(VTK_WRAP_PYTHON ON)
  message(STATUS "VTK build with python support")
else()
  set(VTK_WRAP_PYTHON OFF)
  message(STATUS "VTK build without python support")
endif()

#
# VTK
#

# General VTK flags
set(vtk_cmake_args ${vtk_cmake_args}
  -DVTK_Group_Imaging:BOOL=ON
  -DVTK_Group_Rendering:BOOL=ON
  -DVTK_Group_StandAlone:BOOL=ON
  -DVTK_Group_Views:BOOL=ON
  -DVTK_WRAP_PYTHON:BOOL=${VTK_WRAP_PYTHON}
  -DVTK_DEBUG_LEAKS:BOOL=ON
  -DVTK_REQUIRED_OBJCXX_FLAGS:STRING=""
  -DVTK_GROUP_WEB:BOOL=OFF
  -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
  -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
  -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
  )

ExternalProject_Add(VTK
  DEPENDS ${VTK_DEPENDS}
  URL ${VTK_file}
  URL_MD5 ${VTK_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DVTK_PATCH_DIR=${fletch_SOURCE_DIR}/Patches/VTK
    -DVTK_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/VTK
    -P ${fletch_SOURCE_DIR}/Patches/VTK/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
	-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    ${vtk_cmake_args}
)

set(VTK_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# VTK
########################################
set(VTK_ROOT @VTK_ROOT@)
")
