if (NOT fletch_BUILD_CXX11)
  message(FATAL_ERROR "CXX11 must be enabled to use PyBind11")
endif()

if (PYTHON_EXECUTABLE)
  set(PyBind_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE})
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
    # PYTHON_EXECUTABLE addded to cover when it's installed in nonstandard loc.
    # But don't pass if python isn't enabled. It will prevent PyBind from finding it.
    ${PyBind_PYTHON_ARGS}
    -DPYBIND11_TEST:BOOL=OFF # To remove dependencies; build can still be tested manually
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
