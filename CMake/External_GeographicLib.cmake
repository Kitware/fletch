
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
# Explicitly copy each tool executable after install.
if(WIN32 AND CMAKE_CONFIGURATION_TYPES)
  set(_geo_tools CartConvert ConicProj GeodesicProj GeoConvert GeodSolve
                 GeoidEval Gravity MagneticField Planimeter RhumbSolve
                 TransverseMercatorProj)
  set(_geo_copy_cmds)
  foreach(_tool ${_geo_tools})
    list(APPEND _geo_copy_cmds
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${fletch_BUILD_PREFIX}/src/GeographicLib-build/bin/Release/${_tool}.exe"
        "${fletch_BUILD_INSTALL_PREFIX}/bin/${_tool}.exe")
  endforeach()
  ExternalProject_Add_Step(GeographicLib copy_tools
    ${_geo_copy_cmds}
    DEPENDEES install
    COMMENT "Copying GeographicLib tool executables to install prefix"
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
