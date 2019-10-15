# The yasm external project for fletch.
# This external project does not follow the normal pattern for
# fletch.  It is only used by the jpeg-turbo project and only when
# NASM or YASM can't be found. So, the usual enable flags and infrastructure
# for a fletch. Instead this file is directly included
# in External_libjpegturbo.cmake.

if (NOT PYTHON_EXECUTABLE AND NOT yasm_PYTHON_EXECUTABLE)
  find_package(PythonInterp)
  if (NOT PYTHON_EXECUTABLE)
    message("libjpeg-turbo/FFmpeg require yasm which requires python but fletch_python is not enabled.\n"
      "Please set yasm_PYTHON_EXECUTABLE to your python executable to enable python for "
      "yasm only, or enable python for all of fletch")
    set(yasm_PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE} CACHE FILEPATH "")
  else()
    # Since we are only finding python for yasm, unset it from cache
    # Not doing that will effectively enable python for all of fletch
    # which is not desireable
    set(yasm_PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE})
    unset(PYTHON_EXECUTABLE CACHE)
  endif()
elseif(NOT yasm_PYTHON_EXECUTABLE)
  set(yasm_PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE})
endif()

if (NOT _external_yasm_include)
  set(_external_yasm_include TRUE)
  ExternalProject_Add(yasm
    URL ${yasm_url}
    URL_MD5 ${yasm_md5}
    ${COMMON_EP_ARGS}
    ${COMMON_CMAKE_EP_ARGS}
    INSTALL_COMMAND ""
    CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=Release
    -DPYTHON_EXECUTABLE:FILEPATH=${yasm_PYTHON_EXECUTABLE}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    )

    if (WIN32)
        set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/${CMAKE_CFG_INTDIR}/yasm.exe)
    else()
        set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
    endif()
endif()
