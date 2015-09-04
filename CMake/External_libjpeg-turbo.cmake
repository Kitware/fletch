# libjpeg-turbo External project

include(External_yasm)
list(APPEND libjpeg-turbo_DEPENDS yasm)

if(WIN32)
  ExternalProject_Add(libjpeg-turbo
    URL ${libjpeg-turbo_url}
    URL_MD5 ${libjpeg-turbo_md5}
    DEPENDS ${libjpeg-turbo_DEPENDS}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    PATCH_COMMAND ${CMAKE_COMMAND}
        -Dlibjpeg-turbo_patch:PATH=${fletch_SOURCE_DIR}/Patches/libjpeg-turbo
        -Dlibjpeg-turbo_source:PATH=${fletch_BUILD_PREFIX}/src/libjpeg-turbo
        -P ${fletch_SOURCE_DIR}/Patches/libjpeg-turbo/Patch.cmake
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DNASM:FILEPATH=${fletch_YASM} -g vc8
    )

  ExternalProject_Add_Step(libjpeg-turbo fixup-install
    COMMAND ${CMAKE_COMMAND} -E copy
      ${fletch_BUILD_INSTALL_PREFIX}/lib/jpeg.lib
      ${fletch_BUILD_INSTALL_PREFIX}/lib/libjpeg.lib
    DEPENDEES install
    )
else()
  # We need some special Apple treatment
  if(APPLE)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(_libjpeg-turbo_ARGS_APPLE --host x86_64-apple-darwin )
    endif()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      # Need to investigate/apply the following command-line options for 32-bit when required.
      # Configure commandline comes from the BUILDING.txt file in libjpeg-turbo source
      # "--host i686-apple-darwin CFLAGS='-isysroot /Developer/SDKs/MacOSX10.5.sdk
      # -mmacosx-version-min=10.5 -O3 -m32' LDFLAGS='-isysroot
      # /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -m32'")

    endif()
  endif()

  Fletch_Require_Make()
  ExternalProject_Add(libjpeg-turbo
    URL ${libjpeg-turbo_url}
    URL_MD5 ${libjpeg-turbo_md5}
    DEPENDS ${libjpeg-turbo_DEPENDS}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure
      --prefix=${fletch_BUILD_INSTALL_PREFIX}
      ${_libjpeg-turbo_ARGS_APPLE}
      NASM=${fletch_YASM}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
  )
endif()
