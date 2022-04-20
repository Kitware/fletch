ExternalProject_Add(x265
  URL ${x265_url}
  DEPENDS ${x265_DEPENDS}
  URL_MD5 ${x265_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  SOURCE_SUBDIR source
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX=${fletch_BUILD_INSTALL_PREFIX}
  )

fletch_external_project_force_install(PACKAGE x265)

set(x265_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
