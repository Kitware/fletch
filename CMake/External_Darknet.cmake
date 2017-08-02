set(allOk True)
set(errorMessage)

option(AUTO_ENABLE_DARKNET_DEPENDENCY "Automatically turn on all darknet dependencies if darknet is enabled" OFF)
if(fletch_ENABLE_Darknet AND AUTO_ENABLE_DARKNET_DEPENDENCY)
  set(dependency OpenCV)
  set(OneWasOff FALSE)

  foreach (_var IN LISTS dependency)
    get_property(currentHelpString CACHE "fletch_ENABLE_${_var}" PROPERTY HELPSTRING)
    set(fletch_ENABLE_${_var} ON CACHE BOOL ${currentHelpString} FORCE)
    if(NOT TARGET ${_var})
      include(External_${_var})
    endif()
  endforeach()
endif()

function(addDarknetDendency depend version)
  if(NOT fletch_ENABLE_${depend} )
    find_package(${depend} ${version} QUIET)
    string(TOUPPER "${depend}" dependency_name_upper)
    if(NOT ${depend}_FOUND AND NOT ${dependency_name_upper}_FOUND)
      message("${depend} is needed")
      set(allOk False PARENT_SCOPE)
      return()
    endif()
    message("Warning: Using system library for ${depend}")
  else() #need to make sure library is built before darknet
    set(Darknet_DEPENDS ${Darknet_DEPENDS} ${depend} PARENT_SCOPE)
  endif()
  add_package_dependency(
    PACKAGE Darknet
    PACKAGE_DEPENDENCY ${depend}
    PACKAGE_DEPENDENCY_ALIAS ${depend}
    )
endfunction()

if(NOT allOk)
  message(FATAL_ERROR "Missing dependency(ies).")
endif()

if(fletch_ENABLE_OpenCV)
  option(fletch_ENABLE_Darknet_OpenCV "Build Darknet with OpenCV support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_OpenCV)
else()
  unset(fletch_ENABLE_Darknet_OpenCV CACHE)
endif()
if(fletch_ENABLE_Darknet_OpenCV)
  set(DARKNET_OPENCV_ARGS -DUSE_OPENCV:BOOL=ON)
  addDarknetDendency(OpenCV "")
  list(APPEND DARKNET_EXTRA_BUILD_FLAGS -DOpenCV_DIR:PATH=${OpenCV_DIR})
else()
  set(DARKNET_OPENCV_ARGS -DUSE_OPENCV:BOOL=OFF)
endif()

if(fletch_ENABLE_CUDA)
  option(fletch_ENABLE_Darknet_CUDA "Build Darknet with CUDA support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_CUDA)
else()
  unset(fletch_ENABLE_Darknet_CUDA CACHE)
endif()
if(fletch_ENABLE_CUDNN)
  option(fletch_ENABLE_Darknet_CUDNN "Build Darknet with CUDNN support" TRUE )
  mark_as_advanced(fletch_ENABLE_Darknet_CUDNN)
else()
  unset(fletch_ENABLE_Darknet_CUDNN CACHE)
endif()
if(fletch_ENABLE_Darknet_CUDA)
  set( DARKNET_GPU_ARGS -DUSE_GPU:BOOL=ON)
  if (fletch_ENABLE_Darknet_CUDNN)
    set(DARKNET_CUDNN_ARGS -DUSE_CUDNN:BOOL=ON)
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
    -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR}
    -DCUDNN_ROOT:PATH=${CUDNN_ROOT}
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
set(Darknet_ROOT    \$\{fletch_ROOT\})
set(Darknet_DIR     \$\{fletch_ROOT\}/CMake)
set(fletch_ENABLED_Darknet TRUE)
")
