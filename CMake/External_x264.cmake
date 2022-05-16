# The x264 external project for fletch.
include(External_yasm)
list(APPEND x264_DEPENDS yasm)

if (WIN32)
  message( FATAL_ERROR "Manual x264 build not available on windows" )
else()
  Fletch_Require_Make()
  ExternalProject_Add(x264
    URL ${x264_url}
    URL_MD5 ${x264_md5}
    DEPENDS ${x264_DEPENDS}
    ${COMMON_EP_ARGS}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
      "PATH=${fletch_YASM_DIR}:$ENV{PATH}"
      ./configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
    BUILD_COMMAND ${CMAKE_COMMAND} -E env
      "PATH=${fletch_YASM_DIR}:$ENV{PATH}"
      ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E env
      "PATH=${fletch_YASM_DIR}:$ENV{PATH}"
      ${MAKE_EXECUTABLE} install
  )
  fletch_external_project_force_install(PACKAGE x264)
endif()
