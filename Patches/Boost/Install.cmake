message("Boost.Install: Installing headers")
file(COPY ${Boost_BUILD_DIR}/boost
  DESTINATION ${Boost_INSTALL_DIR}/include
  USE_SOURCE_PERMISSIONS
  )

message("Boost.Install: Installing link libraries")
foreach(SUFFIX lib so a dylib)
  file(COPY ${Boost_BUILD_DIR}/stage/lib/
    DESTINATION ${Boost_INSTALL_DIR}/lib
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING PATTERN "*.${SUFFIX}*"
  )
endforeach()

if (fletch_BUILD_WITH_PYTHON)
  file(COPY ${Boost_source}/boost/python/raw_function.hpp
    DESTINATION ${Boost_INSTALL_DIR}/include/boost/python
    USE_SOURCE_PERMISSIONS
    )
  foreach(pysuffix ${PYTHON_VERSION_MAJOR}
                   ${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR})
    if(NOT WIN32
       AND EXISTS ${Boost_INSTALL_DIR}/lib/libboost_python${pysuffix}.so)
      execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
        ${Boost_INSTALL_DIR}/lib/libboost_python${pysuffix}.so
        ${Boost_INSTALL_DIR}/lib/libboost_python.so)
    endif()
  endforeach()
endif()

if(WIN32)
  message("Boost.Install: Installing runtime libraries")
  file(COPY ${Boost_BUILD_DIR}/stage/lib/
    DESTINATION ${Boost_INSTALL_DIR}/bin
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING PATTERN "*.dll"
  )
endif()

message("Done")
