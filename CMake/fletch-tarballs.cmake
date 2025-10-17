#+
# Adding a module, xxxx, to fletch is fairly straighforward.
#
# First, add a stanza to this file that defines:
#   xxx_version - the version of xxx that you'll be using
#   xxx_url - the url from which to download the associated tarball
#   xxx_md5 - the expected md5 checksum for the tarball.  cmake -E md5sum can
#   be used to obtain this.
#
#   At the end of the stanza for xxx, add xxx to the list
#   fletch_external_sources.
#
#   Then, in the CMake directory, add the file External_xxx.cmake, and write
#   the ExternalProject_add command that will download, configure and build
#   the package
#
#   At the end of the External_xxx file, you should set any values that would
#   be used by Findxxx() in order to find your build of XXX within the
#   fletch build directory.  You'll also need to add the appropriate
#   commands to the fletchConfig.cmake file (see existing
#   External_foo.cmake files for examples)
#-

# ZLib
set(ZLib_version 1.2.11)
set(ZLib_url "https://data.kitware.com/api/v1/file/6622b59fdf5a87675edbc12d/download/zlib.${ZLib_version}.zip")
set(zlib_md5 "9d6a627693163bbbf3f26403a3a0b0b1")
list(APPEND fletch_external_sources ZLib)

# CPython
if(fletch_ENABLE_CPython)
  set(CPython_SELECT_VERSION 3.10.4 CACHE STRING "Select the version of Python to build.")
  set_property(CACHE CPython_SELECT_VERSION PROPERTY STRINGS "3.6.15" "3.8.13" "3.10.4")
  set(fletch_PYTHON_MAJOR_VERSION 3 CACHE INTERNAL "Required for CPython" FORCE)

  string(REPLACE "." ";" CPython_VERSION_LIST ${CPython_SELECT_VERSION})
  list(GET CPython_VERSION_LIST 0 CPython_version_major)
  list(GET CPython_VERSION_LIST 1 CPython_version_minor)
  list(GET CPython_VERSION_LIST 2 CPython_version_patch)

  set(CPython_version ${CPython_version_major}.${CPython_version_minor})
  set(CPython_full_version ${CPython_version}.${CPython_version_patch})
  set(CPython_version_modifier )

  if(CPython_SELECT_VERSION VERSION_EQUAL 3.6.15)
    set(CPython_version_modifier m)
    set(CPython_url "https://data.kitware.com/api/v1/file/68cc68877d52b0d5b570f398/download/cpython.${CPython_full_version}.zip")
    set(CPython_md5 "325c4c92c8f0efadf1aba8d70b1f74e3")
  elseif(CPython_SELECT_VERSION VERSION_EQUAL 3.8.13)
    set(CPython_url "https://data.kitware.com/api/v1/file/68cc688a7d52b0d5b570f39b/download/cpython.${CPython_full_version}.zip")
    set(CPython_md5 "3daa024d29598baf42ee33019d4b5746")
  elseif(CPython_SELECT_VERSION VERSION_EQUAL 3.10.4)
    set(CPython_url "https://data.kitware.com/api/v1/file/68cc688c7d52b0d5b570f39e/download/cpython.${CPython_full_version}.zip")
    set(CPython_md5 "716d1a13c474c237a4044f129d9d7168")
  else()
    message(FATAL_ERROR "Unsupported CPython version")
  endif()
endif()
list(APPEND fletch_external_sources CPython)

# Boost

