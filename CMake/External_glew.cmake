if(WIN32)
  include(External_msys2)
  list(APPEND glew_DEPENDS msys2)
  set(glew_make_command ${mingw_prefix} ${msys_bash} -c "make")
else()
  set(glew_make_command "make")
endif()

ExternalProject_Add(glew
  URL ${glew_file}
  URL_MD5 ${glew_md5}
  DEPENDS ${glew_DEPENDS}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND
    ${CMAKE_COMMAND}
    -Dglew_patch:PATH=${fletch_SOURCE_DIR}/Patches/glew
    -Dglew_source:PATH=${fletch_BUILD_PREFIX}/src/glew
    -P ${fletch_SOURCE_DIR}/Patches/glew/Patch.cmake
  CONFIGURE_COMMAND
    cd <SOURCE_DIR>/auto/ && ${glew_make_command} && cd <SOURCE_DIR>/build/ && ${CMAKE_COMMAND} ./cmake ${COMMON_CMAKE_ARGS}
  BUILD_COMMAND
    cd <SOURCE_DIR>/build/ && ${CMAKE_COMMAND} --build .
  INSTALL_COMMAND
    cd <SOURCE_DIR>/build/ && ${CMAKE_COMMAND} --install .
)

set(glew_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(glew_DIR ${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/glew CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# Glew
#######################################
set(glew_ROOT \${fletch_ROOT})
set(fletch_ENABLED_glew TRUE)
")
