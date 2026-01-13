if(BUILD_SHARED_LIBS)
  set(_shared_lib_params
    --enable-shared
    )
else()
  if(WIN32)
    # MSVC doesn't use -fPIC
    set(_shared_lib_params
      --enable-static
      --disable-asm
      )
  else()
    set(_shared_lib_params
      --enable-static
      --enable-pic
      --extra-cflags=-fPIC
      --extra-cxxflags=-fPIC
      --disable-asm
      )
  endif()
endif()

if(WIN32)
  include(External_msys2)
  list(APPEND x264_DEPENDS msys2)

  # Get the Visual Studio tools directory from CMAKE_C_COMPILER (cl.exe)
  get_filename_component(_MSVC_TOOLS_DIR "${CMAKE_C_COMPILER}" DIRECTORY)
  # Convert Windows path to MSYS2 path format
  string(REPLACE "\\" "/" _MSVC_TOOLS_DIR_UNIX "${_MSVC_TOOLS_DIR}")
  string(REGEX REPLACE "^([A-Za-z]):" "/\\1" _MSVC_TOOLS_PATH "${_MSVC_TOOLS_DIR_UNIX}")

  # Use MSYS environment (not MINGW64) with MSVC tools in PATH
  set(X264_COMMAND_PREFIX ${msys_env} MSYSTEM=MSYS PATH=${_MSVC_TOOLS_PATH}:/usr/local/bin:/usr/bin:/bin ${msys_bash})

  # Configure x264 with MSVC - set CC=cl to use MSVC compiler
  set(_win32_config_params CC=cl)
  set(X264_BUILD_COMMAND ${X264_COMMAND_PREFIX} -c "make -j 8")
  set(X264_INSTALL_COMMAND ${X264_COMMAND_PREFIX} -c "make install")
else()
  include(External_yasm)
  list(APPEND x264_DEPENDS yasm)
  Fletch_Require_Make()
  set(X264_BUILD_COMMAND ${MAKE_EXECUTABLE})
  set(X264_INSTALL_COMMAND ${MAKE_EXECUTABLE} install)
endif()

if(WIN32)
  # Build command string similar to FFmpeg pattern - use multiline string and replace semicolons
  set(x264_inner_cmd "${_win32_config_params}\
    ${fletch_BUILD_PREFIX}/src/x264/configure\
    --prefix=${fletch_BUILD_INSTALL_PREFIX}\
    --disable-cli\
    --disable-opencl\
    --disable-asm\
    ${_shared_lib_params}")
  string(REPLACE ";" " " x264_inner_cmd "${x264_inner_cmd}")
  set(X264_CONFIGURE_COMMAND
    ${X264_COMMAND_PREFIX} -c ${x264_inner_cmd}
    )
else()
  set(X264_CONFIGURE_COMMAND
    ${X264_COMMAND_PREFIX}
    ${fletch_BUILD_PREFIX}/src/x264/configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    --disable-cli
    --disable-opencl
    --disable-asm
    ${_shared_lib_params}
    )
endif()

ExternalProject_Add(x264
  URL ${x264_url}
  DEPENDS ${x264_DEPENDS}
  URL_MD5 ${x264_md5}
  ${COMMON_EP_ARGS}
  CONFIGURE_COMMAND ${X264_CONFIGURE_COMMAND}
  BUILD_COMMAND ${X264_BUILD_COMMAND}
  INSTALL_COMMAND ${X264_INSTALL_COMMAND}
  )

fletch_external_project_force_install(PACKAGE x264)

set(x264_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
