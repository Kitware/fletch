if (NOT fletch_BUILD_CXX11)
  message(FATAL_ERROR "CXX11 must be enabled to use pybind11")
endif()

if (fletch_ENABLE_CPython)
  add_package_dependency(
    PACKAGE pybind11
    PACKAGE_DEPENDENCY CPython
  )
endif()

if (PYTHON_EXECUTABLE)
  set(PYBIND_PYTHON_ARGS -DPYTHON_EXECUTABLE:PATH=${PYTHON_EXECUTABLE})
  set(PYBIND_PYTHON_ARGS -DPYTHON_LIBRARY:PATH=${PYTHON_LIBRARY} ${PYBIND_PYTHON_ARGS})
  set(PYBIND_PYTHON_ARGS -DPYTHON_LIBRARY_DEBUG:PATH=${PYTHON_LIBRARY_DEBUG} ${PYBIND_PYTHON_ARGS})
  set(PYBIND_PYTHON_ARGS -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR} ${PYBIND_PYTHON_ARGS})
endif()

ExternalProject_Add(pybind11
  DEPENDS ${pybind11_DEPENDS}
  URL ${pybind11_url}
  URL_MD5 ${pybind11_md5}
  DOWNLOAD_NAME ${pybind11_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${fletch_SOURCE_DIR}/Patches/pybind11
    ${fletch_BUILD_PREFIX}/src/pybind11
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    # PYTHON_EXECUTABLE addded to cover when it's installed in nonstandard loc.
    # But don't pass if python isn't enabled. It will prevent pybind from finding it.
    ${PYBIND_PYTHON_ARGS}
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
