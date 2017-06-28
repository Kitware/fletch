# The Tensorflow external project

if(NOT fletch_BUILD_WITH_PYTHON)
  message(FATAL_ERROR "Error: A build with Python is required for building Tensorflow")
endif()

if(WIN32)
  if(NOT fletch_ENABLE_SWIG)
    message(FATAL_ERROR "Error: SWIG is required for building Tensorflow on Windows")
  else()
    set(Tensorflow_DEPENDS ${Tensorflow_DEPENDS} SWIG)
    if(WIN32)
      set(SWIG_BUILD_FLAGS
        -DSWIG_DIR=${fletch_BUILD_PREFIX}/src/SWIG-build
        -DSWIG_EXECUTABLE=${fletch_BUILD_PREFIX}/src/SWIG-build/swig.exe)
    else()
      set(SWIG_BUILD_FLAGS
        -DSWIG_DIR=${fletch_BUILD_INSTALL_PREFIX}
        -DSWIG_EXECUTABLE=${fletch_BUILD_INSTALL_PREFIX}/bin/swig)
    endif()
  endif()

  ExternalProject_Add(Tensorflow
    DEPENDS ${Tensorflow_DEPENDS}
    URL ${Tensorflow_url}
    URL_MD5 ${Tensorflow_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND}
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      -Dtensorflow_BUILD_PYTHON_BINDINGS:BOOL=${fletch_BUILD_WITH_PYTHON}
      -Dtensorflow_ENABLE_GPU:BOOL=${fletch_BUILD_WITH_CUDA}
      ${SWIG_BUILD_FLAGS}
      ${Tensorflow_EXTRA_BUILD_FLAGS}
      ${fletch_BUILD_PREFIX}/src/Tensorflow/tensorflow/contrib/cmake
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
else()
  find_program( Bazel NAMES bazel )

  if( NOT Bazel )
    message( FATAL_ERROR "Unable to find Bazel, required for building Tensorflow" )
  endif()

  set( TENSORFLOW_BUILD_PARAMS --config=opt )

  if( fletch_BUILD_WITH_CUDA )
    set( TENSORFLOW_BUILD_PARAMS ${TENSORFLOW_BUILD_PARAMS} --config=cuda )
  endif()

  set( TENSORFLOW_BUILD_PARAMS ${TENSORFLOW_BUILD_PARAMS}
    //tensorflow/tools/pip_package:build_pip_package )

  ExternalProject_Add(Tensorflow
    DEPENDS ${Tensorflow_DEPENDS}
    URL ${Tensorflow_url}
    URL_MD5 ${Tensorflow_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
    BUILD_COMMAND bazel build
      ${TENSORFLOW_BUILD_PARAMS}
    INSTALL_COMMAND ""
    )
endif()

fletch_external_project_force_install(PACKAGE Tensorflow)

set(Tensorflow_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Tensorflow
########################################
set(Tensorflow_ROOT @Tensorflow_ROOT@)
")
