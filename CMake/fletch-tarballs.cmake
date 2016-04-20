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
set(Boost_major_version 1)
set(Boost_minor_version 55)
set(Boost_patch_version 0)
set(Boost_version ${Boost_major_version}.${Boost_minor_version}.${Boost_patch_version})
set(Boost_url "http://sourceforge.net/projects/boost/files/boost/${Boost_version}/boost_${Boost_major_version}_${Boost_minor_version}_${Boost_patch_version}.tar.bz2")
set(Boost_md5 "d6eef4b4cacb2183f2bf265a5a03a354")
list(APPEND fletch_external_sources Boost)

# ZLib
set(ZLib_version 1.2.8)
set(ZLib_tag "66a753054b356da85e1838a081aa94287226823e")
set(ZLib_url "https://github.com/commontk/zlib/archive/${ZLib_tag}.zip")
set(zlib_md5 "1d0e64ac4f7c7fe3a73ae044b70ef857")
set(zlib_dlname "zlib-${ZLib_version}.zip")
list(APPEND fletch_external_sources ZLib)

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


# EIGEN
set(Eigen_version 3.2.7)
set(Eigen_url "http://bitbucket.org/eigen/eigen/get/${Eigen_version}.tar.gz")
set(Eigen_md5 "76959f105cfbda3ba77889bc204f4bd2")
set(Eigen_dlname "eigen-${Eigen_version}.tar.gz")
list(APPEND fletch_external_sources Eigen)


# OpenCV
# Support 2.4.11 and 3.1 optionally
if (fletch_ENABLE_OpenCV OR fletch_ENABLE_ALL_PACKAGES)
  set(OpenCV_SELECT_VERSION 2.4.11 CACHE STRING "Select the  version of OpenCV to build.")
  set_property(CACHE OpenCV_SELECT_VERSION PROPERTY STRINGS 2.4.11 3.1.0)

  # Expose optional contrib repo when enabling OpenCV version >= 3.x
  if (OpenCV_SELECT_VERSION VERSION_EQUAL 3.0.0 OR OpenCV_SELECT_VERSION VERSION_GREATER 3.0.0)
    list(APPEND fletch_external_sources OpenCV_contrib)
  endif()
endif()

# Remove Contrib repo option when OpenCV not enable or incorrect version
if ( NOT fletch_ENABLE_OpenCV OR OpenCV_SELECT_VERSION VERSION_LESS 3.0.0 )
  unset(fletch_ENABLE_OpenCV_contrib CACHE)
endif()

if (OpenCV_SELECT_VERSION VERSION_EQUAL 3.1.0)
  set(OpenCV_version "3.1.0")
  set(OpenCV_url "http://github.com/Itseez/opencv/archive/${OpenCV_version}.zip")
  set(OpenCV_md5 "6082ee2124d4066581a7386972bfd52a")
  # Paired contrib repo information
  set(OpenCV_contrib_version "${OpenCV_version}")
  set(OpenCV_contrib_url "http://github.com/Itseez/opencv_contrib/archive/${OpenCV_contrib_version}.zip")
  set(OpenCV_contrib_dlname "opencv_contrib-${OpenCV_version}.zip")
  set(OpenCV_contrib_md5 "0d0bfeabe539542791b465ec1c7c90e6")
elseif (OpenCV_SELECT_VERSION VERSION_EQUAL 2.4.11)
  set(OpenCV_version "2.4.11")
  set(OpenCV_url "http://github.com/Itseez/opencv/archive/${OpenCV_version}.zip")
  set(OpenCV_md5 "b517e83489c709eee1d8be76b16976a7")
else()
  message(STATUS "OpenCV Version Not Supported")
endif()
set(OpenCV_dlname "opencv-${OpenCV_version}.zip")
list(APPEND fletch_external_sources OpenCV)

#SuiteSparse
set(SuiteSparse_version 4.4.5)
set(SuiteSparse_url "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-${SuiteSparse_version}.tar.gz")
set(SuiteSparse_md5 "a2926c27f8a5285e4a10265cc68bbc18")
list(APPEND fletch_external_sources SuiteSparse)

