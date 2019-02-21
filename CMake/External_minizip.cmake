# The minizip external project for fletch

# If we're building ZLib, use that one.
if(fletch_ENABLE_ZLib)
  set(MINIZIP_DEPENDS ${MINZIP_DEPENDS} ZLib)
  set(minizip_use_external_zlib
        -DZLIB_ROOT:PATH=${ZLIB_ROOT}
	)
else()
  message(FATAL_ERROR "MINIZIP requires ZLib, please enable")
endif()

ExternalProject_Add(minizip
  DEPENDS ${MINIZIP_DEPENDS}
  URL ${minizip_file}
  URL_MD5 ${minizip_md5}
  DOWNLOAD_NAME ${minizip_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${minizip_use_external_zlib}
)

fletch_external_project_force_install(PACKAGE minizip)

set(MINIZIP_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# minizip
########################################
set(MINIZIP_ROOT \${fletch_ROOT})

set(fletch_ENABLED_minizip TRUE)
")

