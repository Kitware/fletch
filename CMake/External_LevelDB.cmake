
if (WIN32)
  # Build option for windows not yet generated
  message( FATAL_ERROR "LevelDB on windows not yet supported" )
endif()

add_package_dependency(
  PACKAGE LevelDB
  PACKAGE_DEPENDENCY Snappy
  PACKAGE_DEPENDENCY_ALIAS Snappy
  )

ExternalProject_Add(LevelDB
  URL ${LevelDB_url}
  URL_MD5 ${LevelDB_md5}
  DOWNLOAD_NAME ${LevelDB_dlname}
  DEPENDS ${LevelDB_DEPENDS}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DSNAPPY_ROOT:PATH=${SNAPPY_ROOT}
    -DLevelDB_patch:PATH=${fletch_SOURCE_DIR}/Patches/LevelDB
    -DLevelDB_source:PATH=${fletch_BUILD_PREFIX}/src/LevelDB
    -P ${fletch_SOURCE_DIR}/Patches/LevelDB/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  )

fletch_external_project_force_install(PACKAGE LevelDB)

set(LevelDB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# LevelDB
########################################
set(LevelDB_ROOT    \${fletch_ROOT})
")
