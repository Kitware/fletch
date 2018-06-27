# Qt

if(Qt_version_major EQUAL 4)
  add_package_dependency(
    PACKAGE qtExtensions
    PACKAGE_DEPENDENCY Qt
    PACKAGE_DEPENDENCY_ALIAS Qt4
  )
  set(QT_ARGS
    -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
    -DQTE_QT_VERSION:STRING=4
  )
else()
  add_package_dependency(
    PACKAGE qtExtensions
    PACKAGE_DEPENDENCY Qt
    PACKAGE_DEPENDENCY_ALIAS Qt5
    PACKAGE_DEPENDENCY_COMPONENTS Widgets Xml Designer UiPlugin
  )
  set(QT_ARGS
    -DQt5_DIR:PATH=${Qt5_DIR}
    -DQTE_QT_VERSION:STRING=5
  )
endif()

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
    ${QT_ARGS}
)

fletch_external_project_force_install(PACKAGE qtExtensions)

set(qtExtensions_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# qtExtensions
########################################
set(qtExtensions_ROOT \${fletch_ROOT})
set(qtExtensions_DIR  \${fletch_ROOT}/lib/cmake/qtExtensions)

set(fletch_ENABLED_qtExtensions TRUE)
")
