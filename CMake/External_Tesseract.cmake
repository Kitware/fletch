#Find required dependencies
add_package_dependency(
 PACKAGE Tesseract
 PACKAGE_DEPENDENCY Leptonica
 PACKAGE_DEPENDENCY_ALIAS Leptonica
)

  ExternalProject_Add(Tesseract
    DEPENDS ${Tesseract_DEPENDS}
    URL ${Tesseract_url}
    URL_MD5 ${Tesseract_md5}
    DOWNLOAD_NAME ${tess_dlname}
    PREFIX  ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}

    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -DLeptonica_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}
  )

set(Tesseract_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "")
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Tesseract
########################################
set(Tesseract_ROOT    \${fletch_ROOT})
")

