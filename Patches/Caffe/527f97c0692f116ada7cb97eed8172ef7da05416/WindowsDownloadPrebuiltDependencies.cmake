set(DEPENDENCIES_URL_1800_27 "https://github.com/willyd/caffe-builder/releases/download/v1.1.0/libraries_v120_x64_py27_1.1.0.tar.bz2")
set(DEPENDENCIES_SHA_1800_27 "ba833d86d19b162a04d68b09b06df5e0dad947d4")
set(DEPENDENCIES_URL_1900_27 "https://github.com/willyd/caffe-builder/releases/download/v1.1.0/libraries_v140_x64_py27_1.1.0.tar.bz2")
set(DEPENDENCIES_SHA_1900_27 "17eecb095bd3b0774a87a38624a77ce35e497cd2")
set(DEPENDENCIES_URL_1900_35 "https://github.com/willyd/caffe-builder/releases/download/v1.1.0/libraries_v140_x64_py35_1.1.0.tar.bz2")
set(DEPENDENCIES_SHA_1900_35 "f060403fd1a7448d866d27c0e5b7dced39c0a607")
set(MAX_MSVC_VERSION 1900) # If later versions of visual studio are added in the future, update dependency URL list and this number

caffe_option(USE_PREBUILT_DEPENDENCIES "Download and use the prebuilt dependencies" ON IF MSVC)
if(MSVC)
  set(CAFFE_DEPENDENCIES_DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "Download directory for prebuilt dependencies")
  set(CAFFE_DEPENDENCIES_DIR ${CMAKE_CURRENT_BINARY_DIR})
