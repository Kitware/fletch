
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
  OPTIONAL
  )

if (NOT fletch_ENABLE_libjpeg-turbo )
  list (APPEND missing_img_fmts libjpeg-turbo)
endif()

# libtiff
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
  OPTIONAL
  )

if (NOT fletch_ENABLE_libtiff )
  list (APPEND missing_img_fmts libtiff)
endif()

# libpng
add_package_dependency(
  PACKAGE VXL
  PACKAGE_DEPENDENCY PNG
  OPTIONAL
  )

if (NOT fletch_ENABLE_PNG )
  list (APPEND missing_img_fmts PNG)
endif()

if (missing_img_fmts)
  message(WARNING "
     You have chosen not to enable the following image formats:
     ${missing_img_fmts}
     It is not recommended since VXL might build its own version,
     which are very old.
     If you have runtime issues with image formats,
     enable these packages.
")
endif()

set(VXL_ARGS_CONTRIB
  -DBUILD_BRL:BOOL=OFF
  -DBUILD_MUL_TOOLS:BOOL=OFF
  -DBUILD_PRIP:BOOL=OFF
  )


# Handle FFMPEG disable flag
if(fletch_DISABLE_FFMPEG_SUPPORT)
  set(VXL_ARGS_VIDL
    -DFFMPEG_CONFIG:FILEPATH=
    -DFFMPEG_INCLUDE1_DIR:PATH=
    -DFFMPEG_INCLUDE2_DIR:PATH=
    -DFFMPEG_avcodec_LIBRARY:PATH=
    -DFFMPEG_avformat_LIBRARY:PATH=
    -DFFMPEG_avutil_LIBRARY:PATH=
    -DFFMPEG_swscale_LIBRARY:PATH=
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

if(${fletch_ENABLE_libtiff})
  # When using the TIFF library from Fletch we need to explicitly
  # disable the GeoTIFF library in VXL, because if a system GeoTiff package
  # is found it will link against a system TIFF library, causing conflicts.
  # This may change in the future if GeoTIFF is added to Fletch.
  list(APPEND VXL_EXTRA_BUILD_FLAGS -DVXL_USE_GEOTIFF:BOOL=OFF)
endif()

ExternalProject_Add(VXL
  DEPENDS ${VXL_DEPENDS}
  URL ${VXL_url}
  URL_MD5 ${VXL_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${KWIVER_ARGS_COMMON}
    ${VXL_ARGS_GUI}
    ${VXL_ARGS_CONTRIB}
    ${VXL_ARGS_VIDL}
    ${VXL_ARGS_V3P}
    ${VXL_EXTRA_CMAKE_CXX_FLAGS}
    ${COMMON_CMAKE_ARGS}
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
    -DBUILD_DOCUMENTATION:BOOL=OFF
    -DBUILD_CORE_PROBABILITY:BOOL=ON
    -DBUILD_CORE_GEOMETRY:BOOL=ON
    -DBUILD_CORE_NUMERICS:BOOL=ON
    -DBUILD_CORE_IMAGING:BOOL=ON
    -DBUILD_CORE_SERIALISATION:BOOL=ON
    -DBUILD_GEL:BOOL=OFF
    -DBUILD_MUL:BOOL=OFF
    -DBUILD_MUL_TOOLS:BOOL=OFF
    -DBUILD_TBL:BOOL=OFF
    -DVXL_USE_DCMTK:BOOL=OFF
    -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
    -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    ${VXL_EXTRA_BUILD_FLAGS}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  )

ExternalProject_Add_Step(VXL forcebuild
  COMMAND ${CMAKE_COMMAND}
    -E remove ${fletch_BUILD_PREFIX}/src/VXL-stamp/VXL-build
  COMMENT "Removing build stamp file for build update (forcebuild)."
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
  )

include_directories( SYSTEM ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl
                            ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl/vcl
                            ${KWIVER_BUILD_INSTALL_PREFIX}/include/vxl/core )

set(VXL_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# VXL
################################
set(VXL_ROOT @VXL_ROOT@)

set(fletch_ENABLED_VXL TRUE)
")
