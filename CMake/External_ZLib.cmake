# The ZLib external project for fletch

ExternalProject_Add(ZLib
  URL ${ZLib_file}
  URL_MD5 ${zlib_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
     -DZLib_patch=${fletch_SOURCE_DIR}/Patches/ZLib
     -DZLib_source=${fletch_BUILD_PREFIX}/src/ZLib
     -P ${fletch_SOURCE_DIR}/Patches/ZLib/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

ExternalProject_Add_Step(ZLib fixup-install
  COMMAND ${CMAKE_COMMAND}
    -Dfletch_BUILD_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -P ${fletch_SOURCE_DIR}/Patches/ZLib/fixup-install.cmake
  DEPENDEES install
)
fletch_external_project_force_install(PACKAGE ZLib STEP_NAMES install fixup-install)

set(ZLIB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# ZLib
########################################
set(ZLIB_ROOT \${fletch_ROOT})

set(fletch_ENABLED_ZLib TRUE)
")
