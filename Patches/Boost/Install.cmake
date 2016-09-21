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

if(WIN32)
  message("Boost.Install: Installing runtime libraries")
  file(COPY ${Boost_BUILD_DIR}/stage/lib/
    DESTINATION ${Boost_INSTALL_DIR}/bin
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING PATTERN "*.dll"
  )
endif()

if(EXISTS ${Boost_INSTALL_DIR}/include/boost/python AND EXISTS ${Boost_SOURCE_DIR}/boost/python/raw_function.hpp)

  file( COPY ${Boost_SOURCE_DIR}/boost/python/raw_function.hpp
        DESTINATION ${Boost_INSTALL_DIR}/include/boost/python/ )

endif()

message("Done")
