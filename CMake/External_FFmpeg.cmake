# If a patch file exists for this version, apply it

include(External_yasm)
set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
set(_FFmpeg_yasm --yasmexe=${fletch_YASM})
list(APPEND ffmpeg_DEPENDS yasm)

# Should we try to point ffmpeg at zlib if we are building it?
# Currently it uses the system version.
if (fletch_ENABLE_Zlib)
  list(APPEND ffmpeg_DEPENDS ZLib)
endif()

set (FFmpeg_patch ${fletch_SOURCE_DIR}/Patches/FFmpeg/${_FFmpeg_version})
if (EXISTS ${FFmpeg_patch})
  set(FFMPEG_PATCH_COMMAND ${CMAKE_COMMAND}
    -DFFmpeg_patch:PATH=${FFmpeg_patch}
    -DFFmpeg_source:PATH=${fletch_BUILD_PREFIX}/src/FFmpeg
    -P ${FFmpeg_patch}/Patch.cmake
    )
  else()
  set(FFMPEG_PATCH_COMMAND "")
endif()

if (BUILD_SHARED_LIBS)
  set(_shared_lib_params --enable-shared --disable-static)
else()
  set(_shared_lib_params
     --disable-shared
     --enable-static
     --enable-pic
     --extra-cflags=-fPIC
     --extra-cxxflags=-fPIC
     --disable-asm
    )
endif()

if(fletch_ENABLE_x264)
  if(_FFmpeg_version VERSION_LESS 3.0)
    message(WARNING "FFmpeg version ${_FFmpeg_version} will not build against x264. Version 3.0 required.")
  else()
    include(External_x264)
    list(APPEND ffmpeg_DEPENDS x264)
    set(_FFmpeg_x264 --enable-gpl --enable-libx264)
  endif()
endif()

if(fletch_ENABLE_x265)
  include(External_x265)
  list(APPEND ffmpeg_DEPENDS x265)
  set(_FFmpeg_x265 --enable-gpl --enable-libx265)
endif()

if(fletch_BUILD_WITH_CUDA)
  if(fletch_ENABLE_ffnvcodec)
    include(External_ffnvcodec)
    list(APPEND ffmpeg_DEPENDS ffnvcodec)
    set(_FFmpeg_cuda
      "--enable-cuda\
      --enable-cuvid\
      --enable-nvenc"
      )
  else()
    message(WARNING "FFmpeg will not build NVidia/CUDA hardware-accelerated codecs (fletch_ENABLE_ffnvcodec)")
  endif()
endif()

set(FFMPEG_PKGCONFIG_PATH ${fletch_BUILD_INSTALL_PREFIX}/lib/pkgconfig)
if(WIN32)
  include(External_msys2)
  list(APPEND ffmpeg_DEPENDS msys2)
  set(FFMPEG_COMMAND_PREFIX ${mingw_prefix} ${msys_bash})
  set(FFMPEG_BUILD_COMMAND ${FFMPEG_COMMAND_PREFIX} -c "make -j 8")
  set(FFMPEG_INSTALL_COMMAND ${FFMPEG_COMMAND_PREFIX} -c "make install")

  # We have to transform the path from C:/... to /c/...
  # because : is treated as a delimiter
  set(inner_cmd "env\
	PKG_CONFIG_PATH=`cygpath ${FFMPEG_PKGCONFIG_PATH}`\
    ${fletch_BUILD_PREFIX}/src/FFmpeg/configure\
    --prefix=${fletch_BUILD_INSTALL_PREFIX}\
    --enable-runtime-cpudetect\
    ${_FFmpeg_x264}\
    ${_FFmpeg_x265}\
    ${_FFmpeg_zlib}\
    ${_FFmpeg_cuda}\
    ${_shared_lib_params}\
    --enable-rpath\
    --disable-programs\
    --disable-asm")
  string(REPLACE ";" " " inner_cmd "${inner_cmd}")
  set(FFMPEG_CONFIGURE_COMMAND
    ${FFMPEG_COMMAND_PREFIX} -x -c ${inner_cmd}
    )
else()
  Fletch_Require_Make()
  set(FFMPEG_BUILD_COMMAND ${MAKE_EXECUTABLE})
  set(FFMPEG_INSTALL_COMMAND ${MAKE_EXECUTABLE} install )
  set(FFMPEG_CONFIGURE_COMMAND
    env PKG_CONFIG_PATH=${FFMPEG_PKGCONFIG_PATH}
    ${fletch_BUILD_PREFIX}/src/FFmpeg/configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    --enable-runtime-cpudetect
    ${_FFmpeg_x264}
    ${_FFmpeg_x265}
    ${_FFmpeg_yasm}
    ${_FFmpeg_zlib}
    ${_FFmpeg_cuda}
    ${_shared_lib_params}
    --cc=${CMAKE_C_COMPILER}
    --cxx=${CMAKE_CXX_COMPILER}
    --enable-rpath
    --disable-programs
    )
endif()

if (_FFmpeg_version VERSION_LESS 3.3.0)
  # memalign-hack is only needed for windows and older versions of ffmpeg
  list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-memalign-hack)
  # bzlib errors if not found in newer versions (previously it did not)
  list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-bzlib)
  list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-outdev=sdl)
endif()

if(APPLE)
  list(APPEND FFMPEG_CONFIGURE_COMMAND --sysroot=${CMAKE_OSX_SYSROOT} --disable-doc)
endif()

ExternalProject_Add(FFmpeg
  URL ${FFmpeg_file}
  DEPENDS ${ffmpeg_DEPENDS}
  URL_MD5 ${FFmpeg_md5}
  ${COMMON_EP_ARGS}
  PATCH_COMMAND ${FFMPEG_PATCH_COMMAND}
  CONFIGURE_COMMAND ${FFMPEG_CONFIGURE_COMMAND}
  BUILD_COMMAND ${FFMPEG_BUILD_COMMAND}
  INSTALL_COMMAND ${FFMPEG_INSTALL_COMMAND}
)
fletch_external_project_force_install(PACKAGE FFmpeg)

set(FFmpeg_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# FFmpeg
#######################################
set(FFmpeg_ROOT \${fletch_ROOT})
set(fletch_ENABLED_FFmpeg TRUE)
")
