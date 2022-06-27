if(BUILD_SHARED_LIBS)
  set(_shared_lib_params
    --enable-shared
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

if(WIN32)
  include(External_msys2)
  list(APPEND x264_DEPENDS msys2)
  set(X264_COMMAND_PREFIX ${mingw_prefix} ${msys_bash})
  set(_win32_config_params --host=x86_64-w64-mingw32)
  set(X264_BUILD_COMMAND ${X264_COMMAND_PREFIX} -c "make -j 8")
  set(X264_INSTALL_COMMAND ${X264_COMMAND_PREFIX} -c "make install")
else()
  include(External_yasm)
  list(APPEND x264_DEPENDS yasm)
  Fletch_Require_Make()
  set(X264_BUILD_COMMAND ${MAKE_EXECUTABLE})
  set(X264_INSTALL_COMMAND ${MAKE_EXECUTABLE} install)
endif()

set(X264_CONFIGURE_COMMAND
  ${X264_COMMAND_PREFIX}
  ${fletch_BUILD_PREFIX}/src/x264/configure
  --prefix=${fletch_BUILD_INSTALL_PREFIX}
  --disable-cli
  --disable-opencl
  --disable-asm
  ${_shared_lib_params}
  ${_win32_config_params}
  )

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
