if (WIN32)
  message( FATAL_ERROR "Caffe-Segnet is not yet supported on windows" )
  return()
endif()


set(allOk True)
set(errorMessage)

option(AUTO_ENABLE_CAFFE_SEGNET_DEPENDENCY "Automatically turn on all caffe segnet dependencies if caffe segnet is enabled" OFF)
if(fletch_ENABLE_Caffe_Segnet AND AUTO_ENABLE_CAFFE_SEGNET_DEPENDENCY)
  #Snappy is needed by LevelDB and ZLib is needed by HDF5
  if(WIN32)
    set(dependency Boost ZLib OpenCV HDF5)
  else()
    set(dependency Boost GFlags GLog ZLib HDF5 Snappy LevelDB LMDB OpenCV Protobuf)
  endif()

  if(NOT APPLE AND NOT WIN32)
    list(APPEND dependency OpenBLAS)
  endif()

  set(OneWasOff FALSE)

  foreach (_var IN LISTS dependency)
    get_property(currentHelpString CACHE "fletch_ENABLE_${_var}" PROPERTY HELPSTRING)
    set(fletch_ENABLE_${_var} ON CACHE BOOL ${currentHelpString} FORCE)
    if(NOT TARGET ${_var})
      include(External_${_var})
    endif()
  endforeach()
endif()

function(addCaffeSegnetDendency depend version)
  if(NOT fletch_ENABLE_${depend} )
    find_package(${depend} ${version} QUIET)
    string(TOUPPER "${depend}" dependency_name_upper)
    if(NOT ${depend}_FOUND AND NOT ${dependency_name_upper}_FOUND)
      message("${depend} is needed")
      set(allOk False PARENT_SCOPE)
      return()
    endif()
    message("Warning: Using system library for ${depend}")
  else() #need to make sure library is built before caffe segnet
    set(Caffe_Segnet_DEPENDS ${Caffe_Segnet_DEPENDS} ${depend} PARENT_SCOPE)
  endif()
  add_package_dependency(
    PACKAGE Caffe_Segnet
    PACKAGE_DEPENDENCY ${depend}
    PACKAGE_DEPENDENCY_ALIAS ${depend}
    )
endfunction()

# Check for dependencies.
if(NOT WIN32) # Win32 build takes care of most dependencies automatically
  addCaffeSegnetDendency(LevelDB "")
  addCaffeSegnetDendency(LMDB "")
  if(NOT APPLE)
    addCaffeSegnetDendency(OpenBLAS "")
  endif()
  addCaffeSegnetDendency(Protobuf "")
endif()
addCaffeSegnetDendency(HDF5 "") # CaffeSegnet for windows grabs its own HDF5, but we need a parallel builds so we don't break other code
addCaffeSegnetDendency(Boost 1.46)
addCaffeSegnetDendency(GFlags "")
addCaffeSegnetDendency(GLog "")
addCaffeSegnetDendency(OpenCV "")
addCaffeSegnetDendency(ZLib "")

if(NOT allOk)
  message(FATAL_ERROR "Missing dependency(ies).")
endif()

# Set paths which CaffeSegnet requires for protobuf and opencv

set( CAFFE_SEGNET_PROTOBUF_ARGS )

if(fletch_ENABLE_Protobuf)
  get_system_library_name( protobuf protobuf_libname )
  get_system_library_name( protobuf-lite protobuf-lite_libname )
  get_system_library_name( protoc protoc_libname )

  set( CAFFE_SEGNET_PROTOBUF_ARGS
    -DPROTOBUF_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DPROTOBUF_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protobuf_libname}
    -DPROTOBUF_LIBRARY_DEBUG:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protobuf_libname}
    -DPROTOBUF_LITE_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protobuf-lite_libname}
    -DPROTOBUF_LITE_LIBRARY_DEBUG:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protobuf-lite_libname}
    -DPROTOBUF_PROTOC_EXECUTABLE:PATH=${fletch_BUILD_INSTALL_PREFIX}/bin/protoc
    -DPROTOBUF_PROTOC_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protoc_libname}
    -DPROTOBUF_PROTOC_LIBRARY_DEBUG:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${protoc_libname}
    )
