# If a patch file exists for this version, apply it

if (WIN32)
  # On windows, FFMPEG relies on prebuilt binaries. These binaries come in two
  # archives, dev and shared. An external project is added for each of them just
  # for the download.
  # The FFmpeg external project then takes care of combining the dev and shared
  # binaries into the install directory using the Patches/FFmpeg/Install.cmake
  # script.
  ExternalProject_Add(FFmpeg_dev
    URL ${FFmpeg_dev_url}
    URL_MD5 ${FFmpeg_dev_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )
  fletch_external_project_force_install(PACKAGE FFmpeg_dev)

  ExternalProject_Add(FFmpeg_shared
    URL ${FFmpeg_shared_url}
    URL_MD5 ${FFmpeg_shared_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )
  fletch_external_project_force_install(PACKAGE FFmpeg_shared)

  # directly install prebuilt-binaries and shared libraries on windows
  set (FFmpeg_patch "${fletch_SOURCE_DIR}/Patches/FFmpeg/win32")
  ExternalProject_Add(FFmpeg
    DEPENDS "FFmpeg_dev;FFmpeg_shared"
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND}
    -DFFmpeg_dev_SOURCE=${fletch_BUILD_PREFIX}/src/FFmpeg_dev
    -DFFmpeg_shared_SOURCE=${fletch_BUILD_PREFIX}/src/FFmpeg_shared
    -DFFmpeg_INSTALL=${fletch_BUILD_INSTALL_PREFIX}
    -DFFmpeg_PATCH=${FFmpeg_patch}
    -P "${FFmpeg_patch}/Install.cmake"
    # no patch command on windows
    )
  fletch_external_project_force_install(PACKAGE FFmpeg)

else ()
  include(External_yasm)
  set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
  set(_FFmpeg_yasm --yasmexe=${fletch_YASM})
  list(APPEND ffmpeg_DEPENDS yasm)

  # Should we try to point ffmpeg at zlib if we are building it?
  # Currently it uses the system version.
  #if (fletch_ENABLE_Zlib)
  #  list(APPEND ffmpeg_DEPENDS ZLib)
  #endif()

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

  set(FFMPEG_CONFIGURE_COMMAND
    ${fletch_BUILD_PREFIX}/src/FFmpeg/configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    --enable-shared
    --disable-static
    --enable-runtime-cpudetect
    --enable-zlib
    ${_FFmpeg_yasm}
    --cc=${CMAKE_C_COMPILER}
    --cxx=${CMAKE_CXX_COMPILER}
    # enable-rpath allows libavcodec to find libswresample
    --enable-rpath
    )

  if (_FFmpeg_version VERSION_LESS 3.3.0)
    # memalign-hack is only needed for windows and older versions of ffmpeg
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-memalign-hack)
    # bzlib errors if not found in newer versions (previously it did not)
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-bzlib)
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-outdev=sdl)
  endif()


  Fletch_Require_Make()
  ExternalProject_Add(FFmpeg
    URL ${FFmpeg_file}
    DEPENDS ${ffmpeg_DEPENDS}
    URL_MD5 ${FFmpeg_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${FFMPEG_PATCH_COMMAND}
    CONFIGURE_COMMAND ${FFMPEG_CONFIGURE_COMMAND}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
  fletch_external_project_force_install(PACKAGE FFmpeg)
endif ()

set(FFmpeg_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# FFmpeg
#######################################
set(FFmpeg_ROOT \${fletch_ROOT})
set(fletch_ENABLED_FFmpeg TRUE)
")
