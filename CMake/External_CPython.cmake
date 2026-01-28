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

  # Add free-threaded (GIL-less) build flag for Python 3.13+
  if( CPython_free_threaded )
    set( CPYTHON_BUILD_ARGS ${CPYTHON_BUILD_ARGS} --disable-gil )
  endif()

  # Determine the platform toolset to match the current Visual Studio version
  if( CMAKE_GENERATOR_TOOLSET )
    set( CPYTHON_PLATFORM_TOOLSET ${CMAKE_GENERATOR_TOOLSET} )
  elseif( MSVC_TOOLSET_VERSION )
    set( CPYTHON_PLATFORM_TOOLSET v${MSVC_TOOLSET_VERSION} )
  elseif( CMAKE_GENERATOR MATCHES "Visual Studio ([0-9]+)" )
    # Extract VS version from generator and construct toolset (e.g., VS 18 -> v180)
    set( CPYTHON_PLATFORM_TOOLSET v${CMAKE_MATCH_1}0 )
  endif()

  # Create a wrapper script to call build.bat with the correct MSBuild properties
  # This avoids CMake list parsing issues with the = sign
  # Note: The MSBuild property must be quoted to prevent batch from splitting at =
  if( CPYTHON_PLATFORM_TOOLSET )
    set( CPYTHON_BUILD_SCRIPT ${fletch_BUILD_PREFIX}/tmp/CPython/build_python.bat )
    # Use SHIFT to handle the first argument (directory) and pass remaining args
    file( WRITE ${CPYTHON_BUILD_SCRIPT}
"@echo off
setlocal
set CPYTHON_DIR=%~1
shift
cd /d %CPYTHON_DIR%
call PCBuild\\build.bat %1 %2 %3 %4 %5 %6 %7 %8 %9 \"/p:PlatformToolset=${CPYTHON_PLATFORM_TOOLSET}\"
" )
    set( CPYTHON_BUILD_CMD ${CPYTHON_BUILD_SCRIPT} ${CPYTHON_DIR} ${CPYTHON_BUILD_ARGS} )
  else()
    set( CPYTHON_BUILD_CMD PCBuild/build.bat ${CPYTHON_BUILD_ARGS} )
  endif()

  ExternalProject_Add( CPython
    DEPENDS ${CPython_DEPENDS}
    URL ${CPython_url}
    URL_MD5 ${CPython_md5}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${CPYTHON_PATCH_CMD}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CPYTHON_BUILD_CMD}
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

  if( CPython_version VERSION_GREATER_EQUAL "3.8" )
    set( CPYTHON_BUILD_ARGS_STATIC
       ${CPYTHON_BUILD_ARGS_STATIC}
       --with-openssl=/usr
    )
  endif()

  # Add free-threaded (GIL-less) build flag for Python 3.13+
  if( CPython_free_threaded )
    set( CPYTHON_BUILD_ARGS_STATIC ${CPYTHON_BUILD_ARGS_STATIC} --disable-gil )
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

# --------------------- ADD ANY EXTRA PYTHON LIBS HERE -------------------------

set( DEFAULT_LIBS "cython ordered_set" )

if( CPython_version VERSION_GREATER_EQUAL "3.8" )
  set( DEFAULT_LIBS "${DEFAULT_LIBS} numpy pip" )
else()
  set( DEFAULT_LIBS "${DEFAULT_LIBS} numpy==1.19.5" )
endif()

if( NOT WIN32 )
  set( DEFAULT_LIBS "${DEFAULT_LIBS} wheel" )
endif()

set( DEFAULT_HELP "Python libraries to pip install" )
set( fletch_PYTHON_LIBRARIES "${DEFAULT_LIBS}" CACHE STRING "${DEFAULT_HELP}" )

set( fletch_PYTHON_LIB_IDS PythonLibs )
set( fletch_PYTHON_LIB_CMDS "${fletch_PYTHON_LIBRARIES}" )

if( WIN32 )
  set( CUSTOM_PYTHONPATH
    ${PYTHON_BASEPATH};${PYTHON_BASEPATH}/site-packages;${PYTHON_BASEPATH}/dist-packages )
  set( CUSTOM_PATH
    ${fletch_BUILD_INSTALL_PREFIX}/bin )
  set( CUSTOM_PYTHONHOME
    ${fletch_BUILD_INSTALL_PREFIX} )

  set( ENV{PYTHONPATH} "${CUSTOM_PYTHONPATH}" )
  set( ENV{PYTHONHOME} "${CUSTOM_PYTHONHOME}" )

  string( REPLACE ";" "----" CUSTOM_PYTHONPATH "${CUSTOM_PYTHONPATH}" )
  string( REPLACE ";" "----" CUSTOM_PATH "${CUSTOM_PATH}" )
  string( REPLACE "/" "\\" CUSTOM_PYTHONHOME "${CUSTOM_PYTHONHOME}" )
else()
  set( CUSTOM_PYTHONPATH
    ${PYTHON_BASEPATH}:${PYTHON_BASEPATH}/site-packages:${PYTHON_BASEPATH}/dist-packages )
  set( CUSTOM_PATH
    ${fletch_BUILD_INSTALL_PREFIX}/bin )
  set( CUSTOM_PYTHONHOME
    ${fletch_BUILD_INSTALL_PREFIX} )
endif()

set( fletch_PYTHON_LIBS_DEPS CPython )

if( WIN32 )
  ExternalProject_Add( CPython-pip
    DEPENDS ${fletch_PYTHON_LIBS_DEPS}
    PREFIX ${fletch_BUILD_PREFIX}
    SOURCE_DIR ${fletch_CMAKE_DIR}
    USES_TERMINAL_BUILD 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND  ${CMAKE_COMMAND}
        -E env "PYTHONPATH=${CUSTOM_PYTHONPATH}"
               "PATH=${CUSTOM_PATH}"
               "PYTHONUSERBASE=${CUSTOM_PYTHONHOME}"
      ${PYTHON_EXECUTABLE} ${fletch_SOURCE_DIR}/Patches/CPython/extract_pip.py
    INSTALL_COMMAND ${CMAKE_COMMAND}
      -DPYTHON_MAJOR:STRING=${PYTHON_VERSION_MAJOR}
      -DPYTHON_MINOR:STRING=${PYTHON_VERSION_MINOR}
      -DSOURCE_DIRECTORY:PATH=${fletch_BUILD_DIR}/build/src/CPython-pip-build
      -DINSTALL_DIRECTORY:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -P ${fletch_SOURCE_DIR}/Patches/CPython/install_pip_windows.cmake
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    LIST_SEPARATOR "----"
  )
  set( fletch_PYTHON_LIBS_DEPS ${fletch_PYTHON_LIBS_DEPS} CPython-pip )
endif()

if( fletch_PYTHON_LIB_IDS )
  list( LENGTH fletch_PYTHON_LIB_IDS DEP_COUNT )
  math( EXPR DEP_COUNT "${DEP_COUNT} - 1" )

  foreach( ID RANGE ${DEP_COUNT} )

    list( GET fletch_PYTHON_LIB_IDS ${ID} DEP )
    list( GET fletch_PYTHON_LIB_CMDS ${ID} CMD )

    set( fletch_PROJECT_LIST ${fletch_PROJECT_LIST} ${DEP} )

    set( PYTHON_DEP_PIP_CMD pip install --user ${CMD} )
    string( REPLACE " " ";" PYTHON_DEP_PIP_CMD "${PYTHON_DEP_PIP_CMD}" )

    set( PYTHON_DEP_INSTALL
      ${CMAKE_COMMAND} -E env "PYTHONPATH=${CUSTOM_PYTHONPATH}"
                              "PATH=${CUSTOM_PATH}"
                              "PYTHONUSERBASE=${CUSTOM_PYTHONHOME}"
        ${PYTHON_EXECUTABLE} -m ${PYTHON_DEP_PIP_CMD}
      )

    ExternalProject_Add( ${DEP}
      DEPENDS ${fletch_PYTHON_LIBS_DEPS}
      PREFIX ${fletch_BUILD_PREFIX}
      SOURCE_DIR ${fletch_CMAKE_DIR}
      USES_TERMINAL_BUILD 1
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ${PYTHON_DEP_INSTALL}
      INSTALL_COMMAND ""
      INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
      LIST_SEPARATOR "----"
      )
    set( fletch_ENABLE_${DEP} ON )
  endforeach()
endif()
