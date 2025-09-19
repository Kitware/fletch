# The ITK external project for fletch

include(${fletch_CMAKE_DIR}/Utils.cmake)

# ZLIB
if (fletch_ENABLE_ZLib)
  add_package_dependency(
    PACKAGE ITK
    PACKAGE_DEPENDENCY ZLib
    PACKAGE_DEPENDENCY_ALIAS ZLIB
    )
  list(APPEND ITK_IMG_ARGS -DITK_USE_SYSTEM_PNG:BOOL=TRUE)
endif()

# JPEG
if (fletch_ENABLE_libjpeg-turbo)
  add_package_dependency(
    PACKAGE ITK
    PACKAGE_DEPENDENCY libjpeg-turbo
    PACKAGE_DEPENDENCY_ALIAS JPEG
    )
  list(APPEND ITK_IMG_ARGS -DITK_USE_SYSTEM_JPEG:BOOL=TRUE)
endif()

# libtiff
if (fletch_ENABLE_libtiff)
  add_package_dependency(
    PACKAGE ITK
    PACKAGE_DEPENDENCY libtiff
    PACKAGE_DEPENDENCY_ALIAS TIFF
    )
  list(APPEND ITK_IMG_ARGS -DITK_USE_SYSTEM_TIFF:BOOL=TRUE)
endif()

# libpng
if (fletch_ENABLE_PNG)
  add_package_dependency(
    PACKAGE ITK
    PACKAGE_DEPENDENCY PNG
    )
  list(APPEND ITK_IMG_ARGS -DITK_USE_SYSTEM_PNG:BOOL=TRUE)
endif()

list (APPEND itk_cmake_args
  -DITK_LEGACY_SILENT:BOOL=ON
  -DBUILD_TESTING:BOOL=OFF
  )

if (fletch_BUILD_WITH_PYTHON)
  option(fletch_ENABLE_ITK_PYTHON "Enable Python wrappings for ITK" ON)
  mark_as_advanced(fletch_ENABLE_ITK_PYTHON)

  if (fletch_ENABLE_ITK_PYTHON)
    list (APPEND itk_cmake_args
      -DITK_WRAP_PYTHON:BOOL=ON
      )
    if (fletch_ENABLE_CPython)
      add_package_dependency(
        PACKAGE ITK
        PACKAGE_DEPENDENCY CPython
      )
    endif()
  else()
    list (APPEND itk_cmake_args
      -DITK_WRAP_PYTHON:BOOL=OFF
      )
  endif()
else()
  list (APPEND itk_cmake_args
    -DITK_WRAP_PYTHON:BOOL=OFF
    )
endif()

if (fletch_ENABLE_VXL)
  list (APPEND itk_cmake_args
    -DITK_USE_SYSTEM_VXL:BOOL=ON
    -DVXL_DIR:PATH=${VXL_ROOT}
    )
  list(APPEND ITK_DEPENDS VXL)
endif()

ExternalProject_Add(ITK
  DEPENDS ${ITK_DEPENDS}
  URL ${ITK_file}
  URL_MD5 ${ITK_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${ITK_IMG_ARGS}
    ${itk_cmake_args}
)

fletch_external_project_force_install(PACKAGE ITK)

set(ITK_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(ITK_DIR "${ITK_ROOT}/lib/cmake/vtk-${ITK_version}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# ITK
########################################
set(ITK_ROOT \${fletch_ROOT})
set(ITK_DIR \${fletch_ROOT}/lib/cmake/vtk-${ITK_version})

set(fletch_ENABLED_ITK TRUE)
")
