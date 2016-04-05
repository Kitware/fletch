# The OpenCV contrib repo external project
ExternalProject_Add(OpenCV_contrib
  URL ${OpenCV_contrib_url}
  URL_MD5 ${OpenCV_contrib_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}

  # This is a support repository for OpenCV 3.x and does not contain any
  # build or install rules. This will be hooked into OpenCV which will control
  # those steps.
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  )

set(OpenCV_contrib_MODULE_PATH "${fletch_BUILD_PREFIX}/src/OpenCV_contrib/modules")
