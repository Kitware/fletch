
if( EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_d_i.lib)
  FILE (RENAME
    ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_d_i.lib
    ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_i.lib
    )
endif()

if( EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_d.lib)
  FILE (RENAME
    ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff_d.lib
    ${fletch_BUILD_INSTALL_PREFIX}/lib/geotiff.lib
    )
endif()

if( EXISTS ${fletch_BUILD_INSTALL_PREFIX}/bin/geotiff_d.dll)
  FILE (RENAME
    ${fletch_BUILD_INSTALL_PREFIX}/bin/geotiff_d.dll
    ${fletch_BUILD_INSTALL_PREFIX}/bin/geotiff.dll)
endif()
