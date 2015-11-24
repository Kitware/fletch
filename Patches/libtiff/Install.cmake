# Install rules for Libtiff on windows

# lib
file(GLOB libtiff_libraries "${BUILD_DIR}/libtiff/*.lib")
file(COPY
  ${libtiff_libraries}
  DESTINATION ${INSTALL_DIR}/lib
)

# bin
file(GLOB libtiff_dlls "${BUILD_DIR}/libtiff/*.dll")
file(GLOB libtiff_exes "${BUILD_DIR}/tools/*.exe")
file(COPY
  ${libtiff_dlls}
  ${libtiff_exes}
  DESTINATION ${INSTALL_DIR}/bin
)

# include
set(libtiff_headers
  ${BUILD_DIR}/libtiff/tiff.h
  ${BUILD_DIR}/libtiff/tiffconf.h
  ${BUILD_DIR}/libtiff/tiffio.h
  ${BUILD_DIR}/libtiff/tiffvers.h
)
file(COPY
  ${libtiff_headers}
  DESTINATION ${INSTALL_DIR}/include
)
