# ZLIB
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  )

# JPEG
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
  )

# libtiff
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
  )

# libgeotiff
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY libgeotiff
  PACKAGE_DEPENDENCY_ALIAS GEOTIFF
  OPTIONAL
  )

# Geotiff requires special treatment here. First, there is no CMake provided FindModule
# and the one provided by VXL is insufficient to find it. For now we have included a FindGEOTIFF.cmake
# which is a fixed version of the one provided by VXL. We are not able to update to VXL master
# currently because its treatment of FFmpeg is broken. Once we are able to upgrade to a version that
# contains the fixed FindGEOTIFF.cmake, our copy of it can get deleted and the manually setting of
# the library and include_dir for VXL here can probably go away too.
if (GEOTIFF_FOUND)
  list(APPEND VXL_EXTRA_BUILD_FLAGS
    -DGEOTIFF_INCLUDE_DIR:PATH=${GEOTIFF_INCLUDE_DIR}
    -DGEOTIFF_LIBRARY:FILEPATH=${GEOTIFF_LIBRARY}
    )
endif()

# libpng
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY PNG
  )

set(VXL_ARGS_CONTRIB
  -DVXL_BUILD_CONTRIB:BOOL=ON
  -DVXL_BUILD_RPL:BOOL=ON
  -DVXL_BUILD_BRL:BOOL=OFF
  -DVXL_BUILD_MUL_TOOLS:BOOL=OFF
  -DVXL_BUILD_PRIP:BOOL=OFF
  )

# Handle FFMPEG disable flag
list(APPEND VXL_ARGS_VIDL
  -DVXL_BUILD_CORE_VIDEO:BOOL=ON
  )
if(fletch_ENABLE_FFmpeg)
  add_package_dependency(
    PACKAGE VXL
    PACKAGE_DEPENDENCY FFmpeg
    )
else()
  list( APPEND VXL_ARGS_VIDL
    -DFFMPEG_CONFIG:FILEPATH=IGNORE
    -DFFMPEG_INCLUDE1_DIR:PATH=IGNORE
    -DFFMPEG_INCLUDE2_DIR:PATH=IGNORE
    -DFFMPEG_avcodec_LIBRARY:PATH=IGNORE
    -DFFMPEG_avformat_LIBRARY:PATH=IGNORE
    -DFFMPEG_avutil_LIBRARY:PATH=IGNORE
    -DFFMPEG_swscale_LIBRARY:PATH=IGNORE
    -DWITH_FFMPEG:BOOL=OFF
    )
endif()

if(UNIX)
  set(VXL_ARGS_V3P
    -DVXL_USING_NATIVE_ZLIB:BOOL=TRUE
    -DVXL_USING_NATIVE_BZLIB2:BOOL=TRUE
    )
  set(VXL_EXTRA_CMAKE_CXX_FLAGS
    -DVXL_EXTRA_CMAKE_CXX_FLAGS:STRING=-D__STDC_CONSTANT_MACROS
    )
elseif(WIN32)
  set(VXL_ARGS_V3P
    # Geotiff
    )
endif()

# If a patch file exists, apply it
set (VXL_patch ${fletch_SOURCE_DIR}/Patches/VXL)
if (EXISTS ${VXL_patch})
  set(VXL_PATCH_COMMAND ${CMAKE_COMMAND}
      -DVXL_PATCH_DIR:PATH=${VXL_patch}
      -DVXL_SOURCE_DIR:PATH=${fletch_BUILD_PREFIX}/src/VXL
      -P ${VXL_patch}/Patch.cmake
    )
endif()

ExternalProject_Add(VXL
  DEPENDS ${VXL_DEPENDS}
  URL ${VXL_url}
  URL_MD5 ${VXL_md5}
  DOWNLOAD_NAME ${VXL_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${VXL_PATCH_COMMAND}
  CMAKE_ARGS
    ${KWIVER_ARGS_COMMON}
    ${VXL_ARGS_GUI}
    ${VXL_ARGS_CONTRIB}
    ${VXL_ARGS_VIDL}
    ${VXL_ARGS_V3P}
    ${VXL_EXTRA_CMAKE_CXX_FLAGS}
    ${COMMON_CMAKE_ARGS}
    -DBUILD_TESTING:BOOL=OFF
    -DVXL_BUILD_EXAMPLES:BOOL=OFF
    -DVXL_BUILD_DOCUMENTATION:BOOL=OFF
    -DVXL_BUILD_FOR_VXL_DASHBOARD:BOOL=ON
    -DVXL_BUILD_CORE_PROBABILITY:BOOL=ON
    -DVXL_BUILD_CORE_GEOMETRY:BOOL=ON
    -DVXL_BUILD_CORE_NUMERICS:BOOL=ON
    -DVXL_BUILD_CORE_IMAGING:BOOL=ON
    -DVXL_BUILD_CORE_SERIALISATION:BOOL=ON
    -DVXL_BUILD_BRL:BOOL=OFF
    -DVXL_BUILD_GEL:BOOL=OFF
    -DVXL_BUILD_MUL:BOOL=OFF
    -DVXL_BUILD_MUL_TOOLS:BOOL=OFF
    -DVXL_BUILD_TBL:BOOL=OFF
    -DVXL_BUILD_OXL:BOOL=OFF
    -DVXL_USE_DCMTK:BOOL=OFF
    -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
    -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
    -DGEOTIFF_LIBRARY=${libgeotiff_LIBRARY}
    ${VXL_EXTRA_BUILD_FLAGS}
  )

ExternalProject_Add_Step(VXL forcebuild
  COMMAND ${CMAKE_COMMAND}
    -E remove ${fletch_BUILD_PREFIX}/src/VXL-stamp/VXL-build
  COMMENT "Removing build stamp file for build update (forcebuild)."
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
  )

fletch_external_project_force_install(PACKAGE VXL)

include_directories( SYSTEM ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl
                            ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl/vcl
                            ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl/core )

set(VXL_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
set(VXL_DIR "${VXL_ROOT}/share/vxl/cmake" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# VXL
################################
set(VXL_ROOT \${fletch_ROOT})
set(VXL_DIR \${fletch_ROOT}/share/vxl/cmake)

set(fletch_ENABLED_VXL TRUE)
")