endif()
if(USE_PREBUILT_DEPENDENCIES)
    # Determine the python version
    if(BUILD_python)
        if(NOT PYTHONINTERP_FOUND)
            if(NOT "${python_version}" VERSION_LESS "3.0.0")
                find_package(PythonInterp 3.5)
            else()
                find_package(PythonInterp 2.7)
            endif()
        endif()
        set(_pyver ${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR})
    else()
        message(STATUS "Building without python. Prebuilt dependencies will default to Python 2.7")
        set(_pyver 27)
    endif()
    if(${MSVC_VERSION} GREATER ${MAX_MSVC_VERSION}) # Use the latest version we have
        set(CAPPED_MSVC_VERSION ${MAX_MSVC_VERSION})
  else()
        set(CAPPED_MSVC_VERSION ${MSVC_VERSION})
    endif()  
    if(NOT DEFINED DEPENDENCIES_URL_${CAPPED_MSVC_VERSION}_${_pyver})
        message(FATAL_ERROR "Could not find url for MSVC version = ${CAPPED_MSVC_VERSION} and Python version = ${_pyver}.")
    endif()
    # set the dependencies URL and SHA1
    set(DEPENDENCIES_URL ${DEPENDENCIES_URL_${CAPPED_MSVC_VERSION}_${_pyver}})
    set(DEPENDENCIES_SHA ${DEPENDENCIES_SHA_${CAPPED_MSVC_VERSION}_${_pyver}})
    # create the download directory if it does not exist
    if(NOT EXISTS ${CAFFE_DEPENDENCIES_DOWNLOAD_DIR})
      file(MAKE_DIRECTORY ${CAFFE_DEPENDENCIES_DOWNLOAD_DIR})
    endif()
    # download and extract the file if it does not exist or if does not match the sha1
    get_filename_component(_download_filename ${DEPENDENCIES_URL} NAME)
    set(_download_path ${CAFFE_DEPENDENCIES_DOWNLOAD_DIR}/${_download_filename})
    set(_download_file 1)
    if(EXISTS ${_download_path})
        file(SHA1 ${_download_path} _file_sha)
        if("${_file_sha}" STREQUAL "${DEPENDENCIES_SHA}")
            set(_download_file 0)
        else()
            set(_download_file 1)
            message(STATUS "Removing file because sha1 does not match.")
            file(REMOVE ${_download_path})
        endif()
    endif()
    if(_download_file)
        message(STATUS "Downloading file dependencies")
        file(DOWNLOAD "${DEPENDENCIES_URL}"
                      "${_download_path}"
                      EXPECTED_HASH SHA1=${DEPENDENCIES_SHA}
                      SHOW_PROGRESS
                      )
        if(EXISTS ${CAFFE_DEPENDENCIES_DIR}/libraries)
            file(REMOVE_RECURSE ${CAFFE_DEPENDENCIES_DIR}/libraries)
        endif()
    endif()
    if(EXISTS ${_download_path} AND NOT EXISTS ${CAFFE_DEPENDENCIES_DIR}/libraries)
        message(STATUS "Extracting dependencies")
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xjf ${_download_path}
                        WORKING_DIRECTORY ${CAFFE_DEPENDENCIES_DIR}
        )
    endif()
    if(EXISTS ${CAFFE_DEPENDENCIES_DIR}/libraries/caffe-builder-config.cmake) # Sanity check
    file(COPY ${CAFFE_DEPENDENCIES_DIR}/libraries/ DESTINATION ${CMAKE_INSTALL_PREFIX} # We need to move the prereqs to the proper directory, except dependencies handled by fletch
            PATTERN "*opencv*" EXCLUDE
        PATTERN "*boost*" EXCLUDE
        PATTERN "*hdf5*" EXCLUDE
        PATTERN "H5*" EXCLUDE
        PATTERN "glog*" EXCLUDE
        PATTERN "gflags*" EXCLUDE
    )
    if(EXISTS ${CAFFE_DEPENDENCIES_DIR}/libraries/lib/libopenblas.dll.a AND NOT EXISTS ${CMAKE_INSTALL_PREFIX}/lib/libopenblas.lib)
          file(RENAME ${CAFFE_DEPENDENCIES_DIR}/libraries/lib/libopenblas.dll.a ${CMAKE_INSTALL_PREFIX}/lib/libopenblas.lib) # Same file type, but needs to be .lib for cmake
        endif()
    file (REMOVE_RECURSE ${CAFFE_DEPENDENCIES_DIR}/libraries/) # Clean up

    # BOOST config
    set(BOOST_ROOT ${CMAKE_INSTALL_PREFIX} CACHE PATH "")
    set(BOOST_INCLUDEDIR ${BOOST_ROOT}/include CACHE PATH "")
    set(BOOST_LIBRARYDIR ${BOOST_ROOT}/lib CACHE PATH "")
    set(Boost_LIBRARY_DIR_RELEASE ${BOOST_ROOT}/lib CACHE PATH "")
    set(Boost_LIBRARY_DIR_DEBUG ${BOOST_ROOT}/lib CACHE PATH "")
    set(Boost_USE_MULTITHREADED ON CACHE BOOL "")
    set(Boost_USE_STATIC_LIBS ON CACHE BOOL "")
    set(Boost_USE_STATIC_RUNTIME OFF CACHE BOOL "")


    # GFLAGS config
    set(GFLAGS_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(gflags_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")
    set(GFlags_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")
    set(Gflags_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")
    get_filename_component(GFLAGS_ROOT_DIR ${GFlags_DIR} DIRECTORY)
    


    # GLOG config
    set(GLOG_DIR ${CMAKE_INSTALL_PREFIX}/lib/cmake/glog CACHE PATH "")
    set(glog_DIR ${CMAKE_INSTALL_PREFIX}/lib/cmake/glog CACHE PATH "")
    set(Glog_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")


    # HDF5 config
    set(HDF5_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(hdf5_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(HDF5_ROOT_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
        find_package(HDF5 COMPONENTS C HL REQUIRED)


    # LEVELDB config
    set(LEVELDB_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(leveldb_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")
    set(LevelDB_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")


    # LMDB config
    set(LMDB_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(lmdb_DIR ${CMAKE_INSTALL_PREFIX}/cmake  CACHE PATH "")


    # OPENBLAS config
    set(OPENBLAS_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include CACHE PATH "")
    set(openblas_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include CACHE PATH "")
    set(OpenBLAS_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include CACHE PATH "")
    set(OPENBLAS_LIB ${CMAKE_INSTALL_PREFIX}/lib/libopenblas.dll.a CACHE FILEPATH "")
    set(openblas_LIB ${CMAKE_INSTALL_PREFIX}/lib/libopenblas.dll.a CACHE FILEPATH "")
    set(OpenBLAS_LIB ${CMAKE_INSTALL_PREFIX}/lib/libopenblas.dll.a CACHE FILEPATH "")


    # OPENCV config
    set(OPENCV_DIR ${CMAKE_INSTALL_PREFIX}  CACHE PATH "")
    set(opencv_DIR ${CMAKE_INSTALL_PREFIX}  CACHE PATH "")
    set(OpenCV_DIR ${CMAKE_INSTALL_PREFIX}  CACHE PATH "")
    set(OpenCV_STATIC OFF CACHE BOOL "")


    # PROTOBUF config
    set(PROTOBUF_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(protobuf_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(Protobuf_DIR ${CMAKE_INSTALL_PREFIX}/cmake CACHE PATH "")
    set(protobuf_MODULE_COMPATIBLE ON CACHE BOOL "")


    # SNAPPY config
    set(SNAPPY_DIR ${CMAKE_INSTALL_PREFIX}/cmake)
    set(snappy_DIR ${CMAKE_INSTALL_PREFIX}/cmake)
    set(Snappy_DIR ${CAFFE_DEPENDENCIES_DIR}/libraries/cmake)


    # ZLIB config
    set(ZLIB_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include CACHE PATH "")
    set(ZLIB_LIBRARY_DEBUG  ${CMAKE_INSTALL_PREFIX}/lib/zlib.lib CACHE FILEPATH "")
    set(ZLIB_LIBRARY_RELEASE  ${CMAKE_INSTALL_PREFIX}/lib/zlib.lib CACHE FILEPATH "")

        # Generate leveldb files so we can get rid of some hard coding
        find_package(Boost 1.46 REQUIRED date_time filesystem system)

        file(WRITE ${CMAKE_INSTALL_PREFIX}/cmake/leveldb-targets-debug.cmake
           "#----------------------------------------------------------------\n"
           "# Generated CMake target import file for configuration 'Debug'.  \n"
           "#----------------------------------------------------------------\n"
           "# Commands may need to know the format version.\n"
           "set(CMAKE_IMPORT_FILE_VERSION 1)\n"
           "# Import target 'leveldb' for configuration 'Debug'\n"
           "set_property(TARGET leveldb APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)\n"
           "set_target_properties(leveldb PROPERTIES\n"
           "  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG \"CXX\"\n"
           "  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG \"${Boost_DATE_TIME_LIBRARY_DEBUG};${Boost_FILESYSTEM_LIBRARY_DEBUG};${Boost_SYSTEM_LIBRARY_DEBUG}\"\n"
           "  IMPORTED_LOCATION_DEBUG \"${CMAKE_INSTALL_PREFIX}/lib/leveldbd.lib\"\n"
           "  )\n"
           "list(APPEND _IMPORT_CHECK_TARGETS leveldb )\n"
           "list(APPEND _IMPORT_CHECK_FILES_FOR_leveldb \"${CMAKE_INSTALL_PREFIX}/lib/leveldbd.lib\" )\n"
           "# Commands beyond this point should not need to know the version.\n"
           "set(CMAKE_IMPORT_FILE_VERSION)"
        )

        # They use a lot of hard coding and reliance on extracted files that need to be patched over.
        file(WRITE ${CMAKE_INSTALL_PREFIX}/cmake/leveldb-targets-release.cmake
          "#---------------------------------------------------------------- \n" 
           "# Generated CMake target import file for configuration 'Release'. \n"
           "#---------------------------------------------------------------- \n"
           "# Commands may need to know the format version. \n"
           "set(CMAKE_IMPORT_FILE_VERSION 1) \n"
           "# Import target 'leveldb' for configuration 'Release' \n"
           "set_property(TARGET leveldb APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE) \n"
           "set_target_properties(leveldb PROPERTIES \n"
           "  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE \"CXX\" \n"
           "  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE \"${Boost_DATE_TIME_LIBRARY_RELEASE};${Boost_FILESYSTEM_LIBRARY_RELEASE};${Boost_SYSTEM_LIBRARY_RELEASE}\"\n"
           "  IMPORTED_LOCATION_RELEASE \"${CMAKE_INSTALL_PREFIX}/lib/leveldb.lib\" \n"
           "  ) \n"
           "list(APPEND _IMPORT_CHECK_TARGETS leveldb ) \n"
           "list(APPEND _IMPORT_CHECK_FILES_FOR_leveldb \"${CMAKE_INSTALL_PREFIX}/lib/leveldb.lib\" ) \n"
           "# Commands beyond this point should not need to know the version. \n"
           "set(CMAKE_IMPORT_FILE_VERSION) "
        )
    else()
        message(FATAL_ERROR "Something went wrong while dowloading dependencies could not open caffe-builder-config.cmake")
    endif()
endif()

