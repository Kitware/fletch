# libjpeg-turbo External project
include(External_yasm)
list(APPEND libjpeg-turbo_DEPENDS yasm)

ExternalProject_Add(libjpeg-turbo
  URL ${libjpeg-turbo_url}
  URL_MD5 ${libjpeg-turbo_md5}
  DEPENDS ${libjpeg-turbo_DEPENDS}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -Dlibjpeg-turbo_patch:PATH=${fletch_SOURCE_DIR}/Patches/libjpeg-turbo
    -Dlibjpeg-turbo_source:PATH=${fletch_BUILD_PREFIX}/src/libjpeg-turbo
    -P ${fletch_SOURCE_DIR}/Patches/libjpeg-turbo/Patch.cmake
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DNASM:FILEPATH=${fletch_YASM} -g vc8
  )

if (WIN32)
  ExternalProject_Add_Step(libjpeg-turbo fixup-install
    COMMAND ${CMAKE_COMMAND} -E copy
    ${fletch_BUILD_INSTALL_PREFIX}/lib/jpeg.lib
    ${fletch_BUILD_INSTALL_PREFIX}/lib/libjpeg.lib
    DEPENDEES install
    )
endif()

fletch_external_project_force_install(PACKAGE libjpeg-turbo STEP_NAMES install fixup-install)

set(libjpeg-turbo_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# libjpeg-turbo
################################
set(libjpeg-turbo_ROOT \${fletch_ROOT})
set(fletch_ENABLED_libjpeg-turbo TRUE)
")
