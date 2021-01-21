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
set(ZLib_version 1.2.9)
set(ZLib_url "https://github.com/madler/zlib/archive/v${ZLib_version}.zip")
set(zlib_md5 "d71ee9e2998abd2fdfb6a40c8f3c7bd7")
set(zlib_dlname "zlib-${ZLib_version}.zip")
list(APPEND fletch_external_sources ZLib)

# CPython
if(fletch_PYTHON_MAJOR_VERSION STREQUAL "2")
  set(CPython_version_major 2)
  set(CPython_version_minor 7)
  set(CPython_version_modifier )
  set(CPython_version ${CPython_version_major}.${CPython_version_minor})
  set(CPython_url "https://github.com/python/cpython/archive/${CPython_version}.zip")
  set(CPython_md5 "3c1b1e1511e8b026f06c29c4cb7bc5aa")
else()
  set(CPython_version_major 3)
  set(CPython_version_minor 6)
  set(CPython_version_patch 9)
  set(CPython_version_modifier m)
  set(CPython_version ${CPython_version_major}.${CPython_version_minor})
  set(CPython_full_version ${CPython_version}.${CPython_version_patch})
  set(CPython_url "https://github.com/python/cpython/archive/v${CPython_full_version}.zip")
  set(CPython_md5 "70fd4923d7102a1a97ebd081071d5969")
endif()
list(APPEND fletch_external_sources CPython)

