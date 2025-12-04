foreach(dep Boost Ceres Eigen GLog freeimage glew)
  if (fletch_ENABLE_${dep})
    list(APPEND colmap_DEPENDS ${dep})
  else()
    message(FATAL_ERROR "${dep} is required for colmap, please enable")
  endif()
endforeach()

if(Ceres_version VERSION_LESS 2.0.0)
  message(FATAL_ERROR "Ceres version >=2.0 is required for colmap")
endif()

ExternalProject_Add(colmap
  DEPENDS ${colmap_DEPENDS}
  URL ${colmap_file}
  URL_MD5 ${colmap_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND
    ${CMAKE_COMMAND}
    -Dcolmap_patch:PATH=${fletch_SOURCE_DIR}/Patches/colmap
    -Dcolmap_source:PATH=${fletch_BUILD_PREFIX}/src/colmap
    -P ${fletch_SOURCE_DIR}/Patches/colmap/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CUDA_ARCHITECTURES=all-major
    -DBoost_ROOT=${BOOST_ROOT}
    -DCeres_DIR=${Ceres_DIR}
    -DEigen_DIR=${Eigen_DIR}
    -DGLog_DIR=${GLog_DIR}
    -DCGAL_ENABLED=OFF
    -DTESTS_ENABLED=OFF
    -DGUI_ENABLED=OFF
)

fletch_external_project_force_install(PACKAGE colmap)

set(colmap_ROOT ${fletch_ROOT})

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# colmap
########################################
set(colmap_ROOT \${fletch_ROOT})

set(fletch_ENABLED_colmap TRUE)
")
