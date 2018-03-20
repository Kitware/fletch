set(Darknet_DEPENDS)

if(fletch_ENABLE_OpenCV)
  option(fletch_ENABLE_Darknet_OpenCV "Build Darknet with OpenCV support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_OpenCV)
else()
  unset(fletch_ENABLE_Darknet_OpenCV CACHE)
endif()
if(fletch_ENABLE_Darknet_OpenCV)
  set(DARKNET_OPENCV_ARGS -DUSE_OPENCV:BOOL=ON)
  add_package_dependency(
    PACKAGE Darknet
    PACKAGE_DEPENDENCY OpenCV
    PACKAGE_DEPENDENCY_ALIAS OpenCV
    )
  list(APPEND DARKNET_EXTRA_BUILD_FLAGS -DOpenCV_DIR:PATH=${OpenCV_DIR})
else()
  set(DARKNET_OPENCV_ARGS -DUSE_OPENCV:BOOL=OFF)
endif()

if(fletch_BUILD_WITH_CUDA)
  option(fletch_ENABLE_Darknet_CUDA "Build Darknet with CUDA support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_CUDA)
else()
  unset(fletch_ENABLE_Darknet_CUDA CACHE)
endif()
if(fletch_BUILD_WITH_CUDNN)
  option(fletch_ENABLE_Darknet_CUDNN "Build Darknet with CUDNN support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_CUDNN)
else()
  unset(fletch_ENABLE_Darknet_CUDNN CACHE)
endif()
if(fletch_ENABLE_Darknet_CUDA)
  set( DARKNET_GPU_ARGS -DUSE_GPU:BOOL=ON -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
  if (fletch_ENABLE_Darknet_CUDNN)
    set(DARKNET_CUDNN_ARGS -DUSE_CUDNN:BOOL=ON -DCUDNN_ROOT_DIR:PATH=${CUDNN_ROOT_DIR})
  else()
    set( DARKNET_CUDNN_ARGS -DUSE_CUDNN:BOOL=OFF)
  endif()
else()
  set( DARKNET_GPU_ARGS -DUSE_GPU:BOOL=OFF)
  set( DARKNET_CUDNN_ARGS -DUSE_CUDNN:BOOL=OFF)
endif()

if( WIN32 )
  set( DARKNET_BUILD_SHARED OFF )
else()
  set( DARKNET_BUILD_SHARED ON )
endif()

# Main build and install command
ExternalProject_Add(Darknet
  DEPENDS ${Darknet_DEPENDS}
  URL ${Darknet_url}
  URL_MD5 ${Darknet_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  CMAKE_COMMAND
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=${DARKNET_BUILD_SHARED}
    -DINSTALL_HEADER_FILES:BOOL=ON
    ${DARKNET_OPENCV_ARGS}
    ${DARKNET_CUDNN_ARGS}
    ${DARKNET_GPU_ARGS}
    ${DARKNET_EXTRA_BUILD_FLAGS}
  )


fletch_external_project_force_install(PACKAGE Darknet)

set(Darknet_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Darknet
########################################
set(Darknet_ROOT    \${fletch_ROOT})
set(Darknet_DIR     \${fletch_ROOT}/CMake)
set(fletch_ENABLED_Darknet TRUE)
")
