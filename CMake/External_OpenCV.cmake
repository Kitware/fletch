# The OpenCV external project


# --- Allow OpenCV options to be explicitly turned on/off --- 

# Allow OpenCV's highgui to be turned off
option(fletch_ENABLE_OpenCV_highgui "Build OpenCV's highgui? (generally should be left on)" TRUE )
mark_as_advanced(fletch_ENABLE_OpenCV_highgui)
list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DBUILD_opencv_highgui=${fletch_ENABLE_OpenCV_highgui})

# Allow OpenCV's GPU option to be explicitly turned off while keeping CUDA for everything else
if(fletch_ENABLE_CUDA)
  option(fletch_ENABLE_OpenCV_CUDA "Build OpenCV with CUDA support" TRUE )
  mark_as_advanced(fletch_ENABLE_OpenCV_CUDA)
else()
  set(fletch_ENABLE_OpenCV_CUDA CACHE INTERNAL FALSE)
endif()

# Allow OpenCV's FFMPEG option to be explicitly turned off
if(fletch_ENABLE_FFmpeg)
  option(fletch_ENABLE_OpenCV_FFmpeg "Build OpenCV with FFMPEG support" TRUE )
  mark_as_advanced(fletch_ENABLE_OpenCV_FFmpeg)
else()
  set(fletch_ENABLE_OpenCV_FFmpeg CACHE INTERNAL FALSE)
endif()

# Allow OpenCV's VTK option to be explicitly turned off
if(fletch_ENABLE_VTK)
  # By default turn opencv-VTK support off, even when building with VTK
  option(fletch_ENABLE_OpenCV_VTK "Build OpenCV with VTK support" FALSE )
  mark_as_advanced(fletch_ENABLE_OpenCV_VTK)
else()
  set(fletch_ENABLE_OpenCV_VTK CACHE INTERNAL FALSE)
endif()


# Note: 
# Some other libraries built by fletch could be used by OpenCV
# these are: Ceres, Qt


# --- Configure OpenCV dependencies ---

# Set FFmpeg dependency if we're locally building it.
if(fletch_ENABLE_OpenCV_FFmpeg)
  message(STATUS "OpenCV depending on internal FFmpeg")
  list(APPEND OpenCV_DEPENDS FFmpeg)

  # OpenCV uses pkg-config to find libraries to link against and use, so placing
  # our instal target library pkgconfig directory on the path link in order to
  # take precedence.
  if(NOT WIN32)
      # Setting ``cmake_command`` to add custom configuretion to CMAKE_ARGS generation
      set(custom_cmake_command CMAKE_COMMAND PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH} ${CMAKE_COMMAND})
      message(STATUS "Custom cmake comand for OpenCV: \"${custom_cmake_command}\"")
  else()
    message(WARNING "Custom linking of FFMPEG with OpenCV is undefined on Windows. OpenCV may correctly find the locally built FFmpeg, but it is not guaranteed.")
    # TODO: Figure out how OpenCV finds ffmpeg on Windows.
  endif()
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_FFMPEG=OFF)
endif()

# Set VTK dependency if we're locally building it
if(fletch_ENABLE_OpenCV_VTK)
  message(STATUS "OpenCV depending on fletch VTK")
  if (OpenCV_version VERSION_LESS 3.2.0 AND VTK_version VERSION_GREATER_EQUAL 7.0)
    message(FATAL_ERRROR "OpenCV versions before 3.2 can only handle pre 7.0 VTK versions")
  endif()
  list(APPEND OpenCV_DEPENDS VTK)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_VTK:BOOL=TRUE
    -DVTK_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/vtk-${VTK_version}
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_EIGEN:BOOL=FALSE)
endif()

# Set Eigen dependency if we're locally building it
if(fletch_ENABLE_Eigen)
  message(STATUS "OpenCV depending on fletch Eigen")
  set(_OpenCV_ENABLE_EIGEN_DEFAULT TRUE)
  list(APPEND OpenCV_DEPENDS Eigen)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_EIGEN:BOOL=TRUE
    -DEIGEN_INCLUDE_PATH:PATH=${fletch_BUILD_INSTALL_PREFIX}/include/eigen3
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_EIGEN:BOOL=FALSE)
endif()


# Handle GPU disable flag
if(fletch_ENABLE_OpenCV_CUDA)
  format_passdowns("CUDA" CUDA_BUILD_FLAGS)
  format_passdowns("CUDNN" CUDNN_BUILD_FLAGS)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    ${CUDA_BUILD_FLAGS}
    ${CUDNN_BUILD_FLAGS}
    -DWITH_CUBLAS=ON -DWITH_CUDA=ON
    -DWITH_CUFFT=ON
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DWITH_CUBLAS=OFF -DWITH_CUDA=OFF
    -DWITH_CUFFT=OFF
    )
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DWITH_OPENCL=OFF -DWITH_OPENCLAMDBLAS=OFF
    -DWITH_OPENCLAMDFFT=OFF
    )
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DBUILD_opencv_gpu=OFF -DBUILD_opencv_ocl=OFF
    )
endif()

# libtiff
add_package_dependency(
  PACKAGE OpenCV
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
  OPTIONAL
  EMBEDDED
)
list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_TIFF=ON)