# Ceres Solver
set(Ceres_version 1.10.0)
set(Ceres_url "http://ceres-solver.org/ceres-solver-${Ceres_version}.tar.gz")
set(Ceres_md5 "dbf9f452bd46e052925b835efea9ab16")
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
  set(jom_md5 "95fcaabe82f7bb88fd70e3f646850e1f")
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
set(shapelib_version 1.3.0b2)
set(shapelib_url "http://download2.osgeo.org/shapelib/shapelib-${shapelib_version}.tar.gz")
set(shapelib_md5 "708ea578bc299dcd9f723569d12bee8d")
list(APPEND fletch_external_sources shapelib)

# TinyXML
set(TinyXML_version_major "2")
set(TinyXML_version_minor "6")
set(TinyXML_version_patch "2")
set(TinyXML_url "http://downloads.sourceforge.net/tinyxml/tinyxml_${TinyXML_version_major}_${TinyXML_version_minor}_${TinyXML_version_patch}.zip")
set(TinyXML_md5 "2a0aaf609c9e670ec9748cd01ed52dae")
list(APPEND fletch_external_sources TinyXML)

# libjpeg-turbo
set(libjpeg-turbo_version "1.4.0")
set(libjpeg-turbo_url "http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${libjpeg-turbo_version}.tar.gz")
set(libjpeg-turbo_md5 "039153dabe61e1ac8d9323b5522b56b0")
list(APPEND fletch_external_sources libjpeg-turbo)

# YASM for building jpeg-turbo, not third party library
set(yasm_version "1.3.0")
set(yasm_url "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz")
set(yasm_md5 "fc9e586751ff789b34b1f21d572d96af")

# libtiff
set(libtiff_version "4.0.6")
set(libtiff_url "http://download.osgeo.org/libtiff/tiff-${libtiff_version}.tar.gz")
set(libtiff_md5 "d1d2e940dea0b5ad435f21f03d96dd72")
list(APPEND fletch_external_sources libtiff)

# libkml
set(libkml_version "20150911git79b3eb0")
set(libkml_tag "79b3eb066eacd8fb117b10dc990b53b4cd11f33d")
set(libkml_url "https://github.com/kitware/libkml/archive/${libkml_tag}.zip")
set(libkml_md5 "a232dfd4eb07489768b207d88b983267")
list(APPEND fletch_external_sources libkml)

# Qt
set(Qt_release_location official_releases) # official_releases or archive
set(Qt_version_major 4)
set(Qt_version_minor 8)
set(Qt_patch_version 6)
set(Qt_version ${Qt_version_major}.${Qt_version_minor}.${Qt_patch_version})
set(Qt_url "http://download.qt-project.org/${Qt_release_location}/qt/${Qt_version_major}.${Qt_version_minor}/${Qt_version}/qt-everywhere-opensource-src-${Qt_version}.tar.gz")
set(Qt_md5 "2edbe4d6c2eff33ef91732602f3518eb")
list(APPEND fletch_external_sources Qt)

# PROJ.4
set(PROJ4_version "4.8.0" )
set(PROJ4_url "http://download.osgeo.org/proj/proj-${PROJ4_version}.tar.gz" )
set(PROJ4_md5 "d815838c92a29179298c126effbb1537" )
list(APPEND fletch_external_sources PROJ4 )

# GeographicLib
set(GeographicLib_version "1.30" )
set(GeographicLib_url "http://downloads.sourceforge.net/geographiclib/distrib/GeographicLib-${GeographicLib_version}.tar.gz" )
set(GeographicLib_md5 "eadf39013bfef1f87387e7964a2adf02" )
list(APPEND fletch_external_sources GeographicLib )

# VTK
set(VTK_version 6.2)
set(VTK_url "http://www.vtk.org/files/release/${VTK_version}/VTK-${VTK_version}.0.zip")
set(VTK_md5 "2363432e25e6a2377e1c241cd2954f00")
list(APPEND fletch_external_sources VTK)

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
