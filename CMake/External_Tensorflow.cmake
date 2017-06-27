# The Tensorflow external project

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
    ${Tensorflow_EXTRA_BUILD_FLAGS}
    ${fletch_BUILD_PREFIX}/src/Tensorflow/tensorflow/contrib/cmake
  BUILD_COMMAND ${MAKE_EXECUTABLE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )

fletch_external_project_force_install(PACKAGE Tensorflow)

set(Tensorflow_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Tensorflow
########################################
set(Tensorflow_ROOT @Tensorflow_ROOT@)
")
