
if (WIN32)

  # Build option for windows not yet generated
  message( FATAL_ERROR "LevelDB on windows not yet supported" )

else()

  add_package_dependency(
    PACKAGE LevelDB
    PACKAGE_DEPENDENCY Snappy
    PACKAGE_DEPENDENCY_ALIAS Snappy
    )
  # Default linux install process for LevelDB
  Fletch_Require_Make()

  set(LevelDB_BUILD_DIR
    ${fletch_BUILD_PREFIX}/src/LevelDB
    )

  get_system_library_name( leveldb LevelDB_SHARED_LIB )
  set(LevelDB_CUSTOM_INSTALL
    COMMAND ${CMAKE_COMMAND} -E copy "${LevelDB_BUILD_DIR}/libleveldb.a" "${fletch_BUILD_INSTALL_PREFIX}/lib"
    COMMAND ${CMAKE_COMMAND} -E copy "${LevelDB_BUILD_DIR}/${LevelDB_SHARED_LIB}" "${fletch_BUILD_INSTALL_PREFIX}/lib"
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${LevelDB_BUILD_DIR}/include/leveldb" "${fletch_BUILD_INSTALL_PREFIX}/include/leveldb"
    )

  ExternalProject_Add(LevelDB
    URL ${LevelDB_url}
    URL_MD5 ${LevelDB_md5}
    DEPENDS ${LevelDB_DEPENDS}
    PREFIX  ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSNAPPY_ROOT:PATH=${SNAPPY_ROOT}
      -DLevelDB_patch:PATH=${fletch_SOURCE_DIR}/Patches/LevelDB
      -DLevelDB_source:PATH=${fletch_BUILD_PREFIX}/src/LevelDB
      -P ${fletch_SOURCE_DIR}/Patches/LevelDB/Patch.cmake
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${LevelDB_CUSTOM_INSTALL}
    )
endif()

fletch_external_project_force_install(PACKAGE LevelDB)

set(LevelDB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# LevelDB
########################################
set(LevelDB_ROOT    \${fletch_ROOT})
")
