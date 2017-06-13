#+
# Install fletch to the CMAKE_INSTALL_PREFIX directory
#

install(DIRECTORY ${fletch_BUILD_INSTALL_PREFIX}/ DESTINATION ${CMAKE_INSTALL_PREFIX})

# Also install the Config file so it can be found.
install(FILES ${fletch_CONFIG_OUTPUT} DESTINATION ${CMAKE_INSTALL_PREFIX})
