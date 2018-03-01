set(allOk True)
set(errorMessage)

option(AUTO_ENABLE_CAFFE2_DEPENDENCY "Automatically turn on all caffe dependencies if caffe is enabled" OFF)

function(addCaffe2Dendency depend version)
  set(options OPTIONAL)
  set(oneValueArgs )
  set(multiValueArgs )
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if(AUTO_ENABLE_CAFFE2_DEPENDENCY AND fletch_ENABLE_Caffe2)
    get_property(currentHelpString CACHE "fletch_ENABLE_${_var}" PROPERTY HELPSTRING)
    set(fletch_ENABLE_${_var} ON CACHE BOOL ${currentHelpString} FORCE)
    if(NOT TARGET ${_var})
      include(External_${_var})
    endif()
  endif()

  if(fletch_ENABLE_${depend} )
    set(${depend}_FOUND TRUE)
    set(Caffe2_DEPENDS ${Caffe2_DEPENDS} ${depend} PARENT_SCOPE)
  else()
    find_package(${depend} ${version} QUIET)
    string(TOUPPER "${depend}" dependency_name_upper)
    if(NOT ${depend}_FOUND AND NOT ${dependency_name_upper}_FOUND)
      set(${depend}_FOUND FALSE)
      if (NOT MY_OPTIONAL)
        message("${depend} is needed")
        set(allOk False PARENT_SCOPE)
        return()
      endif()
    else()
      set(${depend}_FOUND TRUE)
      message("Warning: Using system library for ${depend}")
    endif()
  endif()

  #need to make sure library is built before caffe2
  #message(STATUS "${depend}_FOUND = ${${depend}_FOUND}")
  if (${depend}_FOUND)
    add_package_dependency(
      PACKAGE Caffe2
      PACKAGE_DEPENDENCY ${depend}
      PACKAGE_DEPENDENCY_ALIAS ${depend}
      )
  endif()
endfunction()

# Check for dependencies.
if(NOT WIN32)
  # Win32 build takes care of most dependencies automatically
  # Is this still true for Caffe2?
  addCaffe2Dendency(Snappy "")  # needed by LevelDB
  addCaffe2Dendency(LevelDB "")
  addCaffe2Dendency(LMDB "")
  addCaffe2Dendency(Protobuf "")
  if (NOT APPLE)
    addCaffe2Dendency(OpenBLAS "")
  endif()
endif()
addCaffe2Dendency(Boost "")
addCaffe2Dendency(GFlags "")
addCaffe2Dendency(GLog "")
addCaffe2Dendency(CUB "")
addCaffe2Dendency(pybind11 "")
addCaffe2Dendency(OpenCV "")
addCaffe2Dendency(FFmpeg "" OPTIONAL)

if(NOT allOk)
  message(FATAL_ERROR "Missing dependency(ies).")
endif()

# Set paths which Caffe2 requires for protobuf and opencv

set( CAFFE2_PROTOBUF_ARGS )

set( CAFFE2_PROTOBUF_ARGS
  -DPROTOBUF_INCLUDE_DIR:PATH=${PROTOBUF_INCLUDE_DIR}
  -DPROTOBUF_LIBRARY:PATH=${PROTOBUF_LIBRARY}
  -DPROTOBUF_LIBRARY_DEBUG:PATH=${PROTOBUF_LIBRARY_DEBUG}
  -DPROTOBUF_LITE_LIBRARY:PATH=${PROTOBUF_LITE_LIBRARY}
  -DPROTOBUF_LITE_LIBRARY_DEBUG:PATH=${PROTOBUF_LITE_LIBRARY_DEBUG}
  -DPROTOBUF_PROTOC_EXECUTABLE:PATH=${PROTOBUF_PROTOC_EXECUTABLE}
  -DPROTOBUF_PROTOC_LIBRARY:PATH=${PROTOBUF_PROTOC_LIBRARY}
  -DPROTOBUF_PROTOC_LIBRARY_DEBUG:PATH=${PROTOBUF_PROTOC_LIBRARY_DEBUG}
)

if(fletch_ENABLE_OpenCV)
  set( CAFFE2_OPENCV_ARGS
    -DUSE_OPENCV:BOOL=${fletch_ENABLE_OpenCV}
    -DOpenCV_DIR:PATH=${fletch_BUILD_PREFIX}/src/OpenCV-build
    -DOpenCV_LIB_PATH:PATH=${OpenCV_ROOT}/lib
    )
else()
  set( CAFFE2_OPENCV_ARGS
    -DUSE_OPENCV:BOOL=${fletch_ENABLE_OpenCV}
  )
endif()

set( CAFFE2_LMDB_ARGS
  -DLMDB_INCLUDE_DIR:PATH=${LMDB_INCLUDE_DIR}
  -DLMDB_LIBRARIES:PATH=${LMDB_LIBRARIES}
  )

# NOTE: Caffe currently has LevelDB_INCLUDE instead of the normal LevelDB_INCLUDE_DIR
set( CAFFE2_LevelDB_ARGS
  -DLevelDB_INCLUDE:PATH=${LevelDB_INCLUDE_DIR}
  -DLevelDB_LIBRARY:PATH=${LevelDB_LIBRARY}
  )

set( CAFFE2_GLog_ARGS
  -DGLOG_ROOT_DIR:PATH=${GLog_ROOT}
  -DGLOG_INCLUDE_DIR:PATH=${GLog_INCLUDE_DIR}
  -DGLOG_LIBRARY:FILEPATH=${GLog_LIBRARY}
  )

