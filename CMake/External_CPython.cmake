# --------------------------- PYTHON INTERPRETER -------------------------------

if( fletch_ENABLE_ZLib )
  add_package_dependency(
    PACKAGE CPython
    PACKAGE_DEPENDENCY ZLib
    PACKAGE_DEPENDENCY_ALIAS ZLIB
    )
endif()

set( PYTHON_BASEPATH
  ${fletch_BUILD_INSTALL_PREFIX}/lib/python${CPython_version} )

set( BUILT_PYTHON_EXE     ${fletch_BUILD_INSTALL_PREFIX}/bin/python )
set( BUILT_PYTHON_INCLUDE ${fletch_BUILD_INSTALL_PREFIX}/include/python${CPython_version} )
set( BUILT_PYTHON_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/ )

if( fletch_PYTHON_MAJOR_VERSION MATCHES "^3.*" )
  set( CPYTHON_PATCH_CMD ${CMAKE_COMMAND} -E copy_directory
      ${fletch_SOURCE_DIR}/Patches/CPython/python3${CPython_version_minor}
      ${fletch_BUILD_PREFIX}/src/CPython )
else()
  set( CPYTHON_PATCH_CMD "" )
endif()

if( WIN32 )
  set( CPYTHON_DIR ${fletch_BUILD_DIR}/build/src/CPython )
  set( CPYTHON_BUILD_ARGS -e )

  if( CMAKE_SIZEOF_VOID_P GREATER_EQUAL 8 )
    set( CPYTHON_BUILD_ARGS ${CPYTHON_BUILD_ARGS} -p x64 )
  endif()

  if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
    set( CPYTHON_BUILD_ARGS ${CPYTHON_BUILD_ARGS} -c Debug )
  else()
    set( CPYTHON_BUILD_ARGS ${CPYTHON_BUILD_ARGS} -c Release )
  endif()

  ExternalProject_Add( CPython
    DEPENDS ${CPython_DEPENDS}
    URL ${CPython_url}
    URL_MD5 ${CPython_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CPYTHON_PATCH_CMD}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND PCBuild/build.bat ${CPYTHON_BUILD_ARGS}
    INSTALL_COMMAND ${CMAKE_COMMAND}
      -Dfletch_BUILD_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DCPYTHON_BUILD_LOC:PATH=${CPYTHON_DIR}
      -DPYTHON_BASEPATH:PATH=${PYTHON_BASEPATH}
      -P ${fletch_SOURCE_DIR}/Patches/CPython/install_python_windows.cmake
  )

  set( LIBNAME python${CPython_version_major}.lib )

  set( BUILT_PYTHON_EXE     ${BUILT_PYTHON_EXE}.exe )
  set( BUILT_PYTHON_LIBRARY ${BUILT_PYTHON_LIBRARY}/lib/${LIBNAME} )
else()
  # Build CPython twice on Linux, once shared then again staticly
  #
  # This is because both shared and static libs can't be installed from
  # the configuration currently, and we desire shared libs to be in the
  # installation, but want our python interpreter to still be installed
  # as a static exe for both speed optimizations and ease of use.
  set( CPYTHON_BUILD_ARGS_STATIC
       --prefix=${fletch_BUILD_INSTALL_PREFIX}
       --enable-optimizations
  )

  execute_process( COMMAND lsb_release -cs
    OUTPUT_VARIABLE RELEASE_CODENAME
    OUTPUT_STRIP_TRAILING_WHITESPACE )

  if( "${RELEASE_CODENAME}" MATCHES "xenial" OR
      "${RELEASE_CODENAME}" MATCHES "trusty" OR
      "${RELEASE_CODENAME}" MATCHES "bionic" )
    set( CPYTHON_BUILD_ARGS_STATIC ${CPYTHON_BUILD_ARGS_STATIC} --with-fpectl )
  endif()

  if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
    set( CPYTHON_BUILD_ARGS_STATIC ${CPYTHON_BUILD_ARGS_STATIC} --with-pydebug )
  endif()

  set( CPYTHON_BUILD_ARGS_SHARED ${CPYTHON_BUILD_ARGS_STATIC} --enable-shared )

  Fletch_Require_Make()
  ExternalProject_Add( CPython-shared
    DEPENDS ${CPython_DEPENDS}
    URL ${CPython_url}
    URL_MD5 ${CPython_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure ${CPYTHON_BUILD_ARGS_SHARED}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )
  Fletch_Require_Make()
  ExternalProject_Add( CPython
    DEPENDS CPython-shared
    URL ${CPython_url}
    URL_MD5 ${CPython_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CPYTHON_PATCH_CMD}
    CONFIGURE_COMMAND ./configure ${CPYTHON_BUILD_ARGS_STATIC}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )
  ExternalProject_Add_Step( CPython add-extra-symlinks
    COMMAND ${CMAKE_COMMAND} -E env
      ln -sfn python${CPython_version_major}
        ${fletch_BUILD_INSTALL_PREFIX}/bin/python &&
      ln -sfn pip${CPython_version_major}
        ${fletch_BUILD_INSTALL_PREFIX}/bin/pip
    DEPENDEES install
  )

  set( LIBNAME libpython${CPython_version}${CPython_version_modifier}.so )

  set( BUILT_PYTHON_LIBRARY ${BUILT_PYTHON_LIBRARY}/lib/${LIBNAME} )
endif()

# For internal modules in fletch building against python
set( PYTHON_FOUND TRUE CACHE INTERNAL "Forced" FORCE )
set( PYTHON_VERSION_MAJOR ${CPython_version_major} CACHE INTERNAL "Forced" FORCE )
set( PYTHON_VERSION_MINOR ${CPython_version_minor} CACHE INTERNAL "Forced" FORCE )
set( PYTHON_EXECUTABLE ${BUILT_PYTHON_EXE} CACHE PATH "Forced" FORCE )
set( PYTHON_INCLUDE_DIR ${BUILT_PYTHON_INCLUDE} CACHE PATH "Forced" FORCE )
set( PYTHON_LIBRARY ${BUILT_PYTHON_LIBRARY} CACHE PATH "Forced" FORCE )
set( PYTHON_LIBRARY_DEBUG ${BUILT_PYTHON_LIBRARY} CACHE PATH "Forced" FORCE )

# For external modules linking against fletch using python
set( CPython_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE )
file( APPEND ${fletch_CONFIG_INPUT} "
################################
# Python
################################
set( CPython_ROOT \${fletch_ROOT} )
set( fletch_ENABLED_CPython TRUE )
set( PYTHON_VERSION ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} )
set( PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE} )
set( PYTHON_INCLUDE_DIR ${PYTHON_INCLUDE_DIR} )
set( PYTHON_LIBRARY ${PYTHON_LIBRARY} )
set( PYTHON_LIBRARY_DEBUG ${PYTHON_LIBRARY_DEBUG} )
")