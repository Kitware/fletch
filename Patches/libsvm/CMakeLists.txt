cmake_minimum_required (VERSION 2.8)
project( libsvm )

set(LIBSVM_VERSION_MAJOR 2)

set(LIBSVM_VERSION_MINOR 91)

set(LIBSVM_VERSION "${LIBSVM_VERSION_MAJOR}.${LIBSVM_VERSION_MINOR}")

# Make sure that on 64 bit linux we can link static libs into shared libs
if( (UNIX AND NOT APPLE) AND
      ( ("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU") OR
        ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel") ) AND
    (${CMAKE_SIZEOF_VOID_P} EQUAL 8) AND BUILD_SHARED_LIBS )

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

endif()

set( svm_source svm.h svm.cpp)

if( WIN32 )
  set( svm_source ${svm_source} svm.def )
endif(WIN32)

add_library( svm ${svm_source} )
set_target_properties(svm PROPERTIES
  VERSION      "${LIBSVM_VERSION}"
  SOVERSION    "${LIBSVM_VERSION}"
)

add_executable( svm-train svm-train.c )
target_link_libraries( svm-train svm )
install(TARGETS svm-train RUNTIME DESTINATION bin)

add_executable( svm-predict svm-predict.c )
target_link_libraries( svm-predict svm )
install(TARGETS svm-predict RUNTIME DESTINATION bin)

add_executable( svm-scale svm-scale.c )
target_link_libraries( svm-scale svm )
install(TARGETS svm-scale RUNTIME DESTINATION bin)

if( WIN32 )
  add_executable( svm-toy WIN32 svm-toy/windows/svm-toy.cpp )
  target_link_libraries( svm-toy svm )
  install(TARGETS svm-toy RUNTIME DESTINATION bin)
endif( WIN32 )

install(TARGETS svm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(FILES svm.h DESTINATION include )

install(DIRECTORY DESTINATION ${libsvm_PYTHON_SP})

INCLUDE(FindPythonInterp)
execute_process(
        COMMAND "${PYTHON_EXECUTABLE}" -c "from distutils import sysconfig; print(sysconfig.get_python_lib(prefix=''))"
        RESULT_VARIABLE _exitcode
        OUTPUT_VARIABLE python_site_packages OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT ${_exitcode} EQUAL 0)
    message(FATAL_ERROR "Python command to get version failed with error code: ${_exitcode}")
endif()
set(libsvm_PYTHON_SP "${python_site_packages}")
install(FILES python/svm.py python/svmutil.py DESTINATION ${libsvm_PYTHON_SP})

# Remove supurflous newlines (artifacts of print)
string(STRIP "${_python_version}" _python_version)