if(fletch_ENABLE_GFlags)
  set( CAFFE2_GFlags_ARGS
    -DGFLAGS_INCLUDE_DIR:PATH=${GFlags_INCLUDE_DIR}
    -DGFLAGS_LIBRARY:PATH=${GFlags_LIBRARY}
    )
else()
  set( CAFFE2_GFlags_ARGS -DGFLAGS_ROOT_DIR:PATH=${GFlags_DIR})
endif()

if(fletch_BUILD_WITH_PYTHON AND fletch_ENABLE_Boost)
  if(Boost_Do_BCP_Name_Mangling)
    message(FATAL_ERROR "Cannot have Boost mangling enabled and use pycaffe.")
  endif()
  find_package(NumPy 1.7 REQUIRED)
  set(PYTHON_ARGS
      -DBUILD_PYTHON:BOOL=ON
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DNUMPY_INCLUDE_DIR=${NUMPY_INCLUDE_DIR}
      -DNUMPY_VERSION=${NUMPY_VERSION}
      )
else()
  set(PYTHON_ARGS -DBUILD_PYTHON:BOOL=OFF)
endif()

set(CAFFE2_OPENBLAS_ARGS
  -DOpenBLAS_INCLUDE_DIR="${OpenBLAS_INCLUDE_DIR}"
  -DOpenBLAS_LIB="${OpenBLAS_LIB}"
)

if(fletch_BUILD_WITH_CUDA)
  format_passdowns("CUDA" CUDA_BUILD_FLAGS)
  set( CAFFE2_GPU_ARGS
    ${CUDA_BUILD_FLAGS}
    -DUSE_CUDA:BOOL=TRUE
    )
  if(fletch_BUILD_WITH_CUDNN)
    format_passdowns("CUDNN" CUDNN_BUILD_FLAGS)
    set(CAFFE2_CUDNN_ARGS
      -D CUDNN_LIBRARY=${CUDNN_LIBRARIES}
      -D CUDNN_ROOT_DIR=${CUDNN_TOOLKIT_ROOT_DIR}
      ${CUDNN_BUILD_FLAGS}
      #-DUSE_CUDNN:BOOL=ON
    )
    set( CAFFE2_GPU_ARGS ${CAFFE2_GPU_ARGS} ${CAFFE2_CUDNN_ARGS})
  else()
    set( CAFFE2_GPU_ARGS
      ${CAFFE2_GPU_ARGS}
      #-DUSE_CUDNN:BOOL=OFF
    )
  endif()
else()
  set( CAFFE2_GPU_ARGS
    -DUSE_CUDA:BOOL=FALSE
    #-DCPU_ONLY:BOOL=ON
    #-DUSE_CUDNN:BOOL=OFF
    )
endif()


set (Caffe2_PATCH_DIR "${fletch_SOURCE_DIR}/Patches/Caffe2/${Caffe2_version}")
if (EXISTS ${Caffe2_PATCH_DIR})
  set(
    Caffe2_PATCH_COMMAND ${CMAKE_COMMAND}
    -DCaffe2_patch=${Caffe2_PATCH_DIR}
    -DCaffe2_source=${fletch_BUILD_PREFIX}/src/Caffe2
    -P ${Caffe2_PATCH_DIR}/Patch.cmake
    )
else()
  set(Caffe2_PATCH_COMMAND "")
endif()


# Main build and install command
if(WIN32)
  set(CAFFE2_WIN32_OPTIONS
      -DBoost_USE_STATIC_LIBS:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=ON
  )
endif()

ExternalProject_Add(Caffe2
  DEPENDS ${Caffe2_DEPENDS}
  URL ${Caffe2_url}
  URL_MD5 ${Caffe2_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  #PATCH_COMMAND ${Caffe2_PATCH_COMMAND}
  CMAKE_COMMAND
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -D CMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -D CMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -D BOOST_ROOT:PATH=${BOOST_ROOT}
    -D BLAS:STRING=OpenBLAS
    -D BUILD_TEST:BOOL=OFF
    #NCCL_ROOT_DIR="https://github.com/NVIDIA/nccl/archive/v1.3.4-1.zip"
    -D USE_NCCL:BOOL=OFF
    -D USE_GLOO:BOOL=OFF
    -D USE_MPI:BOOL=OFF
    -D USE_METAL:BOOL=OFF
    -D USE_ROCKSDB:BOOL=OFF
    -D USE_MOBILE_OPENGL:BOOL=OFF
    -D USE_NNPACK:BOOL=OFF
    -D CUB_INCLUDE_DIR:PATH=${CUB_INCLUDE_DIR}
    ${PYTHON_ARGS}
    ${CAFFE2_PROTOBUF_ARGS}
    ${CAFFE2_OPENCV_ARGS}
    ${CAFFE2_LMDB_ARGS}
    ${CAFFE2_LevelDB_ARGS}
    ${CAFFE2_GLog_ARGS}
    ${CAFFE2_GFlags_ARGS}
    ${CAFFE2_OPENBLAS_ARGS}
    ${CAFFE2_GPU_ARGS}
    ${CAFFE2_WIN32_OPTIONS}
  )

fletch_external_project_force_install(PACKAGE Caffe2)

set(Caffe2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Caffe2
########################################
set(Caffe2_ROOT    \${fletch_ROOT})
")

