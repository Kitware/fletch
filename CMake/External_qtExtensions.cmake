# Qt
add_package_dependency(
  PACKAGE qtExtensions
  PACKAGE_DEPENDENCY Qt
  PACKAGE_DEPENDENCY_ALIAS Qt4
)

# The qtExtensions external project for fletch
ExternalProject_Add(qtExtensions
  DEPENDS ${qtExtensions_DEPENDS}
  URL ${qtExtensions_file}
  URL_MD5 ${qtExtensions_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  DOWNLOAD_NAME ${qtExtensions_dlname}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
)

fletch_external_project_force_install(PACKAGE qtExtensions)

set(qtExtensions_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# qtExtensions
########################################
set(qtExtensions_ROOT \${fletch_ROOT})
set(qtExtensions_DIR  \${fletch_ROOT}/lib/cmake)

set(fletch_ENABLED_qtExtensions TRUE)
")