else()
  set( CAFFE_SEGNET_PROTOBUF_ARGS
    -DPROTOBUF_INCLUDE_DIR:PATH=${PROTOBUF_INCLUDE_DIR}
    -DPROTOBUF_LIBRARY:PATH=${PROTOBUF_LIBRARY}
    -DPROTOBUF_LIBRARY_DEBUG:PATH=${PROTOBUF_LIBRARY_DEBUG}
    -DPROTOBUF_LITE_LIBRARY:PATH=${PROTOBUF_LITE_LIBRARY}
    -DPROTOBUF_LITE_LIBRARY_DEBUG:PATH=${PROTOBUF_LITE_LIBRARY_DEBUG}
    -DPROTOBUF_PROTOC_EXECUTABLE:PATH=${PROTOBUF_PROTOC_EXECUTABLE}
    -DPROTOBUF_PROTOC_LIBRARY:PATH=${PROTOBUF_PROTOC_LIBRARY}
    -DPROTOBUF_PROTOC_LIBRARY_DEBUG:PATH=${PROTOBUF_PROTOC_LIBRARY_DEBUG}
  )
endif()

if(fletch_ENABLE_OpenCV)
  set( CAFFE_SEGNET_OPENCV_ARGS
    -DOpenCV_DIR:PATH=${fletch_BUILD_PREFIX}/src/OpenCV-build
    -DOpenCV_LIB_PATH:PATH=${OpenCV_ROOT}/lib
    )
else()
  set( CAFFE_SEGNET_OPENCV_ARGS
    -DOpenCV_DIR:PATH=${OpenCV_DIR}
  )
endif()

if(fletch_ENABLE_LMDB)
  get_system_library_name( lmdb lmdb_libname )

  set( CAFFE_SEGNET_LMDB_ARGS
    -DLMDB_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DLMDB_LIBRARIES:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${lmdb_libname}
    )
else()
  set( CAFFE_SEGNET_LMDB_ARGS
    -DLMDB_INCLUDE_DIR:PATH=${LMDB_INCLUDE_DIR}
    -DLMDB_LIBRARIES:PATH=${LMDB_LIBRARY}
    )
endif()

if(fletch_ENABLE_LevelDB)
  get_system_library_name( leveldb leveldb_libname )
  # NOTE: CaffeSegnet currently has LevelDB_INCLUDE instead of the normal LevelDB_INCLUDE_DIR
  set( CAFFE_SEGNET_LevelDB_ARGS
    -DLevelDB_INCLUDE:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DLevelDB_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${leveldb_libname}
    )
else()
  set( CAFFE_SEGNET_LevelDB_ARGS
    -DLevelDB_INCLUDE:PATH=${LevelDB_INCLUDE_DIR}
    -DLevelDB_LIBRARY:PATH=${LevelDB_LIBRARY}
    )
endif()

if(fletch_ENABLE_GLog)
  get_system_library_name( glog glog_libname )

  set( CAFFE_SEGNET_GLog_ARGS
    -DGLOG_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DGLOG_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${glog_libname}
    )
else()
  set( CAFFE_SEGNET_GLog_ARGS
    -DGLOG_INCLUDE_DIR:PATH=${GLog_INCLUDE_DIR}
    -DGLOG_LIBRARY:FILEPATH=${GLog_LIBRARY}
    )
endif()

if(fletch_ENABLE_GFlags)
  get_system_library_name( gflags gflags_libname )

  set( CAFFE_SEGNET_GFlags_ARGS
    -DGFLAGS_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DGFLAGS_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${gflags_libname}
    )
else()
  set( CAFFE_SEGNET_GFlags_ARGS -DGFLAGS_ROOT_DIR:PATH=${GFlags_DIR})
