# libsvm external project
# Uses CMake wrapper patch for cross-platform builds

# Set up patch command - always applies CMakeLists.txt, optionally applies HIK patch
set(libsvm_PATCH_COMMAND ${CMAKE_COMMAND}
  -Dlibsvm_patch:PATH=${fletch_SOURCE_DIR}/Patches/libsvm
  -Dlibsvm_source:PATH=${fletch_BUILD_PREFIX}/src/libsvm
  -Dlibsvm_apply_hik_patch:BOOL=${libsvm_apply_patch}
  -P ${fletch_SOURCE_DIR}/Patches/libsvm/Patch.cmake
  )

ExternalProject_Add(libsvm
  URL ${libsvm_url}
  URL_MD5 ${libsvm_md5}
  ${COMMON_EP_ARGS}
  PATCH_COMMAND ${libsvm_PATCH_COMMAND}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
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

fletch_external_project_force_install(PACKAGE libsvm)

set(libsvm_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# libsvm
########################################
set(libsvm_ROOT \${fletch_ROOT})
set(fletch_ENABLED_libsvm TRUE)
")
