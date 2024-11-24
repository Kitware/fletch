# If a patch file exists for this version, apply it
set (OpenCV_contrib_patch ${fletch_SOURCE_DIR}/Patches/OpenCV_contrib/${OpenCV_contrib_version})
if (EXISTS ${OpenCV_contrib_patch})
  set(OPENCV_CONTRIB_PATCH_COMMAND ${CMAKE_COMMAND}
    -DOpenCV_contrib_patch:PATH=${OpenCV_contrib_patch}
    -DOpenCV_contrib_source:PATH=${fletch_BUILD_PREFIX}/src/OpenCV_contrib
    -P ${OpenCV_contrib_patch}/Patch.cmake)
endif()


# The OpenCV contrib repo external project
ExternalProject_Add(OpenCV_contrib
  URL ${OpenCV_contrib_url}
  URL_MD5 ${OpenCV_contrib_md5}
  ${COMMON_EP_ARGS}

  # This is a support repository for OpenCV 3.x and does not contain any
  # build or install rules. This will be hooked into OpenCV which will control
  # those steps.
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  PATCH_COMMAND ${OPENCV_CONTRIB_PATCH_COMMAND}
  )

set(OpenCV_contrib_MODULE_PATH "${fletch_BUILD_PREFIX}/src/OpenCV_contrib/modules")