endif()

if(fletch_ENABLE_HDF5)

  if( CMAKE_BUILD_TYPE STREQUAL "Debug" )

    get_system_library_name( hdf5_debug hdf5_libname )
    get_system_library_name( hdf5_hl_debug hdf5_hl_libname )
    get_system_library_name( hdf5_cpp_debug hdf5_cpp_libname )
    get_system_library_name( hdf5_hl_cpp_debug hdf5_hl_cpp_libname )


  else()

    get_system_library_name( hdf5 hdf5_libname )
    get_system_library_name( hdf5_hl hdf5_hl_libname )
    get_system_library_name( hdf5_cpp hdf5_cpp_libname )
    get_system_library_name( hdf5_hl_cpp hdf5_hl_cpp_libname )

  endif()
  set( CAFFE_SEGNET_HDF5_ARGS
    -DHDF5_INCLUDE_DIRS:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DHDF5_HL_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
    -DHDF5_LIBRARIES:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_libname}
    -DHDF5_hdf5_LIBRARY_DEBUG:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_libname}
    -DHDF5_hdf5_LIBRARY_RELEASE:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_libname}
    -DHDF5_hdf5_hl_LIBRARY_DEBUG:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_libname}
    -DHDF5_hdf5_hl_LIBRARY_RELEASE:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_libname}
    -DHDF5_HL_LIBRARIES:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_libname}

    -DHDF5_CXX_LIBRARY_hdf5:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_libname}
    -DHDF5_CXX_LIBRARY_hdf5_cpp:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_cpp_libname}
    -DHDF5_CXX_LIBRARY_hdf5_hl:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_libname}
    -DHDF5_CXX_LIBRARY_hdf5_hl_cpp:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_cpp_libname}

    -DHDF5_C_LIBRARY_hdf5_hl:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_libname}
    -DHDF5_C_LIBRARY_hdf5:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${hdf5_hl_libname}

    )
else()
  set( CAFFE_SEGNET_HDF5_ARGS
    -DHDF5_INCLUDE_DIRS:PATH=${HDF5_INCLUDE_DIRS}
    -DHDF5_HL_INCLUDE_DIR:PATH=${HDF5_HL_INCLUDE_DIR}
    -DHDF5_LIBRARIES:PATH=${HDF5_LIBRARIES}
    -DHDF5_hdf5_LIBRARY_DEBUG:PATH=${HDF5_hdf5_LIBRARY_DEBUG}
    -DHDF5_hdf5_LIBRARY_RELEASE:PATH=${HDF5_hdf5_LIBRARY_RELEASE}
    -DHDF5_hdf5_hl_LIBRARY_DEBUG:PATH=${HDF5_hdf5_hl_LIBRARY_DEBUG}
    -DHDF5_hdf5_hl_LIBRARY_RELEASE:PATH=${HDF5_hdf5_hl_LIBRARY_RELEASE}
    -DHDF5_HL_LIBRARIES:PATH=${HDF5_HL_LIBRARIES}
  )
endif()

if(fletch_BUILD_WITH_PYTHON AND fletch_ENABLE_Boost)
  if(Boost_Do_BCP_Name_Mangling)
    message(FATAL_ERROR "Cannot have Boost mangling enabled and use pycaffe.")
  endif()
  find_package(NumPy 1.7 REQUIRED)
  set(PYTHON_ARGS
      -DBUILD_python:BOOL=ON
      -DBUILD_python_layer:BOOL=ON
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DNUMPY_INCLUDE_DIR=${NUMPY_INCLUDE_DIR}
      -DNUMPY_VERSION=${NUMPY_VERSION}
      )
else()
  set(PYTHON_ARGS -DBUILD_python:BOOL=OFF -DBUILD_python_layer:BOOL=OFF)
endif()

set(CAFFE_SEGNET_OPENBLAS_ARGS "-DOpenBLAS_INCLUDE_DIR=${OpenBLAS_INCLUDE_DIR}"
  "-DOpenBLAS_LIB=${OpenBLAS_LIB}")

