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

# Boost
# Support 1.55.0 (Default) and 1.65.1 optionally
if (fletch_ENABLE_Boost OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
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

# ZLib
set(ZLib_version 1.2.8)
set(ZLib_tag "66a753054b356da85e1838a081aa94287226823e")
set(ZLib_url "https://github.com/commontk/zlib/archive/${ZLib_tag}.zip")
set(zlib_md5 "1d0e64ac4f7c7fe3a73ae044b70ef857")
set(zlib_dlname "zlib-${ZLib_version}.zip")
list(APPEND fletch_external_sources ZLib)

# libjpeg-turbo
set(libjpeg-turbo_version "1.4.0")
set(libjpeg-turbo_url "http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${libjpeg-turbo_version}.tar.gz")
set(libjpeg-turbo_md5 "039153dabe61e1ac8d9323b5522b56b0")
list(APPEND fletch_external_sources libjpeg-turbo)

# libtiff
set(libtiff_version "4.0.6")
set(libtiff_url "http://download.osgeo.org/libtiff/tiff-${libtiff_version}.tar.gz")
set(libtiff_md5 "d1d2e940dea0b5ad435f21f03d96dd72")
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
set(yasm_url "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz")
set(yasm_md5 "fc9e586751ff789b34b1f21d572d96af")

# FFmpeg
set(_FFmpeg_supported TRUE)
if (fletch_ENABLE_FFmpeg OR fletch_ENABLE_ALL_PACKAGES)
  if(WIN32)
    set(FFmpeg_SELECT_VERSION "win32" CACHE STRING "Select the version of FFmpeg to build.")
    set_property(CACHE FFmpeg_SELECT_VERSION PROPERTY STRINGS "win32")
    mark_as_advanced(FFmpeg_SELECT_VERSION)
    # The windows version is git-c089e72 (2015-03-05)
    # follows: n2.6-dev (2014-12-03)
    # precedes: n2.6 (2015-03-06) - n2.7-dev (2015-03-06)
    set(_FFmpeg_version ${FFmpeg_SELECT_VERSION})

    if (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} LESS 3.1 )
      message(FATAL_ERROR "CMake ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} is too old to support the 7z extension of FFmpeg")
    endif()
    include(CheckTypeSize)
    if (CMAKE_SIZEOF_VOID_P EQUAL 4)  # 32 Bits
      set(bitness 32)
      message(FATAL_ERROR "Fletch does NOT support FMPEG 32 bit. Please use 64bit.")
    endif()
    # On windows download prebuilt binaries and shared libraries
    # dev contains headers .lib, .def, and mingw .dll.a files
    # shared contains dll and exe files.
    set(FFmpeg_dev_md5 "748d5300316990c6a40a23bbfc3abff4")
    set(FFmpeg_shared_md5 "33dbda4fdcb5ec402520528da7369585")
    set(FFmpeg_dev_url    "https://data.kitware.com/api/v1/file/591a0e258d777f16d01e0cb8/download/ffmpeg_dev_win64.7z")
    set(FFmpeg_shared_url "https://data.kitware.com/api/v1/file/591a0e258d777f16d01e0cb5/download/ffmpeg_shared_win64.7z")
  else()
    # allow different versions to be selected for testing purposes
    set(FFmpeg_SELECT_VERSION 2.6.2 CACHE STRING "Select the version of FFmpeg to build.")
    set_property(CACHE FFmpeg_SELECT_VERSION PROPERTY STRINGS "2.6.2" "3.3.3")
    mark_as_advanced(FFmpeg_SELECT_VERSION)

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
set(Eigen_version 3.3.4)
set(Eigen_url "http://bitbucket.org/eigen/eigen/get/${Eigen_version}.tar.gz")
set(Eigen_md5 "1a47e78efe365a97de0c022d127607c3")
set(Eigen_dlname "eigen-${Eigen_version}.tar.gz")
list(APPEND fletch_external_sources Eigen)

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
    # TODO remove VTK 6.2 support when we remove support for OpenCV < 3.2
    set(OpenCV_md5 "886b0c511209b2f3129649928135967c")
  else()
    message(ERROR " OpenCV Version \"${OpenCV_version}\" Not Supported")
  endif()
else()
  # Remove Contrib repo option when OpenCV is not enabled
  unset(fletch_ENABLE_OpenCV_contrib CACHE)
endif()
list(APPEND fletch_external_sources OpenCV)

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

