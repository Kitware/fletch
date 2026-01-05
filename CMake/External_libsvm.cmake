
if(WIN32)
  # Build option for windows not yet generated
  message(FATAL_ERROR "libsvm on windows not yet supported")
else()
  Fletch_Require_Make()

  # libsvm builds a shared library with "make lib"
  # The output is libsvm.so.2 on Linux
  set(LIBSVM_LIB_NAME libsvm.so.2)

  # Set up patch command for version 3.11 (HIK kernel support)
  if(libsvm_apply_patch)
    set(libsvm_PATCH_COMMAND ${CMAKE_COMMAND}
      -Dlibsvm_patch:PATH=${fletch_SOURCE_DIR}/Patches/libsvm
      -Dlibsvm_source:PATH=${fletch_BUILD_PREFIX}/src/libsvm
      -P ${fletch_SOURCE_DIR}/Patches/libsvm/Patch.cmake
      )
  else()
    set(libsvm_PATCH_COMMAND "")
  endif()

  ExternalProject_Add(libsvm
    URL ${libsvm_url}
    URL_MD5 ${libsvm_md5}
    ${COMMON_EP_ARGS}
    PATCH_COMMAND ${libsvm_PATCH_COMMAND}
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND ${MAKE_EXECUTABLE} lib
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${fletch_BUILD_INSTALL_PREFIX}/lib
            COMMAND ${CMAKE_COMMAND} -E make_directory ${fletch_BUILD_INSTALL_PREFIX}/include
            COMMAND ${CMAKE_COMMAND} -E copy ${LIBSVM_LIB_NAME} ${fletch_BUILD_INSTALL_PREFIX}/lib
            COMMAND ${CMAKE_COMMAND} -E copy svm.h ${fletch_BUILD_INSTALL_PREFIX}/include
    )

  # Install Python bindings if Python support is enabled
  if(fletch_BUILD_WITH_PYTHON)
    ExternalProject_Add_Step(libsvm install_python
      COMMAND ${CMAKE_COMMAND} -E make_directory ${fletch_PYTHON_PACKAGES_DIR}
      COMMAND ${CMAKE_COMMAND} -E copy
        ${fletch_BUILD_PREFIX}/src/libsvm/python/svm.py
        ${fletch_PYTHON_PACKAGES_DIR}
      COMMAND ${CMAKE_COMMAND} -E copy
        ${fletch_BUILD_PREFIX}/src/libsvm/python/svmutil.py
        ${fletch_PYTHON_PACKAGES_DIR}
      DEPENDEES install
      )
  endif()
endif()

fletch_external_project_force_install(PACKAGE libsvm)

set(libsvm_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libsvm
########################################
set(libsvm_ROOT \${fletch_ROOT})
set(fletch_ENABLED_libsvm TRUE)
")
