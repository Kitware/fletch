# FFmpeg NVidia (CUDA/CUVID/NVENC) codec headers

set(ffnvcodec_build_command make)
set(ffnvcodec_install_command make install PREFIX=${fletch_BUILD_INSTALL_PREFIX})

if(WIN32)
  include(External_msys2)
  list(APPEND ffnvcodec_depends msys2)
  set(ffnvcodec_build_command ${mingw_prefix} ${mingw_bash} -c "${ffnvcodec_build_command}")
  set(ffnvcodec_install_command ${mingw_prefix} ${mingw_bash} -c "${ffnvcodec_install_command}")
endif()

ExternalProject_Add(ffnvcodec
  GIT_REPOSITORY ${ffnvcodec_url}
  GIT_TAG ${ffnvcodec_version}
  DEPENDS ${ffnvcodec_depends}
  ${COMMON_EP_ARGS}
  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE true
  BUILD_COMMAND ${ffnvcodec_build_command}
  INSTALL_COMMAND ${ffnvcodec_install_command}
  UPDATE_COMMAND ""
)

fletch_external_project_force_install(PACKAGE ffnvcodec)
