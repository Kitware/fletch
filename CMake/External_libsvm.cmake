ExternalProject_Add(libsvm
        DEPENDS ${_LIBSVM_DEPENDS}
        URL ${libsvm_url}
        URL_MD5 ${libsvm_md5}
        DOWNLOAD_NAME ${libsvm_dlname}
        PREFIX ${fletch_BUILD_PREFIX}
        DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
        INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
        PATCH_COMMAND ${CMAKE_COMMAND}
        -DLIBSVM_patch:PATH=${fletch_SOURCE_DIR}/Patches/libsvm
        -DLIBSVM_source:PATH=${fletch_BUILD_PREFIX}/src/libsvm
        -P ${fletch_SOURCE_DIR}/Patches/libsvm/Patch.cmake
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
        )
