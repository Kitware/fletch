# Setup restricted search paths
macro(setup_find_root_context PKG)
  if(${PKG}_ROOT)
    set(_CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
    set(_CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
    set(CMAKE_FIND_ROOT_PATH "${${PKG}_ROOT}")
    set(CMAKE_PREFIX_PATH /)
    set(_${PKG}_FIND_OPTS ${${PKG}_FIND_OPTS})
    set(${PKG}_FIND_OPTS ONLY_CMAKE_FIND_ROOT_PATH ${${PKG}_FIND_OPTS})
  endif()
endmacro()


# Restore original search paths
macro(restore_find_root_context PKG)
  if(${PKG}_ROOT)
    set(CMAKE_FIND_ROOT_PATH "${_CMAKE_FIND_ROOT_PATH}")
    set(CMAKE_PREFIX_PATH "${_CMAKE_PREFIX_PATH}")
    set(${PKG}_FIND_OPTS ${_${PKG}_FIND_OPTS})
  endif()
endmacro()

macro(fletch_FIND_PYTHON)
  # If we change python versions re-find the bin, include, and libs
  if (NOT _prev_fletch_pymajor_version STREQUAL fletch_PYTHON_MAJOR_VERSION)
    # but dont clobber initial settings in the instance they are specified via
    # commandline (e.g  cmake -DPYTHON_EXECUTABLE=/my/special/python)
    if (_prev_fletch_pymajor_version)
      message(STATUS "The Python version changed; refinding the interpreter")
      message(STATUS "Previous python version was ${_prev_fletch_pymajor_version}")
      unset(_prev_fletch_pymajor_version CACHE)
      unset(PYTHON_EXECUTABLE CACHE)
      unset(PYTHON_INCLUDE_DIR CACHE)
      unset(PYTHON_LIBRARY CACHE)
      unset(PYTHON_LIBRARY_DEBUG CACHE)
    endif()
  endif()

  # Make a copy so we can determine if the user changes python versions
  set(_prev_fletch_pymajor_version "${fletch_PYTHON_MAJOR_VERSION}" CACHE INTERNAL
    "allows us to determine if the user changes python version")
  if (fletch_PYTHON_MAJOR_VERSION STREQUAL "3")
    find_package(PythonInterp 3.4 REQUIRED)
    find_package(PythonLibs 3.4 REQUIRED)
  else()
    find_package(PythonInterp 2.7 REQUIRED)
    find_package(PythonLibs 2.7 REQUIRED)
  endif()

  # Check to ensure that the python executable agrees with the major version
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" -c "import sys; print(sys.version[0:3])"
    RESULT_VARIABLE _exitcode
    OUTPUT_VARIABLE _python_version)
  if(NOT ${_exitcode} EQUAL 0)
    message(FATAL_ERROR "Python command to get version failed with error code: ${_exitcode}")
  endif()
  # Remove supurflous newlines (artifacts of print)
  string(STRIP "${_python_version}" _python_version)

  if(NOT _python_version MATCHES "^${fletch_PYTHON_MAJOR_VERSION}.*")
    message(FATAL_ERROR "Requested python \"${fletch_PYTHON_MAJOR_VERSION}\" but got \"${_python_version}\"")
  endif()
endmacro()