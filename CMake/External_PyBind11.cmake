if (NOT fletch_BUILD_CXX11)
  message(FATAL_ERROR "CXX11 must be enabled to use PyBind11")
endif()

ExternalProject_Add(PyBind11
  URL ${PyBind11_url}
  URL_MD5 ${PyBind11_md5}
  DOWNLOAD_NAME ${PyBind11_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DPYBIND11_TEST:BOOL=OFF # To remove dependencies; build can still be tested manually
    -DPYBIND11_PYTHON_VERSION=${fletch_PYTHON_MAJOR_VERSION}
    -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
    -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
    -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
  )

fletch_external_project_force_install(PACKAGE PyBind11)

set(PyBind11_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# PyBind11
################################
set(PyBind11_ROOT \${fletch_ROOT})

set(fletch_ENABLED_PyBind11 TRUE)
")