# Support 1.78.0 (Default) and 1.65.1 optionally
if (fletch_ENABLE_Boost OR fletch_ENABLE_ALL_PACKAGES)
  set(Boost_SELECT_VERSION 1.78.0 CACHE STRING "Select the major version of Boost to build.")
  set_property(CACHE Boost_SELECT_VERSION PROPERTY STRINGS "1.78.0" "1.65.1")
  string(REGEX REPLACE "\\\." "_" Boost_version_underscore ${Boost_SELECT_VERSION})
  message(STATUS "Boost Select version: ${Boost_SELECT_VERSION}")

  if(Boost_SELECT_VERSION VERSION_EQUAL 1.65.1)
    set(Boost_url "https://data.kitware.com/api/v1/file/6622b045df5a87675edbc03d/download/boost.${Boost_SELECT_VERSION}.tar.bz2")
    set(Boost_md5 "41d7542ce40e171f3f7982aff008ff0d")
  elseif(Boost_SELECT_VERSION VERSION_EQUAL 1.78.0)
    set(Boost_url "https://data.kitware.com/api/v1/file/6622b07adf5a87675edbc040/download/boost.${Boost_SELECT_VERSION}.tar.gz")
    set(Boost_md5 "c2f6428ac52b0e5a3c9b2e1d8cc832b5")
  else()
    message(STATUS "Boost_SELECT_VERSION: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources Boost)

# libjpeg-turbo
set(libjpeg-turbo_version "1.4.0")
set(libjpeg-turbo_url "https://data.kitware.com/api/v1/file/6622b0c6df5a87675edbc08b/download/libjpeg-turbo.${libjpeg-turbo_version}.tar.gz")
set(libjpeg-turbo_md5 "039153dabe61e1ac8d9323b5522b56b0")
list(APPEND fletch_external_sources libjpeg-turbo)

# libtiff
set(libtiff_version "4.1.0")
set(libtiff_url "https://data.kitware.com/api/v1/file/6622b0d0df5a87675edbc09a/download/libtiff.${libtiff_version}.tar.gz")
set(libtiff_md5 "2165e7aba557463acc0664e71a3ed424")
list(APPEND fletch_external_sources libtiff)

# PNG
set(PNG_version_major 1)
set(PNG_version_minor 6)
set(PNG_version_patch 19)
set(PNG_version "${PNG_version_major}.${PNG_version_minor}.${PNG_version_patch}")
set(PNG_major_minor_no_dot "${PNG_version_major}${PNG_version_minor}")
set(PNG_version_no_dot "${PNG_major_minor_no_dot}${PNG_version_patch}")
if(WIN32)
  set(PNG_url "https://data.kitware.com/api/v1/file/6622b0cedf5a87675edbc097/download/libpng.${PNG_version}.zip")
  set(PNG_md5 "ff0e82b4d8516daa7ed6b1bf93acca48")
else()
  set(PNG_url "https://data.kitware.com/api/v1/file/6622b0ccdf5a87675edbc094/download/libpng.${PNG_version}.tar.gz")
  set(PNG_md5 "3121bdc77c365a87e054b9f859f421fe")
endif()
list(APPEND fletch_external_sources PNG)

# openjpeg
set(openjpeg_version "2.3.0")
set(openjpeg_url "https://data.kitware.com/api/v1/file/6622b230df5a87675edbc0cd/download/openjpeg.${openjpeg_version}.tar.gz")
set(openjpeg_md5 "6a1f8aaa1fe55d2088e3a9c942e0f698")
list(APPEND fletch_external_sources openjpeg)

# YASM for building jpeg-turbo, not third party library
set(yasm_version "1.3.0")
set(yasm_url "https://data.kitware.com/api/v1/file/6622b59ddf5a87675edbc127/download/yasm.${yasm_version}.tar.gz")
set(yasm_md5 "38802696efbc27554d75d93a84a23183")

# msys2
if(WIN32)
  set(msys2_version "20220128")
  set(msys2_url "https://data.kitware.com/api/v1/file/6622b0ecdf5a87675edbc0a6/download/msys2.${msys2_version}.tar.xz")
  set(msys2_md5 "45b3be3d1e30d01e0d95d5bd8e75244a")
endif()

# x264
set(x264_version "bfc87b7a330f75f5c9a21e56081e4b20344f139e")
set(x264_url "https://data.kitware.com/api/v1/file/6622b59bdf5a87675edbc11e/download/x264.${x264_version}.tar.bz2")
set(x264_md5 "fd71fead6422ccb5094207c9d2ad70bd")

# x265
set(x265_version "3.4")
set(x265_url "https://data.kitware.com/api/v1/file/6622b59cdf5a87675edbc121/download/x265.${x265_version}.tar.gz")
set(x265_md5 "d867c3a7e19852974cf402c6f6aeaaf3")

# FFmpeg NVidia codec headers
set(ffnvcodec_version "n11.1.5.1")
set(ffnvcodec_url "https://git.videolan.org/git/ffmpeg/nv-codec-headers.git")

# FFmpeg
if (fletch_ENABLE_FFmpeg OR fletch_ENABLE_ALL_PACKAGES)
  # allow different versions to be selected for testing purposes
  set(FFmpeg_SELECT_VERSION 5.1.2 CACHE STRING "Select the version of FFmpeg to build.")
  set_property(CACHE FFmpeg_SELECT_VERSION PROPERTY STRINGS "2.6.2" "3.3.3" "4.4.1" "5.1.2")
  mark_as_advanced(FFmpeg_SELECT_VERSION)

  set(_FFmpeg_version ${FFmpeg_SELECT_VERSION})

  if (_FFmpeg_version VERSION_EQUAL 5.1.2)
    set(FFmpeg_url "https://data.kitware.com/api/v1/file/6622b098df5a87675edbc05e/download/ffmpeg.${_FFmpeg_version}.tar.gz")
    set(FFmpeg_md5 "f44232183ae1ef814eac50dd382a2d7f")
  elseif (_FFmpeg_version VERSION_EQUAL 4.4.1)
    set(FFmpeg_url "https://data.kitware.com/api/v1/file/6622b091df5a87675edbc05b/download/ffmpeg.${_FFmpeg_version}.tar.gz")
    set(FFmpeg_md5 "493da4b6a946b569fc65775ecde404ea")
  elseif (_FFmpeg_version VERSION_EQUAL 3.3.3)
    set(FFmpeg_url "https://data.kitware.com/api/v1/file/6622b08adf5a87675edbc058/download/ffmpeg.${_FFmpeg_version}.tar.gz")
    set(FFmpeg_md5 "f32df06c16bdc32579b7fcecd56e03df")
  elseif (_FFmpeg_version VERSION_EQUAL 2.6.2)
    set(FFmpeg_url "https://data.kitware.com/api/v1/file/6622b085df5a87675edbc055/download/ffmpeg.${_FFmpeg_version}.tar.gz")
    set(FFmpeg_md5 "412166ef045b2f84f23e4bf38575be20")
  elseif (_FFmpeg_supported AND _FFmpeg_version)
    message("Unsupported FFmpeg version ${_FFmpeg_version}")
  endif()

  set(fletch_ENABLE_x264 ON CACHE BOOL "Include x264")
  set(fletch_ENABLE_x265 ON CACHE BOOL "Include x265")
  set(fletch_ENABLE_ffnvcodec ON CACHE BOOL "Include FFmpeg NVidia codec headers")
endif()
list(APPEND fletch_external_sources FFmpeg)

# EIGEN
set(Eigen_SELECT_VERSION 3.3.9 CACHE STRING "Select the version of Eigen to build.")
set_property(CACHE Eigen_SELECT_VERSION PROPERTY STRINGS "3.3.9" "3.4.0")
mark_as_advanced(Eigen_SELECT_VERSION)

set(_Eigen_version ${Eigen_SELECT_VERSION})
if(_Eigen_version VERSION_EQUAL 3.3.9)
  set(Eigen_url "https://data.kitware.com/api/v1/file/6622b080df5a87675edbc04f/download/eigen.${_Eigen_version}.tar.gz")
  set(Eigen_md5 "609286804b0f79be622ccf7f9ff2b660")
elseif(_Eigen_version VERSION_EQUAL 3.4.0)
  set(Eigen_url "https://data.kitware.com/api/v1/file/6622b081df5a87675edbc052/download/eigen.${_Eigen_version}.tar.gz")
  set(Eigen_md5 "4c527a9171d71a72a9d4186e65bea559")
elseif (_Eigen_supported AND _Eigen_version)
  message("Unsupported Eigen version ${_Eigen_version}")
endif()
list(APPEND fletch_external_sources Eigen)

# log4cplus
set(log4cplus_version "2.0.4")
set(log4cplus_url "https://data.kitware.com/api/v1/file/6622b0d4df5a87675edbc0a3/download/log4cplus.${log4cplus_version}.zip")
set(log4cplus_md5 "cb075cd19ce561273b1c74907cc66b6a")
list(APPEND fletch_external_sources log4cplus)

# GFlags
set(GFlags_version "2.2.1")
set(GFlags_url "https://data.kitware.com/api/v1/file/6622b0acdf5a87675edbc070/download/gflags.${GFlags_version}.tar.gz")
set(GFlags_md5 "b98e772b4490c84fc5a87681973f75d1")
list(APPEND fletch_external_sources GFlags)

# GLog
set(GLog_version "0.3.5")
set(GLog_url "https://data.kitware.com/api/v1/file/6622b0acdf5a87675edbc073/download/glog.${GLog_version}.tar.gz")
set(GLog_md5 "5df6d78b81e51b90ac0ecd7ed932b0d4")
list(APPEND fletch_external_sources GLog)

set(GTest_version "1.8.1")
set(GTest_url "https://data.kitware.com/api/v1/file/6622b0addf5a87675edbc076/download/gtest.${GTest_version}.tar.gz")
set(GTest_md5 "2e6fbeb6a91310a16efe181886c59596")
list(APPEND fletch_external_sources GTest)

#OpenBLAS
if(NOT WIN32)
  set(OpenBLAS_SELECT_VERSION 0.3.21 CACHE STRING "Select the version of OpenBLAS to build.")
  set_property(CACHE OpenBLAS_SELECT_VERSION PROPERTY STRINGS "0.3.21" "0.3.10" "0.3.6")

  set (OpenBLAS_version ${OpenBLAS_SELECT_VERSION})
  if (OpenBLAS_version VERSION_EQUAL 0.3.6)
    set(OpenBLAS_url "https://data.kitware.com/api/v1/file/6622b0f3df5a87675edbc0a9/download/openblas.${OpenBLAS_version}.tar.gz")
    set(OpenBLAS_md5 "8a110a25b819a4b94e8a9580702b6495")
  elseif (OpenBLAS_version VERSION_EQUAL 0.3.10)
    set(OpenBLAS_url "https://data.kitware.com/api/v1/file/6622b0f8df5a87675edbc0ac/download/openblas.${OpenBLAS_version}.tar.gz")
    set(OpenBLAS_md5 "4727a1333a380b67c8d7c7787a3d9c9a")
  elseif (OpenBLAS_version VERSION_EQUAL 0.3.21)
    set(OpenBLAS_url "https://data.kitware.com/api/v1/file/6622b101df5a87675edbc0af/download/openblas.${OpenBLAS_version}.tar.gz")
    set(OpenBLAS_md5 "ffb6120e2309a2280471716301824805")
  else()
    message("Unknown OpenBLAS version = ${OpenBLAS_version}")
  endif()
  list(APPEND fletch_external_sources OpenBLAS)
endif()

#SuiteSparse
set(SuiteSparse_version 4.4.5)
set(SuiteSparse_url "https://data.kitware.com/api/v1/file/6622b53fdf5a87675edbc106/download/suitesparse.${SuiteSparse_version}.tar.gz")
set(SuiteSparse_md5 "a2926c27f8a5285e4a10265cc68bbc18")
list(APPEND fletch_external_sources SuiteSparse)

# Ceres Solver
set(Ceres_version 1.14.0)
set(Ceres_url "https://data.kitware.com/api/v1/file/6622b07ddf5a87675edbc043/download/ceres.${Ceres_version}.tar.gz")
set(Ceres_md5 "fd9b4eba8850f0f2ede416cd821aafa5")
list(APPEND fletch_external_sources Ceres)

if(NOT WIN32)
  set(libxml2_release "2.9")
  set(libxml2_patch_version 0)
  set(libxml2_url "https://data.kitware.com/api/v1/file/6622b0d3df5a87675edbc09d/download/libxml2.${libxml2_release}.tar.gz")
  set(libxml2_md5 "5b9bebf4f5d2200ae2c4efe8fa6103f7")
  list(APPEND fletch_external_sources libxml2)
endif()

# jom
if(WIN32)
  # this is only used by the Qt external project to speed builds
  set(jom_version 1_0_16)
  set(jom_url "https://data.kitware.com/api/v1/file/6622b0c4df5a87675edbc082/download/jom.${jom_version}.zip")
  set(jom_md5 "a021066aefcea8999b382b1c7c12165e")
endif()

# libjson
set(libjson_version_major 7)
set(libjson_version_minor 6)
set(libjson_version_patch 1)
set(libjson_version "${libjson_version_major}.${libjson_version_minor}.${libjson_version_patch}")
set(libjson_url "https://data.kitware.com/api/v1/file/6622b0c7df5a87675edbc08e/download/libjson.${libjson_version}.zip")
set(libjson_md5 "82f3fcbf9f8cf3c4e25e1bdd77d65164")
list(APPEND fletch_external_sources libjson)

# shapelib
set(shapelib_version 1.4.1)
set(shapelib_url "https://data.kitware.com/api/v1/file/6622b532df5a87675edbc0fd/download/shapelib.${shapelib_version}.tar.gz")
set(shapelib_md5 "ae9f1fcd2adda35b74ac4da8674a3178")
list(APPEND fletch_external_sources shapelib)

# TinyXML_1
set(TinyXML1_version_major "2")
set(TinyXML1_version_minor "6")
set(TinyXML1_version_patch "2")
set(TinyXML1_version "${TinyXML1_version_major}.${TinyXML1_version_minor}.${TinyXML1_version_patch}")
set(TinyXML1_url "https://data.kitware.com/api/v1/file/6622b540df5a87675edbc109/download/tinyxml1.${TinyXML1_version}.zip")
set(TinyXML1_md5 "2a0aaf609c9e670ec9748cd01ed52dae")
list(APPEND fletch_external_sources TinyXML1)

# TinyXML_2
set(TinyXML2_version_major "7")
set(TinyXML2_version_minor "0")
set(TinyXML2_version_patch "1")
set(TinyXML2_version "${TinyXML2_version_major}.${TinyXML2_version_minor}.${TinyXML2_version_patch}")
set(TinyXML2_url "https://data.kitware.com/api/v1/file/6622b540df5a87675edbc10c/download/tinyxml2.${TinyXML2_version}.zip")
set(TinyXML2_md5 "03ad292c4b6454702c0cc22de0d196ad")
list(APPEND fletch_external_sources TinyXML2)

# libkml
set(libkml_version "20150911git79b3eb0")
set(libkml_tag "79b3eb066eacd8fb117b10dc990b53b4cd11f33d")
set(libkml_url "https://data.kitware.com/api/v1/file/6622b0cbdf5a87675edbc091/download/libkml.${libkml_version}.zip")
set(libkml_md5 "a232dfd4eb07489768b207d88b983267")
list(APPEND fletch_external_sources libkml)

# Qt
# Support 4.8.6 and 5.11 optionally
if (fletch_ENABLE_Qt OR fletch_ENABLE_VTK OR fletch_ENABLE_qtExtensions OR
    fletch_ENABLE_ALL_PACKAGES)
  set(Qt_SELECT_VERSION 5.12.8 CACHE STRING "Select the version of Qt to build.")
  set_property(CACHE Qt_SELECT_VERSION PROPERTY STRINGS "5.11.2" "5.12.8" "5.15.12")

  set(Qt_version ${Qt_SELECT_VERSION})
  string(REPLACE "." ";" Qt_VERSION_LIST ${Qt_version})
  list(GET Qt_VERSION_LIST 0 Qt_version_major)
  list(GET Qt_VERSION_LIST 1 Qt_version_minor)
  list(GET Qt_VERSION_LIST 2 Qt_version_patch)

  if (Qt_version VERSION_EQUAL 5.11.2)
    set(Qt_url "https://data.kitware.com/api/v1/file/6622b353df5a87675edbc0f1/download/qt.${Qt_version}.tar.xz")
    set(Qt_md5 "152a8ade9c11fe33ff5bc95310a1bb64")
  elseif (Qt_version VERSION_EQUAL 5.12.8)
    set(Qt_url "https://data.kitware.com/api/v1/file/6622b425df5a87675edbc0f4/download/qt.${Qt_version}.tar.xz")
    set(Qt_md5 "8ec2a0458f3b8e9c995b03df05e006e4")
  elseif (Qt_version VERSION_EQUAL 5.15.12)
    set(Qt_url "https://data.kitware.com/api/v1/file/6622b532df5a87675edbc0fa/download/qt.${Qt_version}.tar.xz")
    set(Qt_md5 "3fb1cd4f763f5d50d491508b7b99fb77")
  else()
    message(ERROR "Qt Version \"${Qt_version}\" Not Supported")
  endif()
endif()
list(APPEND fletch_external_sources Qt)

# OpenCV
# Support 3.4, 4.2, 4.5.1, 4.7, 4.9 optionally
if (fletch_ENABLE_OpenCV OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
  set(OpenCV_SELECT_VERSION 4.9.0 CACHE STRING "Select the  version of OpenCV to build.")
  set_property(CACHE OpenCV_SELECT_VERSION PROPERTY STRINGS "3.4.0" "4.2.0" "4.5.1" "4.7.0" "4.9.0")

  set(OpenCV_version ${OpenCV_SELECT_VERSION})

  # Optional contrib repo available for OpenCV version >= 3.x
  list(APPEND fletch_external_sources OpenCV_contrib)
  set(OpenCV_contrib_version "${OpenCV_version}")

  # Paired contrib repo information
  if (OpenCV_version VERSION_EQUAL 4.9.0)
    set(OpenCV_url "https://data.kitware.com/api/v1/file/6622b22fdf5a87675edbc0ca/download/opencv.${OpenCV_version}.zip")
    set(OpenCV_md5 "872cf2ded2c5e79cb5904563c0b35bf4")
    set(OpenCV_contrib_url "https://data.kitware.com/api/v1/file/6622b161df5a87675edbc0bb/download/opencv-contrib.${OpenCV_version}.zip")
    set(OpenCV_contrib_md5 "e103e5c766c794f8c58435feca7e14d2")
  elseif (OpenCV_version VERSION_EQUAL 4.7.0)
    set(OpenCV_url "https://data.kitware.com/api/v1/file/664cd3cf85908871f9b3adb4/download/opencv.${OpenCV_version}.zip")
    set(OpenCV_md5 "481a9ee5b0761978832d02d8861b8156")
    set(OpenCV_contrib_url "https://data.kitware.com/api/v1/file/664cd3e985908871f9b3adb7/download/opencv-contrib.${OpenCV_version}.zip")
    set(OpenCV_contrib_md5 "a3969f1db6732340e492c0323178f6f1")
  elseif (OpenCV_version VERSION_EQUAL 4.5.1)
    if (fletch_USE_PYPI_OPENCV)
      set(OpenCV_url "https://data.kitware.com/api/v1/file/6622b1d4df5a87675edbc0c4/download/opencv.${OpenCV_version}.tar.gz")
      set(OpenCV_md5 "0e178bd601b25a0a1ee0cd1e8c81bec0")
    else()
      set(OpenCV_url "https://data.kitware.com/api/v1/file/6622b1fcdf5a87675edbc0c7/download/opencv.${OpenCV_version}.zip")
      set(OpenCV_md5 "cc13d83c3bf989b0487bb3798375ee08")
    endif()
    set(OpenCV_contrib_url "https://data.kitware.com/api/v1/file/6622b149df5a87675edbc0b8/download/opencv-contrib.${OpenCV_version}.zip")
    set(OpenCV_contrib_md5 "ddb4f64d6cf31d589a8104655d39c99b")
  elseif (OpenCV_version VERSION_EQUAL 4.2.0)
    set(OpenCV_url "https://data.kitware.com/api/v1/file/6622b1afdf5a87675edbc0c1/download/opencv.${OpenCV_version}.zip")
    set(OpenCV_md5 "b02b54115f1f99cb9e885d1e5988ff70")
    set(OpenCV_contrib_url "https://data.kitware.com/api/v1/file/6622b130df5a87675edbc0b5/download/opencv-contrib.${OpenCV_version}.zip")
    set(OpenCV_contrib_md5 "4776354662667c85a91bcd19f6a13da7")
  elseif (OpenCV_version VERSION_EQUAL 3.4.0)
    set(OpenCV_url "https://data.kitware.com/api/v1/file/6622b184df5a87675edbc0be/download/opencv.${OpenCV_version}.zip")
    set(OpenCV_md5 "ed60f8bbe7a448f325d0a0f58fcf2063")
    set(OpenCV_contrib_url "https://data.kitware.com/api/v1/file/6622b119df5a87675edbc0b2/download/opencv-contrib.${OpenCV_version}.zip")
    set(OpenCV_contrib_md5 "92c09ce6c837329f05802a8d17136148")
  else()
    message(ERROR " OpenCV Version \"${OpenCV_version}\" Not Supported")
  endif()
else()
  # Remove Contrib repo option when OpenCV is not enabled
  unset(fletch_ENABLE_OpenCV_contrib CACHE)
endif()
list(APPEND fletch_external_sources OpenCV)

# SQLite3
if (fletch_ENABLE_SQLite3 OR fletch_ENABLE_ALL_PACKAGES)
  set(SQLite3_SELECT_VERSION 3.35.2 CACHE STRING "Select the major version of SQLite3 to build.")
  set_property(CACHE SQLite3_SELECT_VERSION PROPERTY STRINGS "3.45.3" "3.35.2")
  message(STATUS "SQLite3 Select version: ${SQLite3_SELECT_VERSION}")
  if (SQLite3_SELECT_VERSION VERSION_EQUAL 3.45.3)
    set(SQLite3_version 3450300)
    set(SQLite3_url "https://data.kitware.com/api/v1/file/684ca5886adfd2ac0d0bf874/download/sqlite3.${SQLite3_version}.zip")
    set(SQLite3_md5 "a285b1e2c1f4b09593d972353212b312")
  elseif (SQLite3_SELECT_VERSION VERSION_EQUAL 3.35.2)
    set(SQLite3_version 3350200)
    set(SQLite3_url "https://data.kitware.com/api/v1/file/6622b534df5a87675edbc103/download/sqlite3.${SQLite3_version}.zip")
    set(SQLite3_md5 "732c5d0758a2a2fb9e5b9d6224141a01")
  else()
    message(STATUS "SQLite3_SELECT_VERSION ${SQLite3_SELECT_VERSION}: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources SQLite3)

# PROJ
if (fletch_ENABLE_PROJ4)
  message(WARNING "The package name PROJ4 is deprecated. Use PROJ instead.")
  set(fletch_ENABLE_PROJ ON)
endif()
if (fletch_ENABLE_PROJ OR fletch_ENABLE_ALL_PACKAGES)
  set(PROJ_SELECT_VERSION 6.3.2 CACHE STRING "Select the major version of PROJ to build.")
  set_property(CACHE PROJ_SELECT_VERSION PROPERTY STRINGS "9.6.2" "6.3.2")
  message(STATUS "PROJ Select version: ${PROJ_SELECT_VERSION}")
  if (PROJ_SELECT_VERSION VERSION_EQUAL 9.6.2)
    set(PROJ_version "9.6.2")
    set(PROJ_url "https://data.kitware.com/api/v1/file/684c6c3e6adfd2ac0d0bf866/download/proj.${PROJ_SELECT_VERSION}.tar.gz")
    set(PROJ_md5 "1241c7115d8c380ea19469ba0828a22a")
  elseif (PROJ_SELECT_VERSION VERSION_EQUAL 6.3.2)
    set(PROJ_version "6.3.2")
    set(PROJ_url "https://data.kitware.com/api/v1/file/6622b26cdf5a87675edbc0dc/download/proj.${PROJ_SELECT_VERSION}.tar.gz" )
    set(PROJ_md5 "2ca6366e12cd9d34d73b4602049ee480" )
  else()
    message(STATUS "PROJ_SELECT_VERSION ${PROJ_SELECT_VERSION}: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources PROJ )

# libgeotiff
set(libgeotiff_version "1.6.0")
set(libgeotiff_url "https://data.kitware.com/api/v1/file/6622b0c5df5a87675edbc088/download/libgeotiff.${libgeotiff_version}.zip")
set(libgeotiff_md5 "c72c682c5972a5cf8c3f655567761a17")
list(APPEND fletch_external_sources libgeotiff)

# GEOS
set(GEOS_version "3.6.2" )
set(GEOS_url "https://data.kitware.com/api/v1/file/6622b0abdf5a87675edbc06d/download/geos.${GEOS_version}.tar.bz2" )
set(GEOS_md5 "a32142343c93d3bf151f73db3baa651f" )
list(APPEND fletch_external_sources GEOS )

# GDAL
if (fletch_ENABLE_GDAL OR fletch_ENABLE_ALL_PACKAGES)
  set(GDAL_SELECT_VERSION 2.4.4 CACHE STRING "Select the major version of GDAL to build.")
  set_property(CACHE GDAL_SELECT_VERSION PROPERTY STRINGS "3.11.0" "2.4.4" "2.3.2" "1.11.5")
  message(STATUS "GDAL Select version: ${GDAL_SELECT_VERSION}")
  if (GDAL_SELECT_VERSION VERSION_EQUAL 3.11.0)
    set(GDAL_version "3.11.0")
    set(GDAL_url "https://data.kitware.com/api/v1/file/684c77056adfd2ac0d0bf86c/download/gdal.${GDAL_version}.tar.gz")
    set(GDAL_md5 "dbc8e9395b8859fed3baf08e7d8e9ed3")
  elseif (GDAL_SELECT_VERSION VERSION_EQUAL 2.4.4)
    set(GDAL_version "2.4.4")
    set(GDAL_url "https://data.kitware.com/api/v1/file/6622b0a9df5a87675edbc067/download/gdal.${GDAL_version}.tar.gz")
    set(GDAL_md5 "dc676d06eda38fb1006dcf5490128a1d")
  elseif (GDAL_SELECT_VERSION VERSION_EQUAL 2.3.2)
    set(GDAL_version "2.3.2")
    set(GDAL_url "https://data.kitware.com/api/v1/file/6622b0a3df5a87675edbc064/download/gdal.${GDAL_version}.tar.gz")
    set(GDAL_md5 "221e4bfe3e8e9443fd33f8fe46f8bf60")
  elseif(GDAL_SELECT_VERSION VERSION_EQUAL 1.11.5)
    set(GDAL_version "1.11.5")
    set(GDAL_url "https://data.kitware.com/api/v1/file/6622b09ddf5a87675edbc061/download/gdal.${GDAL_version}.tar.gz")
    set(GDAL_md5 "879fa140f093a2125f71e38502bdf714")
  else()
    message(STATUS "GDAL_SELECT_VERSION ${GDAL_SELECT_VERSION}: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources GDAL)

# PDAL
if (fletch_ENABLE_PDAL OR fletch_ENABLE_ALL_PACKAGES)
  set(PDAL_SELECT_VERSION 1.7.2 CACHE STRING "Select the major version of PDAL to build.")
  set_property(CACHE PDAL_SELECT_VERSION PROPERTY STRINGS "2.9.2" "1.7.2")
  message(STATUS "PDAL Select version: ${PDAL_SELECT_VERSION}")
  if (PDAL_SELECT_VERSION VERSION_EQUAL 2.9.2)
    set(PDAL_version "2.9.2")
    set(PDAL_url "https://data.kitware.com/api/v1/file/68d46bccaf4f192121e8168d/download/pdal.${PDAL_version}.tar.gz")
    set(PDAL_md5 "f01e30e3e6aeb441488de11df93dee2c")
  elseif (PDAL_SELECT_VERSION VERSION_EQUAL 1.7.2)
    set(PDAL_version "1.7.2")
    set(PDAL_url "https://data.kitware.com/api/v1/file/6622b24edf5a87675edbc0d0/download/pdal.${PDAL_version}.tar.gz")
    set(PDAL_md5 "a89710005fd54e6d2436955e2e542838")
  endif()
endif()
list(APPEND fletch_external_sources PDAL)

# GeographicLib
set(GeographicLib_version "1.49" )
set(GeographicLib_url "https://data.kitware.com/api/v1/file/6622b0aadf5a87675edbc06a/download/geographiclib.${GeographicLib_version}.tar.gz" )
set(GeographicLib_md5 "11300e88b4a38692b6a8712d5eafd4d7" )
list(APPEND fletch_external_sources GeographicLib )

# PostgreSQL
if (fletch_ENABLE_PostgreSQL OR fletch_ENABLE_ALL_PACKAGES)
  set(PostgreSQL_SELECT_VERSION 9.5.1 CACHE STRING "Select the major version of PostgreSQL to build.")
  set_property(CACHE PostgreSQL_SELECT_VERSION PROPERTY STRINGS "9.5.1" "10.2")
  message(STATUS "PostgreSQL Select version: ${PostgreSQL_SELECT_VERSION}")

  if (PostgreSQL_SELECT_VERSION VERSION_EQUAL 9.5.1)
    # PostgreSQL 9.5
    set(PostgreSQL_version ${PostgreSQL_SELECT_VERSION})
    set(PostgreSQL_url "https://data.kitware.com/api/v1/file/6622b260df5a87675edbc0d6/download/postgresql.${PostgreSQL_version}.tar.bz2")
    set(PostgreSQL_md5 "11e037afaa4bd0c90bb3c3d955e2b401")
  elseif(PostgreSQL_SELECT_VERSION VERSION_EQUAL 10.2)
    # PostgreSQL 9.4
    set(PostgreSQL_version ${PostgreSQL_SELECT_VERSION})
    set(PostgreSQL_url "https://data.kitware.com/api/v1/file/6622b26adf5a87675edbc0d9/download/postgresql.${PostgreSQL_version}.tar.bz2")
    set(PostgreSQL_md5 "e97c3cc72bdf661441f29069299b260a")
  else()
    message(STATUS "PostgreSQL_SELECT_VERSION: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources PostgreSQL)

# PostGIS
# Currently it seems the this version of PostGIS will work with all provided PostgreSQL versions
if(NOT WIN32)
  set(PostGIS_version "2.5.3" )
  set(PostGIS_url "https://data.kitware.com/api/v1/file/6622b255df5a87675edbc0d3/download/postgis.${PostGIS_version}.tar.gz" )
  set(PostGIS_md5 "475bca6249ee11f675b899de14fd3f42" )
  list(APPEND fletch_external_sources PostGIS )
endif()

# CPPDB
set(CppDB_version "0.3.0" )
set(CppDB_url "https://data.kitware.com/api/v1/file/6622b07ddf5a87675edbc046/download/cppdb.${CppDB_version}.tar.bz2" )
set(CppDB_md5 "091d1959e70d82d62a04118827732dfe")
list(APPEND fletch_external_sources CppDB)

# VTK
if (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  set(VTK_SELECT_VERSION 9.1 CACHE STRING "Select the version of VTK to build.")
  set_property(CACHE VTK_SELECT_VERSION PROPERTY STRINGS 8.0 8.2 9.0 9.1)
endif()

if (VTK_SELECT_VERSION VERSION_EQUAL 9.1)
  set(VTK_version 9.1.0)
  set(VTK_url "https://data.kitware.com/api/v1/file/6622b582df5a87675edbc118/download/vtk.${VTK_version}.tar.gz")
  set(VTK_md5 "96508e51d7c3764cd5aba06fffd9864e")
elseif (VTK_SELECT_VERSION VERSION_EQUAL 9.0)
  set(VTK_version 9.0.1)
  set(VTK_url "https://data.kitware.com/api/v1/file/6622b56ddf5a87675edbc115/download/vtk.${VTK_version}.tar.gz")
  set(VTK_md5 "b3ba14d616c3b23583c42cffb585deac")
elseif (VTK_SELECT_VERSION VERSION_EQUAL 8.2)
  set(VTK_version 8.2.0)
  set(VTK_url "https://data.kitware.com/api/v1/file/6622b55ddf5a87675edbc112/download/vtk.${VTK_version}.tar.gz")
  set(VTK_md5 "8af3307da0fc2ef8cafe4a312b821111")
elseif (VTK_SELECT_VERSION VERSION_EQUAL 8.0)
  set(VTK_version 8.0.1)
  set(VTK_url "https://data.kitware.com/api/v1/file/6622b54bdf5a87675edbc10f/download/vtk.${VTK_version}.tar.gz")
  set(VTK_md5 "692d09ae8fadc97b59d35cab429b261a")  # v8.0.1
elseif (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  message(ERROR "VTK Version ${VTK_SELECT_VERSION} Not Supported")
endif()
list(APPEND fletch_external_sources VTK)

# VXL
set(VXL_version "0bb0ca92867408caec298cef05412ed85c6d56b7")
set(VXL_url "https://data.kitware.com/api/v1/file/6622b59adf5a87675edbc11b/download/vxl.${VXL_version}.zip")
set(VXL_md5 "287536149942081666a2f9a3be87a666")
list(APPEND fletch_external_sources VXL)

# ITK
set(ITK_version 5.0)
set(ITK_minor b01)
set(ITK_url "https://data.kitware.com/api/v1/file/6622b0c4df5a87675edbc07f/download/itk.${ITK_version}.zip")
set(ITK_md5 "3a93ba69d3bf05258054806fab742611")
set(ITK_experimental TRUE)
list(APPEND fletch_external_sources ITK)

# LMDB
if(NOT WIN32)
  set(LMDB_version "0.9.16")
  set(LMDB_url "https://data.kitware.com/api/v1/file/6622b0d3df5a87675edbc0a0/download/lmdb.${LMDB_version}.tar.gz")
  set(LMDB_md5 "0de89730b8f3f5711c2b3a4ba517b648")
  list(APPEND fletch_external_sources LMDB)
endif()

# HDF5
if (fletch_ENABLE_HDF5 OR fletch_ENABLE_ALL_PACKAGES)
  set(HDF5_SELECT_VERSION 1.12.0 CACHE STRING "Select the major version of HDF5 to build.")
  set_property(CACHE HDF5_SELECT_VERSION PROPERTY STRINGS "1.12.0" "1.8.17")
  if (HDF5_SELECT_VERSION VERSION_EQUAL 1.12.0)
    set(HDF5_major "1")
    set(HDF5_minor "12")
    set(HDF5_rev "0")
    set(HDF5_version_string "${HDF5_major}_${HDF5_minor}_${HDF5_rev}")
    set(HDF5_url "https://data.kitware.com/api/v1/file/6622b0b8df5a87675edbc07c/download/hdf5.${HDF5_SELECT_VERSION}.tar.gz")
    set(HDF5_md5 "7181d12d1940b725248046077a849f54")
  elseif(HDF5_SELECT_VERSION VERSION_EQUAL 1.8.17)
    set(HDF5_major "1")
    set(HDF5_minor "8")
    set(HDF5_rev "17")
    set(HDF5_version_string "${HDF5_major}_${HDF5_minor}_${HDF5_rev}")
    set(HDF5_url "https://data.kitware.com/api/v1/file/6622b0b3df5a87675edbc079/download/hdf5.${HDF5_SELECT_VERSION}.tar.gz")
    set(HDF5_md5 "3ff8830763b0356408e1d454628fa25e")
  else()
    message(ERROR "HDF5 Version ${HDF5_SELECT_VERSION} Not Supported")
  endif()
endif()
list(APPEND fletch_external_sources HDF5)

# SNAPPY
if(NOT WIN32)
  set(Snappy_version "1.1.3")
  set(Snappy_url "https://data.kitware.com/api/v1/file/6622b533df5a87675edbc100/download/snappy.${Snappy_version}.tar.gz")
  set(Snappy_md5 "7358c82f133dc77798e4c2062a749b73")
  list(APPEND fletch_external_sources Snappy)
endif()

# LevelDB
if(NOT WIN32)
  set(LevelDB_version "1.19")
  set(LevelDB_url "https://data.kitware.com/api/v1/file/6622b0c5df5a87675edbc085/download/leveldb.${LevelDB_version}.tar.gz")
  set(LevelDB_md5 "6c201409cce6b711f46d68e0f4b1090a")
  list(APPEND fletch_external_sources LevelDB)
endif()

# Protobuf
if(NOT WIN32)
  if (fletch_ENABLE_Protobuf OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
    set(Protobuf_SELECT_VERSION "3.4.1" CACHE STRING "Select the  version of ProtoBuf to build.")
    set_property(CACHE Protobuf_SELECT_VERSION PROPERTY STRINGS "2.5.0" "3.4.1")
  endif()

  set(Protobuf_version ${Protobuf_SELECT_VERSION})

  if (Protobuf_version VERSION_EQUAL 2.5.0)
    set(Protobuf_url "https://data.kitware.com/api/v1/file/6622b26ddf5a87675edbc0df/download/protobuf.${Protobuf_version}.tar.bz2" )
    set(Protobuf_md5 "a72001a9067a4c2c4e0e836d0f92ece4" )
  elseif (Protobuf_version VERSION_EQUAL 3.4.1)
    set(Protobuf_url "https://data.kitware.com/api/v1/file/6622b26fdf5a87675edbc0e2/download/protobuf.${Protobuf_version}.tar.gz" )
    set(Protobuf_md5 "74446d310ce79cf20bab3ffd0e8f8f8f" )
  elseif(Protobuf_version)
    message(ERROR "Protobuf Version ${Protobuf_version} Not Supported")
  endif()
  list(APPEND fletch_external_sources Protobuf )
endif()

# Darknet
# The Darket package used is a fork maintained by kitware that uses CMake and supports building/running on windows
set(Darknet_url "https://data.kitware.com/api/v1/file/6622b07fdf5a87675edbc04c/download/darknet.zip")
set(Darknet_md5 "5dd51e1965848b5186c08ddab2414489")
list(APPEND fletch_external_sources Darknet)

# pybind11
if (fletch_ENABLE_pybind11 OR fletch_ENABLE_ALL_PACKAGES)
  set(pybind11_SELECT_VERSION 2.10.3 CACHE STRING "Select the version of pybind11 to build.")
  set_property(CACHE pybind11_SELECT_VERSION PROPERTY STRINGS "2.5.0" "2.10.3")
endif()

set(pybind11_version ${pybind11_SELECT_VERSION})

if (pybind11_version VERSION_EQUAL 2.5.0)
  set(pybind11_url "https://data.kitware.com/api/v1/file/6622b270df5a87675edbc0e5/download/pybind11.${pybind11_version}.tar.gz")
  set(pybind11_md5 "1ad2c611378fb440e8550a7eb6b31b89" )
elseif (pybind11_version VERSION_EQUAL 2.10.3)
  set(pybind11_url "https://data.kitware.com/api/v1/file/6622b270df5a87675edbc0e8/download/pybind11.${pybind11_version}.tar.gz")
  set(pybind11_md5 "a093dac9dfd613a5a7c2afa50a301098" )
elseif(pybind11_version)
  message(ERROR "pybind11 Version ${pybind11_version} Not Supported")
endif()

list(APPEND fletch_external_sources pybind11)

# YAMLcpp
set(YAMLcpp_version "0.7.0")
set(YAMLcpp_url "https://data.kitware.com/api/v1/file/6622b59cdf5a87675edbc124/download/yamlcpp.${YAMLcpp_version}.tar.gz")
set(YAMLcpp_md5 "74d646a3cc1b5d519829441db96744f0")
list(APPEND fletch_external_sources YAMLcpp)

# qtExtensions
set(qtExtensions_SELECT_VERSION latest CACHE STRING "Select the version of qtExtensions to build.")
set_property(CACHE qtExtensions_SELECT_VERSION PROPERTY STRINGS "20200330" "latest")
if(fletch_ENABLE_qtExtensions OR fletch_ENABLE_ALL_PACKAGES)
  if(qtExtensions_SELECT_VERSION STREQUAL "latest")
    if (Qt_version VERSION_LESS 5.10)
      message(ERROR "qtExtensions 'latest' does not support Qt Version \"${Qt_version}\"")
    endif()
    set(qtExtensions_version "20210309git0ff5b486")
    set(qtExtensions_tag "0ff5b486f08435c8cdfbc9f05d2f104f63b16aed")
    set(qtExtensions_url "https://data.kitware.com/api/v1/file/6622b271df5a87675edbc0ee/download/qtextensions.${qtExtensions_version}.tar.gz")
    set(qtExtensions_md5 "772d97e455961fb0462d658411ef8be6")
  else()
    set(qtExtensions_version "20200330gitb2848e06")
    set(qtExtensions_tag "b2848e06ebba4c39dc63caa2363abc50db75f9d9")
    set(qtExtensions_url "https://data.kitware.com/api/v1/file/6622b271df5a87675edbc0eb/download/qtextensions.${qtExtensions_version}.tar.gz")
    set(qtExtensions_md5 "24bef5cdaac9d9f0615564b6188a07e5")
  endif()
endif()
list(APPEND fletch_external_sources qtExtensions)

# ZeroMQ
set(ZeroMQ_version "4.2.5")
set(ZeroMQ_url "https://data.kitware.com/api/v1/file/6622b59edf5a87675edbc12a/download/zeromq.${ZeroMQ_version}.tar.gz")
set(ZeroMQ_md5 "da43d89dac623d99909fb95e2725fe05")
list(APPEND fletch_external_sources ZeroMQ)

# CPP ZeroMQ header
set(cppzmq_SELECT_VERSION 4.2.3 CACHE STRING "Select the version of cppzmq to build.")
set_property(CACHE cppzmq_SELECT_VERSION PROPERTY STRINGS "4.2.3" "4.10.0")
mark_as_advanced(cppzmq_SELECT_VERSION)

set(cppzmq_version ${cppzmq_SELECT_VERSION})
set(cppzmq_url "https://github.com/zeromq/cppzmq/archive/v${cppzmq_version}.zip")
if (cppzmq_version VERSION_EQUAL 4.2.3)
  set(cppzmq_md5 "f5a2ef3a4d47522fcb261171eb7ecfc4")
elseif (cppzmq_version VERSION_EQUAL 4.10.0)
  set(cppzmq_md5 "b3110cc4146126cfde994f1fd8ae904b")
  set(cppzmq_dlname "cppzmq-v${cppzmq_version}.zip")
else()
  message("Unsupported cppzmq version ${cppzmq_version}")
endif()
list(APPEND fletch_external_sources cppzmq)

#+
# Iterate through our sources, create local filenames and set up the "ENABLE"
# options
#-
set(fletch_files )
foreach(source ${fletch_external_sources})
  # Set up the ENABLE option for the package
  option(fletch_ENABLE_${source} "Include ${source} version ${${source}_version}")
  set(${source}_file ${${source}_url})
endforeach()
