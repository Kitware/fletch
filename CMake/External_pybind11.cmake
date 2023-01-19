if (PYTHON_EXECUTABLE)
  set(pybind_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE})
endif()

ExternalProject_Add(pybind11
  URL ${pybind11_url}
  URL_MD5 ${pybind11_md5}
  DOWNLOAD_NAME ${pybind11_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    # PYTHON_EXECUTABLE addded to cover when it's installed in nonstandard loc.
    # But don't pass if python isn't enabled. It will prevent pybind from finding it.
    ${pybind_PYTHON_ARGS}
    -DPYBIND11_TEST:BOOL=OFF # To remove dependencies; build can still be tested manually
  )

fletch_external_project_force_install(PACKAGE pybind11)

set(pybind11_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# pybind11
################################
set(pybind11_ROOT \${fletch_ROOT})
set(pybind11_DIR \${fletch_ROOT}/share/cmake/pybind11/)
set(fletch_ENABLED_pybind11 TRUE)
")