set(GTest_version "1.8.0")
set(GTest_url "https://github.com/google/googletest/archive/release-${GTest_version}.tar.gz")
set(GTest_md5 "16877098823401d1bf2ed7891d7dce36")
set(GTest_dlname "gtest-${GTest_version}.tar.gz")
list(APPEND fletch_external_sources GTest)

#OpenBLAS
if(NOT WIN32)
  #set(OpenBLAS_version "0.2.15")
  set(OpenBLAS_version "0.2.20")
  set(OpenBLAS_url "https://github.com/xianyi/OpenBLAS/archive/v${OpenBLAS_version}.tar.gz")

  if (OpenBLAS_version VERSION_EQUAL 0.2.20)
    set(OpenBLAS_md5 "48637eb29f5b492b91459175dcc574b1")
  elseif (OpenBLAS_version VERSION_EQUAL 0.2.15)
    set(OpenBLAS_md5 "b1190f3d3471685f17cfd1ec1d252ac9")
  else()
    message("Unknown OpenBLAS version = ${OpenBLAS_version}")
  endif()
  set(OpenBLAS_dlname "openblas-${OpenBLAS_version}.zip")
  list(APPEND fletch_external_sources OpenBLAS)
endif()

#SuiteSparse
set(SuiteSparse_version 4.4.5)
set(SuiteSparse_url "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-${SuiteSparse_version}.tar.gz")
set(SuiteSparse_md5 "a2926c27f8a5285e4a10265cc68bbc18")
list(APPEND fletch_external_sources SuiteSparse)

# Ceres Solver
set(Ceres_version 1.13.0)
set(Ceres_url "http://ceres-solver.org/ceres-solver-${Ceres_version}.tar.gz")
set(Ceres_md5 "cd568707571c92af3d69c1eb28d63d72")
set(Ceres_dlname "ceres-${Ceres_version}.tar.gz")
list(APPEND fletch_external_sources Ceres)

if(NOT WIN32)
  set(libxml2_release "2.9")
  set(libxml2_patch_version 0)
  set(libxml2_url "ftp://xmlsoft.org/libxml2/libxml2-sources-${libxml2_release}.${libxml2_patch_version}.tar.gz")
  set(libxml2_md5 "7da7af8f62e111497d5a2b61d01bd811")
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
set(libjson_url "http://downloads.sourceforge.net/libjson/libjson_${libjson_version}.zip")
set(libjson_md5 "82f3fcbf9f8cf3c4e25e1bdd77d65164")
list(APPEND fletch_external_sources libjson)

# shapelib
set(shapelib_version 1.4.1)
set(shapelib_url "http://download.osgeo.org/shapelib/shapelib-${shapelib_version}.tar.gz")
set(shapelib_md5 "ae9f1fcd2adda35b74ac4da8674a3178")
list(APPEND fletch_external_sources shapelib)

# TinyXML
set(TinyXML_version_major "2")
set(TinyXML_version_minor "6")
set(TinyXML_version_patch "2")
set(TinyXML_url "http://downloads.sourceforge.net/tinyxml/tinyxml_${TinyXML_version_major}_${TinyXML_version_minor}_${TinyXML_version_patch}.zip")
set(TinyXML_md5 "2a0aaf609c9e670ec9748cd01ed52dae")
list(APPEND fletch_external_sources TinyXML)

# libkml
set(libkml_version "20150911git79b3eb0")
set(libkml_tag "79b3eb066eacd8fb117b10dc990b53b4cd11f33d")
set(libkml_url "https://github.com/kitware/libkml/archive/${libkml_tag}.zip")
set(libkml_md5 "a232dfd4eb07489768b207d88b983267")
set(libkml_dlname "libkml-${libkml_version}.zip")
list(APPEND fletch_external_sources libkml)

