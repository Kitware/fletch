# The yasm external project for fletch.
# This external project does not follow the normal pattern for
# fletch.  It is only used by the jpeg-turbo project and only when
# NASM or YASM can't be found. So, the usual enable flags and infrastructure
# for a fletch. Instead this file is directly included
# in External_libjpegturbo.cmake.

if (NOT _external_yasm_include)
    set(_external_yasm_include TRUE)
    ExternalProject_Add(yasm
      URL ${yasm_url}
      URL_MD5 ${yasm_md5}
      PREFIX ${fletch_BUILD_PREFIX}
      DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
      CMAKE_GENERATOR ${gen}
      INSTALL_COMMAND ""
      CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DBUILD_SHARED_LIBS=OFF
    )

    if (WIN32)
        set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/${CMAKE_CFG_INTDIR}/yasm.exe)
    else()
        set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
    endif()
endif()