if(fletch_BUILD_WITH_CUDA)
  format_passdowns("CUDA" CUDA_BUILD_FLAGS)
  set( CAFFE_SEGNET_GPU_ARGS
    ${CUDA_BUILD_FLAGS}
    -DCPU_ONLY:BOOL=OFF
    )
  if(fletch_BUILD_WITH_CUDNN)
    format_passdowns("CUDNN" CUDNN_BUILD_FLAGS)
    set( CAFFE_SEGNET_GPU_ARGS
      ${CAFFE_SEGNET_GPU_ARGS}
      ${CUDNN_BUILD_FLAGS}
      -DUSE_CUDNN:BOOL=ON
    )
  else()
    set( CAFFE_SEGNET_GPU_ARGS
      ${CAFFE_SEGNET_GPU_ARGS}
      -DUSE_CUDNN:BOOL=OFF
    )
  endif()
else()
  set( CAFFE_SEGNET_GPU_ARGS
    -DCPU_ONLY:BOOL=ON
    -DUSE_CUDNN:BOOL=OFF
    )
endif()


set (Caffe_Segnet_PATCH_DIR "${fletch_SOURCE_DIR}/Patches/Caffe_Segnet/${Caffe_Segnet_version}")
if (EXISTS ${Caffe_Segnet_PATCH_DIR})
  set(
    Caffe_Segnet_PATCH_COMMAND ${CMAKE_COMMAND}
    -DCaffe_Segnet_patch=${Caffe_Segnet_PATCH_DIR}
    -DCaffe_Segnet_source=${fletch_BUILD_PREFIX}/src/Caffe_Segnet
    -P ${Caffe_Segnet_PATCH_DIR}/Patch.cmake
    )
else()
  set(Caffe_Segnet_PATCH_COMMAND "")
endif()


# Main build and install command
if(WIN32)
ExternalProject_Add(Caffe_Segnet
  DEPENDS ${Caffe_Segnet_DEPENDS}
  URL ${Caffe_Segnet_url}
  URL_MD5 ${Caffe_Segnet_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  PATCH_COMMAND ${Caffe_Segnet_PATCH_COMMAND}

  CMAKE_COMMAND
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_USE_STATIC_LIBS:BOOL=OFF
    -DBLAS:STRING=Open
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DCAFFE_FORK_SUFFIX:STRING=Segnet
    ${CAFFE_SEGNET_OPENCV_ARGS}
    ${PYTHON_ARGS}
    ${CAFFE_SEGNET_GPU_ARGS}
)
else()
ExternalProject_Add(Caffe_Segnet
  DEPENDS ${Caffe_Segnet_DEPENDS}
  URL ${Caffe_Segnet_url}
  URL_MD5 ${Caffe_Segnet_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  PATCH_COMMAND ${Caffe_Segnet_PATCH_COMMAND}

  CMAKE_COMMAND
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:PATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBLAS:STRING=Open
    -DCAFFE_FORK_SUFFIX:STRING=Segnet
    ${PYTHON_ARGS}
    ${CAFFE_SEGNET_PROTOBUF_ARGS}
    ${CAFFE_SEGNET_OPENCV_ARGS}
    ${CAFFE_SEGNET_LMDB_ARGS}
    ${CAFFE_SEGNET_LevelDB_ARGS}
    ${CAFFE_SEGNET_GLog_ARGS}
    ${CAFFE_SEGNET_GFlags_ARGS}
    ${CAFFE_SEGNET_HDF5_ARGS}
    ${CAFFE_SEGNET_OPENBLAS_ARGS}
    ${CAFFE_SEGNET_GPU_ARGS}
  )
endif()

fletch_external_project_force_install(PACKAGE Caffe_Segnet)

set(Caffe_Segnet_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Caffe Segnet
########################################
set(Caffe_Segnet_ROOT    \${fletch_ROOT})
")
