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

  ExternalProject_Add(FFmpeg
    DEPENDS "FFmpeg_dev;FFmpeg_shared"
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND}
      -DFFmpeg_dev_SOURCE=${fletch_BUILD_PREFIX}/src/FFmpeg_dev
      -DFFmpeg_shared_SOURCE=${fletch_BUILD_PREFIX}/src/FFmpeg_shared
      -DFFmpeg_INSTALL=${fletch_BUILD_INSTALL_PREFIX}
      -DFFmpeg_PATCH=${fletch_SOURCE_DIR}/Patches/FFmpeg
      -P ${fletch_SOURCE_DIR}/Patches/FFmpeg/Install.cmake
  )
  fletch_external_project_force_install(PACKAGE FFmpeg)

else ()
  include(External_yasm)
  set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
  set(_FFmpeg_yasm --yasmexe=${fletch_YASM})
  list(APPEND ffmpeg_DEPENDS yasm)

  Fletch_Require_Make()
  ExternalProject_Add(FFmpeg
    URL ${FFmpeg_file}
    DEPENDS ${ffmpeg_DEPENDS}
    URL_MD5 ${FFmpeg_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
    -DFFmpeg_patch:PATH=${fletch_SOURCE_DIR}/Patches/FFmpeg
    -DFFmpeg_source:PATH=${fletch_BUILD_PREFIX}/src/FFmpeg
    -P ${fletch_SOURCE_DIR}/Patches/FFmpeg/Patch.cmake

    CONFIGURE_COMMAND ${fletch_BUILD_PREFIX}/src/FFmpeg/configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
      --enable-shared
      --disable-static
      --enable-memalign-hack
      --enable-runtime-cpudetect
      --enable-bzlib
      --enable-zlib
      --enable-outdev=sdl
      ${_FFmpeg_yasm}
      --cc=${CMAKE_C_COMPILER}
      --cxx=${CMAKE_CXX_COMPILER}
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
")