if (OpenCV_WITH_libtiff)
  if(NOT TIFF_FOUND)
    get_system_library_name(tiff tiff_lib)
    set(TIFF_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(TIFF_LIBRARY_DEBUG ${fletch_BUILD_INSTALL_PREFIX}/lib/${tiff_lib})
    set(TIFF_LIBRARY_RELEASE ${fletch_BUILD_INSTALL_PREFIX}/lib/${tiff_lib})
  endif()

  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DBUILD_TIFF:BOOL=OFF
    -DTIFF_INCLUDE_DIR:PATH=${TIFF_INCLUDE_DIR}
    -DTIFF_LIBRARY_DEBUG:FILEPATH=${TIFF_LIBRARY_DEBUG}
    -DTIFF_LIBRARY_RELEASE:FILEPATH=${TIFF_LIBRARY_RELEASE}
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DBUILD_TIFF=ON)
endif()

# ZLIB
add_package_dependency(
  PACKAGE OpenCV
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  OPTIONAL
  EMBEDDED
  )

if(OpenCV_WITH_ZLib)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS  -DBUILD_ZLIB:BOOL=FALSE)
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS  -DBUILD_ZLIB:BOOL=TRUE)
endif()


# PNG
add_package_dependency(
  PACKAGE OpenCV
  PACKAGE_DEPENDENCY PNG
  OPTIONAL
  EMBEDDED
)
list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_PNG=ON)

if(OpenCV_WITH_PNG)
  if(NOT PNG_FOUND)
    # PNG is always libpq, even on windows !
    get_system_libary_vars(prefix extension)
    set(PNG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(PNG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/libpng.${extension})
  endif()

  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DBUILD_PNG=OFF
    -DPNG_PNG_INCLUDE_DIR:PATH=${PNG_INCLUDE_DIR}
    -DPNG_LIBRARY_DEBUG:FILEPATH=${PNG_LIBRARY}
    -DPNG_LIBRARY_RELEASE:FILEPATH=${PNG_LIBRARY}
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DBUILD_PNG=ON)
endif()

# JPEG
add_package_dependency(
  PACKAGE OpenCV
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
  OPTIONAL
  EMBEDDED
)
list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DWITH_JPEG=ON)
if (OpenCV_WITH_libjpeg-turbo)
  if(NOT JPEG_FOUND)
    get_system_library_name(jpeg jpeg_lib)
    set(JPEG_INCLUDE_DIR ${fletch_BUILD_INSTALL_PREFIX}/include)
    set(JPEG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/${jpeg_lib})
  endif()

  list(APPEND OpenCV_EXTRA_BUILD_FLAGS
    -DBUILD_JPEG=OFF
    -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
    -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
    )
else()
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DBUILD_JPEG=ON)
endif()


# If a patch file exists for this version, apply it
set (OpenCV_patch ${fletch_SOURCE_DIR}/Patches/OpenCV/${OpenCV_SELECT_VERSION})
if (EXISTS ${OpenCV_patch})
  set(OPENCV_PATCH_COMMAND ${CMAKE_COMMAND}
    -DOpenCV_patch:PATH=${OpenCV_patch}
    -DOpenCV_source:PATH=${fletch_BUILD_PREFIX}/src/OpenCV
    -P ${OpenCV_patch}/Patch.cmake
    )
else()
  set(OPENCV_PATCH_COMMAND "")
endif()

# Include link to contrib repo if enabled
if (fletch_ENABLE_OpenCV_contrib)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS "-DOPENCV_EXTRA_MODULES_PATH:PATH=${OpenCV_contrib_MODULE_PATH}")
  # turn off cnn_3dobj because it introduces cyclic dependency between OpenCV and Caffe
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS "-DBUILD_opencv_cnn_3dobj:BOOL=OFF")
  list(APPEND OpenCV_DEPENDS OpenCV_contrib)
  #Don't build these contrib modules, they fail on VS.
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DBUILD_opencv_bioinspired:BOOL=FALSE)
endif()

# In newer GCC we need to disable precompiled headers.
if (CMAKE_COMPILER_IS_GNUCC AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DENABLE_PRECOMPILED_HEADERS:BOOL=OFF)
endif()

# OpenCV 3.3.0 has an option to enable C++ 11
if (fletch_BUILD_CXX11)
  list(APPEND OpenCV_EXTRA_BUILD_FLAGS -DENABLE_CXX11:BOOL=ON)
endif()

ExternalProject_Add(OpenCV
  DEPENDS ${OpenCV_DEPENDS}
  URL ${OpenCV_url}
  URL_MD5 ${OpenCV_md5}
  DOWNLOAD_NAME ${OpenCV_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  PATCH_COMMAND ${OPENCV_PATCH_COMMAND}

  ${custom_cmake_command}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DBUILD_opencv_java:BOOL=False
    -DBUILD_PERF_TESTS:BOOL=False
    -DBUILD_SHARED_LIBS:BOOL=True
    -DBUILD_TESTS:BOOL=False
    -DWITH_EIGEN:BOOL=${fletch_ENABLE_EIGEN}
    -DWITH_JASPER:BOOL=False
    -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
    -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
    -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
  ${OpenCV_EXTRA_BUILD_FLAGS}
  )

fletch_external_project_force_install(PACKAGE OpenCV)

set(OpenCV_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

#OpenCV installs its config file in a different location on Windows
if(WIN32)
  set(OpenCV_DIR ${OpenCV_ROOT})
else()
  set(OpenCV_DIR ${OpenCV_ROOT}/share/OpenCV)
endif()

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# OpenCV
########################################
set(OpenCV_ROOT \${fletch_ROOT})
if(WIN32)
  set(OpenCV_DIR \${OpenCV_ROOT})
else()
  set(OpenCV_DIR \${OpenCV_ROOT}/share/OpenCV)
endif()

set(fletch_ENABLED_OpenCV TRUE)
")