# Qt
# Support 4.8.6 and 5.10 optionally
if (fletch_ENABLE_Qt OR fletch_ENABLE_VTK OR fletch_ENABLE_qtExtensions OR
    fletch_ENABLE_ALL_PACKAGES)
  set(Qt_SELECT_VERSION 4.8.6 CACHE STRING "Select the version of Qt to build.")
  set_property(CACHE Qt_SELECT_VERSION PROPERTY STRINGS "4.8.6" "5.10.1")

  set(Qt_version ${Qt_SELECT_VERSION})
  string(REPLACE "." ";" Qt_VERSION_LIST ${Qt_version})
  list(GET Qt_VERSION_LIST 0 Qt_version_major)
  list(GET Qt_VERSION_LIST 1 Qt_version_minor)
  list(GET Qt_VERSION_LIST 2 Qt_version_patch)
  set(Qt_release_location official_releases) # official_releases or archive

  if (Qt_version VERSION_EQUAL 5.10.1)
    set(Qt_url "http://download.qt-project.org/${Qt_release_location}/qt/5.10/${Qt_version}/single/qt-everywhere-src-${Qt_version}.tar.xz")
    set(Qt_md5 "7e167b9617e7bd64012daaacb85477af")
  elseif (Qt_version VERSION_EQUAL 4.8.6)
    set(Qt_release_location archive)
    set(Qt_url "http://download.qt-project.org/${Qt_release_location}/qt/4.8/${Qt_version}/qt-everywhere-opensource-src-${Qt_version}.tar.gz")
    set(Qt_md5 "2edbe4d6c2eff33ef91732602f3518eb")
  else()
    message(ERROR "Qt Version \"${Qt_version}\" Not Supported")
  endif()
endif()
list(APPEND fletch_external_sources Qt)

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
  set(GDAL_SELECT_VERSION 2.3.0 CACHE STRING "Select the major version of GDAL to build.")
  set_property(CACHE GDAL_SELECT_VERSION PROPERTY STRINGS "2.3.0" "1.11.5")
  message(STATUS "GDAL Select version: ${GDAL_SELECT_VERSION}")
  if (GDAL_SELECT_VERSION VERSION_EQUAL 2.3.0)
    set(GDAL_version "2.3.0")
    set(GDAL_url "http://download.osgeo.org/gdal/${GDAL_version}/gdal-${GDAL_version}.tar.gz")
    set(GDAL_md5 "5906e3a92ce4436c1ca5379a06595447")
  elseif(GDAL_SELECT_VERSION VERSION_EQUAL 1.11.5)
    set(GDAL_version "1.11.5")
    set(GDAL_url "http://download.osgeo.org/gdal/${GDAL_version}/gdal-${GDAL_version}.tar.gz")
    set(GDAL_md5 "879fa140f093a2125f71e38502bdf714")
  else()
    message(STATUS "GDAL_SELECT_VERSION ${GDAL_SELECT_VERSION}: Not supported")
  endif()
endif()
list(APPEND fletch_external_sources GDAL)

# GeographicLib
set(GeographicLib_version "1.49" )
set(GeographicLib_url "http://downloads.sourceforge.net/geographiclib/distrib/GeographicLib-${GeographicLib_version}.tar.gz" )
set(GeographicLib_md5 "11300e88b4a38692b6a8712d5eafd4d7" )
list(APPEND fletch_external_sources GeographicLib )

# GEOS
set(GEOS_version "3.6.2" )
set(GEOS_url "http://download.osgeo.org/geos/geos-${GEOS_version}.tar.bz2" )
set(GEOS_md5 "a32142343c93d3bf151f73db3baa651f" )
list(APPEND fletch_external_sources GEOS )

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
  set(PostGIS_version "2.4.3" )
  set(PostGIS_url "http://download.osgeo.org/postgis/source/postgis-${PostGIS_version}.tar.gz" )
  set(PostGIS_md5 "60395f3dc96505ca4e313449d6463c6a" )
  list(APPEND fletch_external_sources PostGIS )
endif()

# CPPDB
set(CppDB_version "0.3.0" )
set(CppDB_url "http://downloads.sourceforge.net/project/cppcms/cppdb/${CppDB_version}/cppdb-${CppDB_version}.tar.bz2" )
set(CppDB_md5 "091d1959e70d82d62a04118827732dfe")
list(APPEND fletch_external_sources CppDB)

