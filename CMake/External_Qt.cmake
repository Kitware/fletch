# The Qt external project for fletch

option(BUILD_Qt_MINIMAL "Build a reduced set of Qt packages. Removes webkit, javascipt and script" TRUE)
if (Qt_version VERSION_LESS 5.0.0)
  if(BUILD_Qt_MINIMAL)
    set(Qt_args_package -no-webkit -no-openssl)
  else()
    set(Qt_args_package -webkit)
  endif()
elseif(Qt_version VERSION_LESS 5.12 AND
    CMAKE_CXX_COMPILER_ID MATCHES GNU AND
    CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
      set(Qt_args_package -skip qtwebengine -no-qml-debug -skip wayland)
else()
  if(BUILD_Qt_MINIMAL)
    set(Qt_args_package -skip qtwebengine -no-qml-debug)
  else()
    set(Qt_args_package )
  endif()
endif()

if(CMAKE_BUILD_TYPE)
  string(TOLOWER "${CMAKE_BUILD_TYPE}" QT_BUILD_TYPE)
  if(QT_BUILD_TYPE STREQUAL "debug")
    set(Qt_args_build_type "-debug")
  else()
    set(Qt_args_build_type "-release")
  endif()
elseif(CMAKE_CONFIGURATION_TYPES)
  string(TOLOWER "${CMAKE_CONFIGURATION_TYPES}" QT_CONF_TYPE)
  if(QT_CONF_TYPE STREQUAL "debug")
    set(Qt_args_build_type "-debug")
  elseif(QT_CONF_TYPE STREQUAL "release")
    set(Qt_args_build_type "-release")
  else()
    # Common Visual Studio option, allows user to change selector.
    set(Qt_args_build_type "-debug-and-release")
  endif()
else()
  # Unknown-configuration projects. Build debug AND release to be safe.
  set(Qt_args_build_type "-debug-and-release")
endif()

# JPEG
add_package_dependency(
  PACKAGE Qt
  PACKAGE_DEPENDENCY libjpeg-turbo
  PACKAGE_DEPENDENCY_ALIAS JPEG
  OPTIONAL
  EMBEDDED
)
if(Qt_WITH_libjpeg-turbo)
  set(Qt_args_jpeg
    -system-libjpeg
    -I ${fletch_BUILD_INSTALL_PREFIX}/include
    -L ${fletch_BUILD_INSTALL_PREFIX}/lib
    )
endif()

# ZLib
add_package_dependency(
  PACKAGE Qt
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
  OPTIONAL
  EMBEDDED
)
if(Qt_WITH_ZLib)
  set(Qt_args_zlib
    -system-zlib
    -I ${fletch_BUILD_INSTALL_PREFIX}/include
    -L ${fletch_BUILD_INSTALL_PREFIX}/lib
    )
endif()

# PNG
add_package_dependency(
  PACKAGE Qt
  PACKAGE_DEPENDENCY PNG
  OPTIONAL
  EMBEDDED
)
if(Qt_WITH_PNG)
  set(Qt_args_PNG
    -system-libpng
    -I ${fletch_BUILD_INSTALL_PREFIX}/include
    -L ${fletch_BUILD_INSTALL_PREFIX}/lib
    )
endif()

if(WIN32)
  include(External_jom) # since this is only used by Qt on windows include here
  list(APPEND Qt_DEPENDS jom)

  set(JOM_EXE "${fletch_BUILD_PREFIX}/src/jom/jom.exe")

  if (Qt_version VERSION_LESS 5.0.0)
    set(Qt_configure configure.exe)
  else()
    set(Qt_configure configure.bat)
  endif()

  if(Qt_WITH_ZLib)
    # Jom needs the path to zlib.dll to build correctly with zlib
    list(APPEND Qt_ADDITIONAL_PATH ${fletch_BUILD_INSTALL_PREFIX}/bin)
  endif()

  set(Qt_build ${fletch_BUILD_PREFIX}/src/Qt-build/BuildQt.bat)
  configure_file(
    ${fletch_SOURCE_DIR}/Patches/Qt/BuildQt.bat.in
    ${Qt_build}
    )

  # Qt has a race condition (https://bugreports.qt.io/browse/QTBUG-28132) where
  # multi-thread builds can intermittantly fail.  Essentially during the install
  # step different targets will check if a directory exists and call MD when it doesn't.
  # On windows if the race is a tie and two threads see that the directory doesn't exist,
  # the second thread will error out because MD fails if the directory exists.  A
  # Work around is to turn off multi threaded builds for install:
  set(Qt_install_cmd ${JOM_EXE} -j1 install)
  if (Qt_version VERSION_LESS 5.0.0)
    #We have some trouble determining the correct platform for VS2013 and VS2017
    if(MSVC12)
      list(APPEND Qt_args_arch -platform win32-msvc2013)
    elseif(MSVC AND NOT MSVC_VERSION LESS 1910)
      list(APPEND Qt_args_arch -platform win32-msvc2017 -make nmake)
    endif()
  endif()
else()
  set(env ${CMAKE_COMMAND} -E env)

  set(configure_env_var PKG_CONFIG_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig)
  if(NOT "$ENV{PKG_CONFIG_PATH}" STREQUAL "")
    set(configure_env_var "${configure_env_var}:$ENV{PKG_CONFIG_PATH}")
  endif()
  if (Qt_version VERSION_LESS 5.0.0)
    if(BUILD_Qt_MINIMAL)
      list(APPEND Qt_args_package -no-javascript-jit -no-script -no-scripttools)
    else()
      set(Qt_args_package -javascript-jit -script -scripttools)
    endif()
    # If we are using gcc >= 6.0 we need to turn off -no-script -no-scripttools
    # until the build is fixed.
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
      set(BUILD_Qt_MINIMAL TRUE CACHE BOOL "" FORCE)
      message(STATUS "disabling script for GNU 6.0")
    endif()
  endif()

  Fletch_Require_Make()
  if(APPLE)
    set(build_env_var DYLD_LIBRARY_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib)
    if(NOT "$ENV{DYLD_LIBRARY_PATH}" STREQUAL "")
      set(build_env_var "${build_env_var}:$ENV{DYLD_LIBRARY_PATH}")
    endif()
  else()
    set(build_env_var LD_LIBRARY_PATH=${fletch_BUILD_INSTALL_PREFIX}/lib)
    if(NOT "$ENV{LD_LIBRARY_PATH}" STREQUAL "")
      set(build_env_var "${build_env_var}:$ENV{LD_LIBRARY_PATH}")
    endif()
  endif()
  set(Qt_configure ${env} ${configure_env_var} ./configure)
  set(Qt_build ${env} ${build_env_var} ${MAKE_EXECUTABLE})
  set(Qt_install_cmd ${MAKE_EXECUTABLE} install)
  set(Qt_args_other -no-cups -optimized-qmake)

  if(APPLE)
    if (Qt_version VERSION_LESS 5.0.0)
      #Qt does not allow pure debug builds with frameworks.
      #So far it only appears to cause an issue with APPLE,
      #Until we decide framework is important, disable it.
      #For reference, see http://qt-project.org/doc/qt-4.8/debug.html
      set(Qt_args_framework "-no-framework")
      set(Qt_args_arch -arch x86_64 -cocoa)
      if(NOT (CMAKE_SYSTEM_VERSION VERSION_LESS "16"))
        # Phonon is broken on macOS 10.12+ (Darwin 16+) due to QTKit.framework being removed.
        list(APPEND Qt_args_other -no-phonon)
      endif()
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # Create a spec file for gcc44 on RHEL5
    if(CMAKE_C_COMPILER MATCHES "gcc44" OR CMAKE_CXX_COMPILER MATCHES "g\\+\\+44")
      list(APPEND Qt_args_arch -platform linux-g++44)
    endif()

    # Disable AVX support if the kernel is too old
    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.([0-9]+)?" KERNEL_VERSION "${CMAKE_SYSTEM_VERSION}")
    if(KERNEL_VERSION VERSION_LESS "2.6.30")
      list(APPEND Qt_args_arch -no-avx)
    endif()
  endif()
endif()


# Set version specific output directory
if (Qt_version VERSION_LESS 5.0.0)
  set( Qt_DIR_NAME "qt4" )
else()
  set( Qt_DIR_NAME "qt5" )
endif()

list( APPEND Qt_configure
  -prefix ${fletch_BUILD_INSTALL_PREFIX}
  -docdir ${fletch_BUILD_INSTALL_PREFIX}/share/doc/${Qt_DIR_NAME}-${Qt_version}
  -datadir ${fletch_BUILD_INSTALL_PREFIX}/lib/${Qt_DIR_NAME}
  -plugindir ${fletch_BUILD_INSTALL_PREFIX}/lib/${Qt_DIR_NAME}/plugins
  -importdir ${fletch_BUILD_INSTALL_PREFIX}/lib/${Qt_DIR_NAME}/imports
  -opensource -confirm-license
  -nomake examples  ${Qt_args_build_type}
  ${Qt_args_package}
  ${Qt_args_arch}
  ${Qt_args_jpeg}
  ${Qt_args_zlib}
  ${Qt_args_PNG}
  ${Qt_args_other}
  ${Qt_args_framework}
  )

if (NOT Qt_version VERSION_LESS 5.0.0)
# The qtlocation module from Qt5 is currently broken.
# Disable until a fix is found.
  list( APPEND Qt_configure
    -skip qtlocation )
endif()

# Additional options for Qt4
if (Qt_version VERSION_LESS 5.0.0)
  list( APPEND Qt_configure
    -nomake demos -nomake translations -nomake linguist
    -fast )
endif()


if (WIN32 AND NOT (Qt_version VERSION_LESS 5.0.0) )
  # Dynamic OpenGL is the recommended way to build Qt5 on Windows
  # and is required by VTK
  list( APPEND Qt_configure
    -opengl dynamic )
endif()

if (APPLE AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if (Qt_version VERSION_LESS 5.0.0)
    list (APPEND Qt_configure
      -platform unsupported/macx-clang )
  else()
    list (APPEND Qt_configure
      -platform macx-clang )
  endif()
endif()

# If a patch file exists for this version, apply it
set (Qt_patch ${fletch_SOURCE_DIR}/Patches/Qt/${Qt_version})
if (EXISTS ${Qt_patch})
  set(QT_PATCH_COMMAND ${CMAKE_COMMAND}
    -DQt_CFLAGS:STRING=${CMAKE_C_FLAGS}
    -DQt_CXXFLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DQt_patch:PATH=${Qt_patch}
    -DQt_source:PATH=${fletch_BUILD_PREFIX}/src/Qt
    -DQt_install:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -P ${Qt_patch}/Patch.cmake
    )
endif()

ExternalProject_Add(Qt
  DEPENDS ${Qt_DEPENDS}
  URL ${Qt_file}
  URL_MD5 ${Qt_md5}
  ${COMMON_EP_ARGS}
  BUILD_IN_SOURCE 1
  PATCH_COMMAND ${QT_PATCH_COMMAND}
  CONFIGURE_COMMAND ${Qt_configure}
  BUILD_COMMAND ${Qt_build}
  INSTALL_COMMAND ${Qt_install_cmd}
  STEP_TARGETS download
  )
add_dependencies(Download Qt-download)

fletch_external_project_force_install(PACKAGE Qt)

if(Qt_version VERSION_LESS 5.0.0)
  set(QT_QMAKE_EXECUTABLE ${fletch_BUILD_INSTALL_PREFIX}/bin/qmake
    CACHE FILEPATH "" FORCE )

  file(APPEND ${fletch_CONFIG_INPUT} [[
########################################
# Qt
########################################
set(QT_QMAKE_EXECUTABLE ${fletch_ROOT}/bin/qmake)

set(fletch_ENABLED_Qt TRUE)
]])
else()
  set(Qt5_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/Qt5
    CACHE FILEPATH "" FORCE )

  file(APPEND ${fletch_CONFIG_INPUT} [[
########################################
# Qt
########################################
set(Qt5_DIR ${fletch_ROOT}/lib/cmake/Qt5)

set(fletch_ENABLED_Qt TRUE)
]])
endif()
