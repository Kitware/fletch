
if(WIN32)
  ExternalProject_Add(SWIG
    URL ${SWIG_url}
    URL_MD5 ${SWIG_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      -DBUILD_SHARED_LIBS:BOOL=ON
    )
else()
  ExternalProject_Add(SWIG
    URL ${SWIG_url}
    URL_MD5 ${SWIG_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./autogen.sh && ./configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
endif()

fletch_external_project_force_install(PACKAGE SWIG)

set(SWIG_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Google SWIG
#######################################
set(SWIG_ROOT @SWIG_ROOT@)
")
