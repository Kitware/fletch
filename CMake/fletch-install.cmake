#+
# Install fletch to the CMAKE_INSTALL_PREFIX directory
#

install(DIRECTORY ${fletch_BUILD_INSTALL_PREFIX}/ DESTINATION ${CMAKE_INSTALL_PREFIX})


set(fletch_INSTALL_BUILD_DIR ${CMAKE_INSTALL_PREFIX})
set(fletch_CONFIG_OUTPUT ${CMAKE_INSTALL_PREFIX}/lib/cmake/fletch/fletchConfig.cmake )
# Also install the Config file so it can be found.


# We need to configure the 'install' version of the config into an 'export' directory, then install it.
# The export directory was chosen because it make sense semantically as is not likely to confuse users.
#
configure_file(
  ${fletch_CONFIG_INPUT} ${fletch_BUILD_PREFIX}/config/export/fletchConfig_install.cmake
  @ONLY
  )

install(
  FILES
  ${fletch_BUILD_PREFIX}/config/export/fletchConfig_install.cmake
  DESTINATION
  ${CMAKE_INSTALL_PREFIX}/lib/cmake/fletch/
  RENAME
  fletchConfig.cmake
  )

install(
  FILES
  ${fletch_BUILD_DIR}/fletchConfig-version.cmake
  DESTINATION
  ${CMAKE_INSTALL_PREFIX}/lib/cmake/fletch/
  )
