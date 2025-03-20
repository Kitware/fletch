# wxWidgets

if(Qt_version_major EQUAL 5)
  add_package_dependency(
    PACKAGE wxWidgets
    PACKAGE_DEPENDENCY Qt
    PACKAGE_DEPENDENCY_ALIAS Qt5
  )
  set(wxWidgets_ARGS
    -DwxBUILD_TOOLKIT:STRING=qt
    -DQt5_DIR:PATH=${Qt5_DIR}
    -DQTE_QT_VERSION:STRING=5
  )
endif()

# The wxWidgets external project for fletch
ExternalProject_Add(wxWidgets
  DEPENDS ${wxWidgets_DEPENDS}
  URL ${wxWidgets_file}
  URL_MD5 ${wxWidgets_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${wxWidgets_ARGS}
)

fletch_external_project_force_install(PACKAGE wxWidgets)

set(wxWidgets_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# wxWidgets
########################################
set(wxWidgets_ROOT \${fletch_ROOT})
set(wxWidgets_DIR  \${fletch_ROOT}/lib/cmake/wxWidgets)

set(fletch_ENABLED_wxWidgets TRUE)
")
