# The ITK external project for fletch

include(${fletch_CMAKE_DIR}/Utils.cmake)

list (APPEND itk_cmake_args
  -DITK_WRAP_PYTHON:BOOL=ON
  -DITK_LEGACY_SILENT:BOOL=ON
  -DBUILD_TESTING:BOOL=OFF
  )

if (fletch_ENABLED_VXL)
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
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
#  PATCH_COMMAND ${CMAKE_COMMAND}
#    -DITK_PATCH_DIR=${fletch_SOURCE_DIR}/Patches/ITK
#    -DITK_SOURCE_DIR=${fletch_BUILD_PREFIX}/src/ITK
#    -P ${fletch_SOURCE_DIR}/Patches/ITK/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    ${itk_cmake_args}
)

set(ITK_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(ITK_DIR "${ITK_ROOT}/lib/cmake/vtk-${ITK_version}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# ITK
########################################
set(ITK_ROOT @ITK_ROOT@)
set(ITK_DIR @ITK_DIR@)

set(fletch_ENABLED_ITK TRUE)
")