# VTK
if (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  set(VTK_SELECT_VERSION 8.0 CACHE STRING "Select the version of VTK to build.")
  set_property(CACHE VTK_SELECT_VERSION PROPERTY STRINGS 6.2 8.0 8.1)
endif()

if (VTK_SELECT_VERSION VERSION_EQUAL 8.1)
  set(VTK_version 8.1.1)
  set(VTK_url "http://www.vtk.org/files/release/${VTK_SELECT_VERSION}/VTK-${VTK_version}.zip")
  set(VTK_md5 "64f3acd5c28b001d5bf0e5a95b3a0af5")  # v8.1.1
elseif (VTK_SELECT_VERSION VERSION_EQUAL 8.0)
  set(VTK_version 8.0.0)
  set(VTK_url "http://www.vtk.org/files/release/${VTK_SELECT_VERSION}/VTK-${VTK_version}.zip")
  set(VTK_md5 "0bec6b6aa3c92cc9e058a12e80257990")  # v8.0.0
elseif (VTK_SELECT_VERSION VERSION_EQUAL 6.2)
  # TODO remove when we remove support for OpenCV < 3.2
  set(VTK_version 6.2.0)
  set(VTK_url "http://www.vtk.org/files/release/${VTK_SELECT_VERSION}/VTK-${VTK_version}.zip")
  set(VTK_md5 "2363432e25e6a2377e1c241cd2954f00")  # v6.2
elseif (fletch_ENABLE_VTK OR fletch_ENABLE_ALL_PACKAGES)
  message(ERROR "VTK Version ${VTK_SELECT_VERSION} Not Supported")
endif()
list(APPEND fletch_external_sources VTK)

# VXL
set(VXL_version "1613dd9f8f06dae759d597c7e86f552a1d539754")
set(VXL_url "https://github.com/vxl/vxl/archive/${VXL_version}.zip")
set(VXL_md5 "f49b704ffc2f5146d303f5b40e977e79")
set(VXL_dlname "vxl-${VXL_version}.zip")
list(APPEND fletch_external_sources VXL)

# ITK
set(ITK_version 4.11)
set(ITK_minor 0)
set(ITK_url "http://downloads.sourceforge.net/project/itk/itk/${ITK_version}/InsightToolkit-${ITK_version}.${ITK_minor}.tar.gz")
set(ITK_md5 "1a71ae9d2f7b3140ac17e8bbb0602c8a")
set(ITK_experimental TRUE)
list(APPEND fletch_external_sources ITK)

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
  set(LevelDB_version "1.18")
  set(LevelDB_url "https://github.com/google/leveldb/archive/v${LevelDB_version}.tar.gz")
  set(LevelDB_md5 "73770de34a2a5ab34498d2e05b2b7fa0")
  set(LevelDB_dlname "leveldb-${LevelDB_version}.tar.gz")
  list(APPEND fletch_external_sources LevelDB)
endif()

# Protobuf
if(NOT WIN32)
  if (fletch_ENABLE_Protobuf OR fletch_ENABLE_ALL_PACKAGES OR AUTO_ENABLE_CAFFE_DEPENDENCY)
    set(Protobuf_SELECT_VERSION "2.5.0" CACHE STRING "Select the  version of ProtoBuf to build.")
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
set(InternalCaffe True)

if(InternalCaffe)
  # Use the internal kitware hosted Caffe, which contain additional
  # functionality that has not been merged into the BVLC version.
  # This is the recommended option.
  if(WIN32)
    set(Caffe_version "527f97c0692f116ada7cb97eed8172ef7da05416")
    set(Caffe_url "https://gitlab.kitware.com/kwiver/caffe/repository/fletch%2Fwindows/archive.zip")
    set(Caffe_md5 "a8376d867d87b6340313b82d87743bc7")
  else()
    set(Caffe_version "7f5cea3b2986a7d2c913b716eb524c27b6b2ba7b")
    set(Caffe_url "https://gitlab.kitware.com/kwiver/caffe/repository/fletch%2Flinux/archive.zip")
    set(Caffe_md5 "29b5ddbd6e2f47836cee5e55c88e098f")
  endif()
else()
  # The original BVLC Caffe does not currently contain required functionality.
  set(Caffe_version "1.0")
  set(Caffe_url "https://github.com/BVLC/caffe/archive/${Caffe_version}.tar.gz")
  set(Caffe_md5 "5fbb0e32e7cd8de3de46e6fe6e4cd2b5")
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
set(Darknet_url "https://gitlab.kitware.com/kwiver/darknet/repository/fletch%2Fmaster/archive.zip")
set(Darknet_md5 "d206b6da7af1f43340a217d6b05db5e3")
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
set(qtExtensions_version "20180815git3c65bd1a")
set(qtExtensions_tag "3c65bd1ad191c181078a95f0bfe6545838bbf3ed")
set(qtExtensions_url "https://github.com/Kitware/qtextensions/archive/${qtExtensions_tag}.zip")
set(qtExtensions_md5 "02fe96039f4e34e21d60fba00d48181d")
set(qtExtensions_dlname "qtExtensions-${qtExtensions_version}.zip")
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
