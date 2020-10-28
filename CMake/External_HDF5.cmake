
add_package_dependency(
  PACKAGE HDF5
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  )

if(fletch_ENABLE_ZLib)
  get_system_library_name( zlib zlib_libname )
  set(HDF5_ZLIB_ARGS
    "-DZLIB_LIBRARY_RELEASE:PATH=${ZLIB_ROOT}/lib/${zlib_libname}"
    "-DZLIB_INCLUDE_DIR:PATH=${ZLIB_ROOT}/include")
endif()

set (HDF5_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/HDF5/${HDF5_SELECT_VERSION})
if(EXISTS ${HDF5_PATCH_DIR})
  set(HDF5_PATCH_COMMAND
    ${CMAKE_COMMAND}
    -DHDF5_patch:PATH=${HDF5_PATCH_DIR}
    -DHDF5_source:PATH=${fletch_BUILD_PREFIX}/src/HDF5
    -P ${HDF5_PATCH_DIR}/Patch.cmake
    )
else()
  set(HDF5_PATCH_COMMAND "")
endif()

ExternalProject_Add(HDF5
  URL ${HDF5_url}
  URL_MD5 ${HDF5_md5}
  DEPENDS ${HDF5_DEPENDS}
  DOWNLOAD_NAME ${HDF5_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${HDF5_PATCH_COMMAND}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
    ${HDF5_ZLIB_ARGS}
    )

fletch_external_project_force_install(PACKAGE HDF5)

set(HDF5_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# HDF5
#######################################
set(HDF5_ROOT \${fletch_ROOT})
set(fletch_ENABLED_HDF5 TRUE)
")
