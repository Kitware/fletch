set (x265_patch ${fletch_SOURCE_DIR}/Patches/x265)
if (EXISTS ${x265_patch})
  set(x265_PATCH_COMMAND ${CMAKE_COMMAND}
    -Dx265_patch:PATH=${x265_patch}
    -Dx265_source:PATH=${fletch_BUILD_PREFIX}/src/x265
    -P ${x265_patch}/Patch.cmake
    )
else()
  set(x265_PATCH_COMMAND "")
endif()

ExternalProject_Add(x265
  URL ${x265_url}
  DEPENDS ${x265_DEPENDS}
  URL_MD5 ${x265_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  SOURCE_SUBDIR source
  PATCH_COMMAND ${x265_PATCH_COMMAND}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX=${fletch_BUILD_INSTALL_PREFIX}
  )

fletch_external_project_force_install(PACKAGE x265)

set(x265_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
