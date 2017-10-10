
if( EXISTS ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff_d_i.lib)
  FILE (RENAME
    ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff_d_i.lib
    ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff_i.lib
    )
endif()

if( EXISTS ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff_d.lib)
  FILE (RENAME
    ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff_d.lib
    ${vision-tpl_BUILD_INSTALL_PREFIX}/lib/geotiff.lib
    )
endif()

if( EXISTS ${vision-tpl_BUILD_INSTALL_PREFIX}/bin/geotiff_d.dll)
  FILE (RENAME
    ${vision-tpl_BUILD_INSTALL_PREFIX}/bin/geotiff_d.dll
    ${vision-tpl_BUILD_INSTALL_PREFIX}/bin/geotiff.dll)
endif()
