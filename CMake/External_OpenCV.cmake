# The OpenCV external project

if (FALSE)
# Set FFmpeg dependency if we're locally building it.
if(fletch_ENABLE_FFmpeg)
  message(STATUS "OpenCV depending on internal FFmpeg")
  set(_OpenCV_DEPENDS FFmpeg ${_OpenCV_DEPENDS})

  # OpenCV uses pkg-config to find libraries to link against and use, so placing
  # our instal target library pkgconfig directory on the path link in order to
  # take precedence.
  if(NOT WIN32)
    option(OpenCV_Enable_FFmpeg "" OFF)
    if (OpenCV_Enable_FFmpeg)
      # Setting ``cmake_command`` to add custom configuretion to CMAKE_ARGS generation
      set(custom_cmake_command CMAKE_COMMAND PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH} ${CMAKE_COMMAND})
      message(STATUS "Custom cmake comand for OpenCV: \"${custom_cmake_command}\"")
    endif()
  else()
    message(WARNING "Custom linking of FFMPEG with OpenCV is undefined on Windows. OpenCV may correctly find the locally built FFmpeg, but it is not guaranteed.")
    # TODO: Figure out how OpenCV finds ffmpeg on Windows.
  endif()
endif()

# Set Eigen dependency if we're locally building it
if (fletch_ENABLE_Eigen)
  message(STATUS "OpenCV depending on internal Eigen")
  set(_OpenCV_ENABLE_EIGEN_DEFAULT TRUE)
  set(_OpenCV_DEPENDS Eigen ${_OpenCV_DEPENDS})
  set(OpenCV_EXTRA_BUILD_FLAGS -DEIGEN_INCLUDE_PATH:PATH=${fletch_INSTALL_PREFIX} ${OpenCV_EXTRA_BUILD_FLAGS})
else()
  set(_OpenCV_ENABLE_EIGEN_DEFAULT FALSE)
endif()

option(fletch_ENABLE_EIGEN "Should Eigen Support be turned on for OpenCV?" ${_OpenCV_ENABLE_EIGEN_DEFAULT})
endif(FALSE)

# Allow OpenCV's highgui to be turned off
option(fletch_ENABLE_OpenCV_highgui "Build OpenCV's highgui? (generally should be left on)" TRUE )
set(OpenCV_EXTRA_BUILD_FLAGS ${OpenCV_EXTRA_BUILD_FLAGS} -DBUILD_opencv_highgui=${fletch_ENABLE_OpenCV_highgui})

# Handle GPU disable flag
if(fletch_DISABLE_GPU_SUPPORT)
  set(OpenCV_EXTRA_BUILD_FLAGS ${OpenCV_EXTRA_BUILD_FLAGS} -DWITH_CUBLAS=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF)
  set(OpenCV_EXTRA_BUILD_FLAGS ${OpenCV_EXTRA_BUILD_FLAGS} -DWITH_OPENCL=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_OPENCLAMDFFT=OFF)
  set(OpenCV_EXTRA_BUILD_FLAGS ${OpenCV_EXTRA_BUILD_FLAGS} -DBUILD_opencv_gpu=OFF -DBUILD_opencv_ocl=OFF)
endif()

# Handle FFMPEG disable flag
if(fletch_DISABLE_FFMPEG_SUPPORT)
  set(OpenCV_EXTRA_BUILD_FLAGS ${OpenCV_EXTRA_BUILD_FLAGS} -DWITH_FFMPEG=OFF)
endif()

ExternalProject_Add(OpenCV
  DEPENDS ${_OpenCV_DEPENDS}
  URL ${OpenCV_url}
  URL_MD5 ${OpenCV_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  PATCH_COMMAND ${CMAKE_COMMAND}
  -DOpenCV_patch:PATH=${fletch_SOURCE_DIR}/Patches/OpenCV
  -DOpenCV_source:PATH=${fletch_BUILD_PREFIX}/src/OpenCV
  -P ${fletch_SOURCE_DIR}/Patches/OpenCV/Patch.cmake

  ${custom_cmake_command}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DBUILD_opencv_java:BOOL=OFF
  -DBUILD_PERF_TESTS:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=True
  -DWITH_EIGEN:BOOL=${fletch_ENABLE_EIGEN}
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
  -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
  -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
  -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
  ${OpenCV_EXTRA_BUILD_FLAGS}
  )

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
set(OpenCV_ROOT @OpenCV_ROOT@)
set(OpenCV_DIR @OpenCV_DIR@)

set(fletch_ENABLED_OpenCV TRUE)
")
