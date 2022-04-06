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

message("Done")