# Boost
# Support 1.55.0 (Default) and 1.65.1 optionally
if(fletch_ENABLE_Boost OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
  set(Boost_SELECT_VERSION 1.65.1 CACHE STRING "Select the major version of Boost to build.")
  set_property(CACHE Boost_SELECT_VERSION PROPERTY STRINGS "1.55.0" "1.65.1")
  message(STATUS "Boost Select version: ${Boost_SELECT_VERSION}")

  if(Boost_SELECT_VERSION VERSION_EQUAL 1.65.1)
    # Boost 1.65.1
    set(Boost_major_version 1)
    set(Boost_minor_version 65)
    set(Boost_patch_version 1)
    set(Boost_url "http://sourceforge.net/projects/boost/files/boost/${Boost_SELECT_VERSION}/boost_${Boost_major_version}_${Boost_minor_version}_${Boost_patch_version}.tar.bz2")
    set(Boost_md5 "41d7542ce40e171f3f7982aff008ff0d")
  else()
    message(STATUS "Boost_SELECT_VERSION: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources Boost)

# libjpeg-turbo
set(libjpeg-turbo_version "1.4.0")
set(libjpeg-turbo_url "http://sourceforge.net/projects/libjpeg-turbo/files/libjpeg-turbo-${libjpeg-turbo_version}.tar.gz")
set(libjpeg-turbo_md5 "039153dabe61e1ac8d9323b5522b56b0")
list(APPEND fletch_external_sources libjpeg-turbo)

# libtiff
set(libtiff_version "4.1.0")
set(libtiff_url "http://download.osgeo.org/libtiff/tiff-${libtiff_version}.tar.gz")
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
  set(PNG_url "http://sourceforge.net/projects/libpng/files/libpng${PNG_major_minor_no_dot}/older-releases/${PNG_version}/lpng${PNG_major_minor_no_dot}${PNG_version_patch}.zip")
  set(PNG_md5 "ff0e82b4d8516daa7ed6b1bf93acca48")
else()
  set(PNG_url "http://sourceforge.net/projects/libpng/files/libpng${PNG_major_minor_no_dot}/older-releases/${PNG_version}/libpng-${PNG_version}.tar.gz")
  set(PNG_md5 "3121bdc77c365a87e054b9f859f421fe")
endif()
list(APPEND fletch_external_sources PNG)

# openjpeg
set(openjpeg_version "2.3.0")
set(openjpeg_url "https://github.com/uclouvain/openjpeg/archive/v${openjpeg_version}.tar.gz")
set(openjpeg_md5 "6a1f8aaa1fe55d2088e3a9c942e0f698")
set(openjpeg_dlname "openjpeg-v${openjpeg_version}.tar.gz")
list(APPEND fletch_external_sources openjpeg)

# YASM for building jpeg-turbo, not third party library
set(yasm_version "1.3.0")
set(yasm_url "https://github.com/yasm/yasm/archive/v1.3.0.tar.gz")
set(yasm_md5 "38802696efbc27554d75d93a84a23183")

# FFmpeg
set(_FFmpeg_supported TRUE)
if (fletch_ENABLE_FFmpeg OR fletch_ENABLE_ALL_PACKAGES)
  # allow different versions to be selected for testing purposes
  set(FFmpeg_SELECT_VERSION 3.3.3 CACHE STRING "Select the version of FFmpeg to build.")
  set_property(CACHE FFmpeg_SELECT_VERSION PROPERTY STRINGS "2.6.2" "3.3.3")
  mark_as_advanced(FFmpeg_SELECT_VERSION)

  if(WIN32)
    # The windows 2.6 version is git-c089e72 (2015-03-05)
    # follows: n2.6-dev (2014-12-03)
    # precedes: n2.6 (2015-03-06) - n2.7-dev (2015-03-06)
    set(_FFmpeg_version ${FFmpeg_SELECT_VERSION})

    if (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} LESS 3.1 )
      message(FATAL_ERROR "CMake ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} is too old to support the 7z extension of FFmpeg")
    endif()
    include(CheckTypeSize)
    if (CMAKE_SIZEOF_VOID_P EQUAL 4)  # 32 Bits
      set(bitness 32)
      message(FATAL_ERROR "Fletch does NOT support FFMPEG 32 bit. Please use 64 bit.")
    endif()
    # On windows download prebuilt binaries and shared libraries
    # dev contains headers .lib, .def, and mingw .dll.a files
    # shared contains dll and exe files.
    if (_FFmpeg_version VERSION_EQUAL 3.3.3)
      set(FFmpeg_dev_md5 "2788ff871ba1c1b91b6f0e91633bef2a")
      set(FFmpeg_shared_md5 "beb39d523cdb032b59f81db80b020f31")
      set(FFmpeg_dev_url    "https://data.kitware.com/api/v1/file/5c520afc8d777f072b212cca/download/ffmpeg-3.3.3-win64-dev.zip")
      set(FFmpeg_shared_url "https://data.kitware.com/api/v1/file/5c520b068d777f072b212cd4/download/ffmpeg-3.3.3-win64-shared.zip")
    elseif (_FFmpeg_version VERSION_EQUAL 2.6.2)
      set(FFmpeg_dev_md5 "748d5300316990c6a40a23bbfc3abff4")
      set(FFmpeg_shared_md5 "33dbda4fdcb5ec402520528da7369585")
      set(FFmpeg_dev_url    "https://data.kitware.com/api/v1/file/591a0e258d777f16d01e0cb8/download/ffmpeg_dev_win64.7z")
      set(FFmpeg_shared_url "https://data.kitware.com/api/v1/file/591a0e258d777f16d01e0cb5/download/ffmpeg_shared_win64.7z")
    else (_FFmpeg_supported AND _FFmpeg_version)
      message("Unsupported FFmpeg version ${_FFmpeg_version}")
    endif()
  else()
    #set(_FFmpeg_version 3.3.3) # (2017-07-29)
    #set(_FFmpeg_version 2.6.2) # (2015-04-10)
    set(_FFmpeg_version ${FFmpeg_SELECT_VERSION})
    set(FFmpeg_url "http://www.ffmpeg.org/releases/ffmpeg-${_FFmpeg_version}.tar.gz")

    if (_FFmpeg_version VERSION_EQUAL 3.3.3)
      set(FFmpeg_md5 "f32df06c16bdc32579b7fcecd56e03df")
    elseif (_FFmpeg_version VERSION_EQUAL 2.6.2)
      set(FFmpeg_md5 "412166ef045b2f84f23e4bf38575be20")
    elseif (_FFmpeg_supported AND _FFmpeg_version)
      message("Unsupported FFmpeg version ${_FFmpeg_version}")
    endif()

  endif()
endif()
if(_FFmpeg_supported)
  list(APPEND fletch_external_sources FFmpeg)
endif()

# EIGEN
set(Eigen_version 3.3.7)
set(Eigen_url "https://gitlab.com/libeigen/eigen/-/archive/${Eigen_version}/eigen-${Eigen_version}.tar.gz")
set(Eigen_md5 "9e30f67e8531477de4117506fe44669b")
set(Eigen_dlname "eigen-${Eigen_version}.tar.gz")
list(APPEND fletch_external_sources Eigen)

# log4cplus
set(log4cplus_version "1.2.x")
set(log4cplus_url "https://github.com/Kitware/log4cplus/archive/1.2.x.zip")
set(log4cplus_md5 "4c0973becab54c8492204258260dcf06")
set(log4cplus_dlname "log4cplus-${log4cplus_version}.zip")
list(APPEND fletch_external_sources log4cplus)

# GFlags
set(GFlags_version "2.2.1")
set(GFlags_url "https://github.com/gflags/gflags/archive/v${GFlags_version}.tar.gz")
set(GFlags_md5 "b98e772b4490c84fc5a87681973f75d1")
set(GFlags_dlname "gflags-${GFlags_version}.tar.gz")
list(APPEND fletch_external_sources GFlags)

# GLog
set(GLog_version "0.3.5")
set(GLog_url "https://github.com/google/glog/archive/v${GLog_version}.tar.gz")
set(GLog_md5 "5df6d78b81e51b90ac0ecd7ed932b0d4")
set(GLog_dlname "glog-${GLog_version}.tar.gz")
list(APPEND fletch_external_sources GLog)

set(GTest_version "1.8.1")
set(GTest_url "https://github.com/google/googletest/archive/release-${GTest_version}.tar.gz")
set(GTest_md5 "2e6fbeb6a91310a16efe181886c59596")
set(GTest_dlname "gtest-${GTest_version}.tar.gz")
list(APPEND fletch_external_sources GTest)

#OpenBLAS
if(NOT WIN32)
  set(OpenBLAS_SELECT_VERSION 0.3.10 CACHE STRING "Select the version of OpenBLAS to build.")
  set_property(CACHE OpenBLAS_SELECT_VERSION PROPERTY STRINGS "0.3.10" "0.3.6")

  set (OpenBLAS_version ${OpenBLAS_SELECT_VERSION})
  if (OpenBLAS_version VERSION_EQUAL 0.3.6)
    set(OpenBLAS_md5 "8a110a25b819a4b94e8a9580702b6495")
  elseif (OpenBLAS_version VERSION_EQUAL 0.3.10)
    set(OpenBLAS_md5 "4727a1333a380b67c8d7c7787a3d9c9a")
  else()
    message("Unknown OpenBLAS version = ${OpenBLAS_version}")
  endif()
#  set(OpenBLAS_version "0.3.6")
  set(OpenBLAS_url "https://github.com/xianyi/OpenBLAS/archive/v${OpenBLAS_version}.tar.gz")
#  set(OpenBLAS_md5 "8a110a25b819a4b94e8a9580702b6495")
  set(OpenBLAS_dlname "openblas-${OpenBLAS_version}.tar.gz")
  list(APPEND fletch_external_sources OpenBLAS)
endif()

#SuiteSparse
set(SuiteSparse_version 4.4.5)
set(SuiteSparse_url "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-${SuiteSparse_version}.tar.gz")
set(SuiteSparse_md5 "a2926c27f8a5285e4a10265cc68bbc18")
list(APPEND fletch_external_sources SuiteSparse)

# Ceres Solver
set(Ceres_version 1.14.0)
set(Ceres_url "http://ceres-solver.org/ceres-solver-${Ceres_version}.tar.gz")
set(Ceres_md5 "fd9b4eba8850f0f2ede416cd821aafa5")
set(Ceres_dlname "ceres-${Ceres_version}.tar.gz")
list(APPEND fletch_external_sources Ceres)

if(NOT WIN32)
  set(libxml2_release "2.9")
  set(libxml2_patch_version 0)
  set(libxml2_url "http://xmlsoft.org/sources/libxml2-2.9.0.tar.gz")
  set(libxml2_md5 "5b9bebf4f5d2200ae2c4efe8fa6103f7")
  list(APPEND fletch_external_sources libxml2)
endif()

# jom
if(WIN32)
  # this is only used by the Qt external project to speed builds
  set(jom_version 1_0_16)
  set(jom_url "http://download.qt.io/official_releases/jom/jom_${jom_version}.zip")
  set(jom_md5 "a021066aefcea8999b382b1c7c12165e")
endif()

# libjson
set(libjson_version_major 7)
set(libjson_version_minor 6)
set(libjson_version_patch 1)
set(libjson_version "${libjson_version_major}.${libjson_version_minor}.${libjson_version_patch}")
set(libjson_url "http://sourceforge.net/projects/libjson/files/libjson_${libjson_version}.zip")
set(libjson_md5 "82f3fcbf9f8cf3c4e25e1bdd77d65164")
list(APPEND fletch_external_sources libjson)

# shapelib
set(shapelib_version 1.4.1)
set(shapelib_url "http://download.osgeo.org/shapelib/shapelib-${shapelib_version}.tar.gz")
set(shapelib_md5 "ae9f1fcd2adda35b74ac4da8674a3178")
list(APPEND fletch_external_sources shapelib)

# TinyXML_1
set(TinyXML1_version_major "2")
set(TinyXML1_version_minor "6")
set(TinyXML1_version_patch "2")
set(TinyXML1_url "http://sourceforge.net/projects/tinyxml/files/tinyxml_${TinyXML1_version_major}_${TinyXML1_version_minor}_${TinyXML1_version_patch}.zip")
set(TinyXML1_md5 "2a0aaf609c9e670ec9748cd01ed52dae")
set(TinyXML1_dlname "tinyXML1.zip")
list(APPEND fletch_external_sources TinyXML1)

# TinyXML_2
set(TinyXML2_version_major "7")
set(TinyXML2_version_minor "0")
set(TinyXML2_version_patch "1")
set(TinyXML2_url "https://github.com/leethomason/tinyxml2/archive/${TinyXML2_version_major}.${TinyXML2_version_minor}.${TinyXML2_version_patch}.zip")
set(TinyXML2_md5 "03ad292c4b6454702c0cc22de0d196ad")
set(TinyXML2_dlname "tinyXML2.zip")
list(APPEND fletch_external_sources TinyXML2)

# libkml
set(libkml_version "20150911git79b3eb0")
set(libkml_tag "79b3eb066eacd8fb117b10dc990b53b4cd11f33d")
set(libkml_url "https://github.com/kitware/libkml/archive/${libkml_tag}.zip")
set(libkml_md5 "a232dfd4eb07489768b207d88b983267")
set(libkml_dlname "libkml-${libkml_version}.zip")
list(APPEND fletch_external_sources libkml)

# Qt
# Support 4.8.6 and 5.11 optionally
if (fletch_ENABLE_Qt OR fletch_ENABLE_VTK OR fletch_ENABLE_qtExtensions OR
    fletch_ENABLE_ALL_PACKAGES)
  set(Qt_SELECT_VERSION 5.11.2 CACHE STRING "Select the version of Qt to build.")
  set_property(CACHE Qt_SELECT_VERSION PROPERTY STRINGS "4.8.6" "5.11.2" "5.12.8")

  set(Qt_version ${Qt_SELECT_VERSION})
  string(REPLACE "." ";" Qt_VERSION_LIST ${Qt_version})
  list(GET Qt_VERSION_LIST 0 Qt_version_major)
  list(GET Qt_VERSION_LIST 1 Qt_version_minor)
  list(GET Qt_VERSION_LIST 2 Qt_version_patch)
  set(Qt_release_location new_archive) # official_releases or new_archive

  if (Qt_version VERSION_EQUAL 5.11.2)
    set(Qt_url "https://data.kitware.com/api/v1/item/5e62b6d0af2e2eed3506dcc3/download")
    set(Qt_md5 "152a8ade9c11fe33ff5bc95310a1bb64")
  elseif (Qt_version VERSION_EQUAL 5.12.8)
    set(Qt_release_location archive) # official_releases or new_archive
    set(Qt_url "https://download.qt.io/${Qt_release_location}/qt/5.12/${Qt_version}/single/qt-everywhere-src-${Qt_version}.tar.xz")
    set(Qt_md5 "8ec2a0458f3b8e9c995b03df05e006e4")
  elseif (Qt_version VERSION_EQUAL 4.8.6)
    set(Qt_release_location new_archive)
    set(Qt_url "https://data.kitware.com/api/v1/item/600701c42fa25629b9fcd844/download")
    set(Qt_md5 "2edbe4d6c2eff33ef91732602f3518eb")
  else()
    message(ERROR "Qt Version \"${Qt_version}\" Not Supported")
  endif()
endif()
list(APPEND fletch_external_sources Qt)

# OpenCV
# Support 2.4.13 and 3.4 optionally
if (fletch_ENABLE_OpenCV OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
  set(OpenCV_SELECT_VERSION 3.4.0 CACHE STRING "Select the  version of OpenCV to build.")
  set_property(CACHE OpenCV_SELECT_VERSION PROPERTY STRINGS "2.4.13" "3.4.0")

  set(OpenCV_version ${OpenCV_SELECT_VERSION})
  set(OpenCV_url "http://github.com/Itseez/opencv/archive/${OpenCV_version}.zip")
  set(OpenCV_dlname "opencv-${OpenCV_version}.zip")

  # Expose optional contrib repo when enabling OpenCV version >= 3.x
  if (NOT OpenCV_SELECT_VERSION VERSION_LESS 3.0.0 )
    list(APPEND fletch_external_sources OpenCV_contrib)
    set(OpenCV_contrib_version "${OpenCV_version}")
    set(OpenCV_contrib_url "http://github.com/Itseez/opencv_contrib/archive/${OpenCV_contrib_version}.zip")
    set(OpenCV_contrib_dlname "opencv-contrib-${OpenCV_version}.zip")
  else()
    # Remove Contrib repo option when OpenCV is not the correct version
    unset(fletch_ENABLE_OpenCV_contrib CACHE)
  endif()

  # Paired contrib repo information
  if (OpenCV_version VERSION_EQUAL 3.4.0)
    set(OpenCV_md5 "ed60f8bbe7a448f325d0a0f58fcf2063")
    set(OpenCV_contrib_md5 "92c09ce6c837329f05802a8d17136148")
  elseif (OpenCV_version VERSION_EQUAL 2.4.13)
    set(OpenCV_md5 "886b0c511209b2f3129649928135967c")
  else()
    message(ERROR " OpenCV Version \"${OpenCV_version}\" Not Supported")
  endif()
else()
  # Remove Contrib repo option when OpenCV is not enabled
  unset(fletch_ENABLE_OpenCV_contrib CACHE)
endif()
list(APPEND fletch_external_sources OpenCV)

# PROJ.4
set(PROJ4_version "4.9.3" )
set(PROJ4_url "http://download.osgeo.org/proj/proj-${PROJ4_version}.tar.gz" )
set(PROJ4_md5 "d598336ca834742735137c5674b214a1" )
list(APPEND fletch_external_sources PROJ4 )

# libgeotiff
set(libgeotiff_version "1.4.2")
set(libgeotiff_url "http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-${libgeotiff_version}.zip")
set(libgeotiff_md5 "a7c7e11e301b7c17e44ea3107cd86e4e")
list(APPEND fletch_external_sources libgeotiff)

# GDAL
if (fletch_ENABLE_GDAL OR fletch_ENABLE_ALL_PACKAGES)
  set(GDAL_SELECT_VERSION 2.3.2 CACHE STRING "Select the major version of GDAL to build.")
  set_property(CACHE GDAL_SELECT_VERSION PROPERTY STRINGS "2.3.2" "1.11.5")
  message(STATUS "GDAL Select version: ${GDAL_SELECT_VERSION}")
  if (GDAL_SELECT_VERSION VERSION_EQUAL 2.3.2)
    set(GDAL_version "2.3.2")
    set(GDAL_url "http://download.osgeo.org/gdal/${GDAL_version}/gdal-${GDAL_version}.tar.gz")
    set(GDAL_md5 "221e4bfe3e8e9443fd33f8fe46f8bf60")
  elseif(GDAL_SELECT_VERSION VERSION_EQUAL 1.11.5)
    set(GDAL_version "1.11.5")
    set(GDAL_url "http://download.osgeo.org/gdal/${GDAL_version}/gdal-${GDAL_version}.tar.gz")
    set(GDAL_md5 "879fa140f093a2125f71e38502bdf714")
  else()
    message(STATUS "GDAL_SELECT_VERSION ${GDAL_SELECT_VERSION}: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources GDAL)

# GEOS
set(GEOS_version "3.6.2" )
set(GEOS_url "http://download.osgeo.org/geos/geos-${GEOS_version}.tar.bz2" )
set(GEOS_md5 "a32142343c93d3bf151f73db3baa651f" )
list(APPEND fletch_external_sources GEOS )

# PDAL
set(PDAL_version 1.7.2)
set(PDAL_url "https://github.com/PDAL/PDAL/releases/download/${PDAL_version}/PDAL-${PDAL_version}-src.tar.gz")
set(PDAL_md5 "a89710005fd54e6d2436955e2e542838")
list(APPEND fletch_external_sources PDAL)

# GeographicLib
set(GeographicLib_version "1.49" )
set(GeographicLib_url "http://sourceforge.net/projects/geographiclib/files/distrib/GeographicLib-${GeographicLib_version}.tar.gz" )
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
    set(PostgreSQL_url "http://ftp.PostgreSQL.org/pub/source/v${PostgreSQL_version}/postgresql-${PostgreSQL_version}.tar.bz2")
    set(PostgreSQL_md5 "11e037afaa4bd0c90bb3c3d955e2b401")
  elseif(PostgreSQL_SELECT_VERSION VERSION_EQUAL 10.2)
    # PostgreSQL 9.4
    set(PostgreSQL_version ${PostgreSQL_SELECT_VERSION})
    set(PostgreSQL_url "http://ftp.PostgreSQL.org/pub/source/v${PostgreSQL_version}/postgresql-${PostgreSQL_version}.tar.bz2")
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
  set(PostGIS_url "http://download.osgeo.org/postgis/source/postgis-${PostGIS_version}.tar.gz" )
  set(PostGIS_md5 "475bca6249ee11f675b899de14fd3f42" )
  list(APPEND fletch_external_sources PostGIS )
endif()

# CPPDB
set(CppDB_version "0.3.0" )
set(CppDB_url "https://sourceforge.net/projects/cppcms/files/cppdb/${CppDB_version}/cppdb-${CppDB_version}.tar.bz2" )
set(CppDB_md5 "091d1959e70d82d62a04118827732dfe")
list(APPEND fletch_external_sources CppDB)

# VTK
if (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  set(VTK_SELECT_VERSION 8.2 CACHE STRING "Select the version of VTK to build.")
  set_property(CACHE VTK_SELECT_VERSION PROPERTY STRINGS 6.2 8.0 8.2)
endif()

if (VTK_SELECT_VERSION VERSION_EQUAL 8.2)
  set(VTK_version 8.2.0)
  set(VTK_md5 "94ba8959b56dcfa6bac996158669ac36")
elseif (VTK_SELECT_VERSION VERSION_EQUAL 8.0)
  set(VTK_version 8.0.1)
  set(VTK_md5 "c248dbe8ffd9b74c6f41199e66d6c690")  # v8.0.1
elseif (VTK_SELECT_VERSION VERSION_EQUAL 6.2)
  # TODO: Remove when we remove support for OpenCV < 3.2
  set(VTK_version 6.2.0)
  set(VTK_md5 "2363432e25e6a2377e1c241cd2954f00")  # v6.2
elseif (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  message(ERROR "VTK Version ${VTK_SELECT_VERSION} Not Supported")
endif()
set(VTK_url "http://www.vtk.org/files/release/${VTK_SELECT_VERSION}/VTK-${VTK_version}.zip")
list(APPEND fletch_external_sources VTK)

# VXL
set(VXL_version "c3fd27959f51e0469a7a6075e975f245ac306f3d")
set(VXL_url "https://github.com/vxl/vxl/archive/${VXL_version}.zip")
set(VXL_md5 "9ae63bb158ae3e5e2104152093a4c46c")
set(VXL_dlname "vxl-${VXL_version}.zip")
list(APPEND fletch_external_sources VXL)

# LMDB
if(NOT WIN32)
  set(LMDB_version "0.9.16")
  set(LMDB_url "https://github.com/LMDB/lmdb/archive/LMDB_${LMDB_version}.tar.gz")
  set(LMDB_md5 "0de89730b8f3f5711c2b3a4ba517b648")
  list(APPEND fletch_external_sources LMDB)
endif()

# HDF5
set(HDF5_major "1.8")
set(HDF5_rev "17")
set(HDF5_version "${HDF5_major}.${HDF5_rev}")
set(HDF5_url "https://support.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-${HDF5_major}/hdf5-${HDF5_version}/src/hdf5-${HDF5_version}.tar")
set(HDF5_md5 "bdf0fc3d648679eeb5d7b4b78f92a83f")
list(APPEND fletch_external_sources HDF5)

# SNAPPY
if(NOT WIN32)
  set(Snappy_version "1.1.3")
  set(Snappy_url "https://github.com/google/snappy/releases/download/1.1.3/snappy-${Snappy_version}.tar.gz")
  set(Snappy_md5 "7358c82f133dc77798e4c2062a749b73")
  list(APPEND fletch_external_sources Snappy)
endif()

# LevelDB
if(NOT WIN32)
  set(LevelDB_version "1.19")
  set(LevelDB_url "https://github.com/google/leveldb/archive/v${LevelDB_version}.tar.gz")
  set(LevelDB_md5 "6c201409cce6b711f46d68e0f4b1090a")
  set(LevelDB_dlname "leveldb-${LevelDB_version}.tar.gz")
  list(APPEND fletch_external_sources LevelDB)
endif()

# ITK
set(ITK_version "fc688e7a2c89967e3d6cbb779f87ec37a4e4750b")
set(ITK_url "https://github.com/InsightSoftwareConsortium/ITK/archive/${ITK_version}.tar.gz")
set(ITK_md5 "8f0965e5ac7828a273dfff8d3b81ff9a")
set(ITK_experimental TRUE)
list(APPEND fletch_external_sources ITK)

# Protobuf
if(NOT WIN32)
  if (fletch_ENABLE_Protobuf OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
    set(Protobuf_SELECT_VERSION "3.4.1" CACHE STRING "Select the  version of ProtoBuf to build.")
    set_property(CACHE Protobuf_SELECT_VERSION PROPERTY STRINGS "2.5.0" "3.4.1")
  endif()

  set(Protobuf_version ${Protobuf_SELECT_VERSION})

  if (Protobuf_version VERSION_EQUAL 2.5.0)
    set(Protobuf_url "https://github.com/google/protobuf/releases/download/v${Protobuf_version}/protobuf-${Protobuf_version}.tar.bz2" )
    set(Protobuf_md5 "a72001a9067a4c2c4e0e836d0f92ece4" )
  elseif (Protobuf_version VERSION_EQUAL 3.4.1)
    set(Protobuf_url "https://github.com/google/protobuf/releases/download/v${Protobuf_version}/protobuf-cpp-${Protobuf_version}.tar.gz" )
    set(Protobuf_md5 "74446d310ce79cf20bab3ffd0e8f8f8f" )
  elseif(Protobuf_version)
    message(ERROR "Protobuf Version ${Protobuf_version} Not Supported")
  endif()
  list(APPEND fletch_external_sources Protobuf )
endif()

# Caffe
set(Caffe_SELECT_VERSION "1" CACHE STRING "Select the  version of Caffe to build.")
set_property(CACHE Caffe_SELECT_VERSION PROPERTY STRINGS "1" "2")

set(Caffe_version ${Caffe_SELECT_VERSION})

if (Caffe_version VERSION_EQUAL 2)
  # Use the internal kitware hosted Caffe, which contain additional
  # functionality that has not been merged into the BVLC version.
  # This is the recommended option.
  if(WIN32)
    set(Caffe_version "527f97c0692f116ada7cb97eed8172ef7da05416")
    set(Caffe_url "https://gitlab.kitware.com/kwiver/caffe/-/archive/fletch/windows/caffe-fletch-windows.zip")
    set(Caffe_md5 "4f3f8c56f9bf8f0e7a5534a1080d4ef1")
  else()
    set(Caffe_version "7f5cea3b2986a7d2c913b716eb524c27b6b2ba7b")
    set(Caffe_url "https://gitlab.kitware.com/kwiver/caffe/-/archive/fletch/linux/caffe-fletch-linux.zip")
    set(Caffe_md5 "8eda68aa96d0bbdd446e2125553f46de")
  endif()
else()
  if(WIN32)
    set(Caffe_version "527f97c0692f116ada7cb97eed8172ef7da05416")
    set(Caffe_url "https://gitlab.kitware.com/kwiver/caffe/repository/fletch%2Fwindows/archive.zip")
    set(Caffe_md5 "a8376d867d87b6340313b82d87743bc7")
  else()
    set(Caffe_version "master")
    set(Caffe_url "https://github.com/BVLC/caffe/archive/${Caffe_version}.tar.gz")
    set(Caffe_md5 "ced51467a3923cdf7c24873fe43bda80")
  endif()
endif()
list(APPEND fletch_external_sources Caffe)

# Caffe-Segnet
# This segnet code is based on caffe, and calls itself caffe, but much different than caffe
if(NOT WIN32)
  set(Caffe_Segnet_version "abcf30dca449245e101bf4ced519f716177f0885")
  set(Caffe_Segnet_url "https://data.kitware.com/api/v1/file/59de95548d777f31ac641dbb/download/caffe-segnet-abcf30d.zip")
  set(Caffe_Segnet_md5 "73780d2a1e9761711d4f7b806dd497ef")

  #Move this out when windows is supported
  list(APPEND fletch_external_sources Caffe_Segnet)
endif()

# Darknet
# The Darket package used is a fork maintained by kitware that uses CMake and supports building/running on windows
set(Darknet_url "https://gitlab.kitware.com/kwiver/darknet/-/archive/master/darknet-master.zip")
set(Darknet_md5 "5dd51e1965848b5186c08ddab2414489")
set(Darnet_dlname "darknent-d206b6da7af1f4.zip")
list(APPEND fletch_external_sources Darknet)

# pybind11
set(pybind11_version "2.2.1")
set(pybind11_url "https://github.com/pybind/pybind11/archive/v${pybind11_version}.tar.gz")
set(pybind11_md5 "bab1d46bbc465af5af3a4129b12bfa3b")
set(pybind11_dlname "pybind11-${pybind11_version}.tar.gz")
list(APPEND fletch_external_sources pybind11)

# YAMLcpp
set(YAMLcpp_version "0.5.3")
set(YAMLcpp_url "https://github.com/jbeder/yaml-cpp/archive/release-${YAMLcpp_version}.tar.gz")
set(YAMLcpp_md5 "e2507c3645fc2bec29ba9a1838fb3951")
set(YAMLcpp_dlname "yaml-cpp-release-${YAMLcpp_version}.tar.gz")
list(APPEND fletch_external_sources YAMLcpp)

# qtExtensions
set(qtExtensions_version "20190905git873c0676")
set(qtExtensions_tag "873c06769a2d76e2323152efc40ad910717ce648")
set(qtExtensions_url "https://github.com/Kitware/qtextensions/archive/${qtExtensions_tag}.tar.gz")
set(qtExtensions_md5 "f7b617250040e2e4bffa0e2a0bd93c89")
set(qtExtensions_dlname "qtExtensions-${qtExtensions_version}.tar.gz")
list(APPEND fletch_external_sources qtExtensions)

# ZeroMQ
set(ZeroMQ_version "4.2.5")
set(ZeroMQ_url "https://github.com/zeromq/libzmq/archive/v${ZeroMQ_version}.tar.gz")
set(ZeroMQ_md5 "da43d89dac623d99909fb95e2725fe05")
set(ZeroMQ_dlname "ZeroMQ-v${ZeroMQ_version}.tar.gz")
list(APPEND fletch_external_sources ZeroMQ)

# CPP ZeroMQ header
set(cppzmq_version "4.2.3")
set(cppzmq_url "https://github.com/zeromq/cppzmq/archive/v${cppzmq_version}.zip")
set(cppzmq_md5 "f5a2ef3a4d47522fcb261171eb7ecfc4")
set(cppzmq_dlname "cppzmq-v${cppzmq_version}.zip")
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
