
# The GeographicLib external project for fletch
ExternalProject_Add(GeographicLib
  URL ${GeographicLib_file}
  URL_MD5 ${GeographicLib_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
     -DGeographicLib_patch=${fletch_SOURCE_DIR}/Patches/GeographicLib
     -DGeographicLib_source=${fletch_BUILD_PREFIX}/src/GeographicLib
     -P ${fletch_SOURCE_DIR}/Patches/GeographicLib/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    #GeographicLIb cannot build with standard 98 anymore. Force 11
    -DCMAKE_CXX_STANDARD:STRING=11
)

fletch_external_project_force_install(PACKAGE GeographicLib)

# On Windows with multi-config generators (Visual Studio), the install step
# may not copy tool executables from bin/Release/ to the install prefix.
# Run cmake --install with --config Release to ensure all targets are installed.
if(WIN32 AND CMAKE_CONFIGURATION_TYPES)
  ExternalProject_Add_Step(GeographicLib install_release
    COMMAND ${CMAKE_COMMAND} --install
      ${fletch_BUILD_PREFIX}/src/GeographicLib-build
      --config Release
      --prefix ${fletch_BUILD_INSTALL_PREFIX}
    DEPENDEES install
    COMMENT "Installing GeographicLib Release binaries"
  )
endif()

set(GeographicLib_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GeographicLib
########################################
set(GeographicLib_ROOT \${fletch_ROOT})

set(fletch_ENABLED_GeographicLib TRUE)
")
