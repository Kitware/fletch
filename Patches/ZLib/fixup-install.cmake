# Make a copy of built libraries with Qt expected name

if(WIN32)
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib)
   execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib ${fletch_BUILD_INSTALL_PREFIX}/lib/zdll.lib)
  endif()
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib${CMAKE_DEBUG_POSTFIX}.lib)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib${CMAKE_DEBUG_POSTFIX}.lib ${fletch_BUILD_INSTALL_PREFIX}/lib/zdll${CMAKE_DEBUG_POSTFIX}.lib)
  endif()
elseif(NOT APPLE)
  # For Linux machines
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/libz.lib)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/libz.lib ${fletch_BUILD_INSTALL_PREFIX}/lib/libzlib.lib)
  endif()
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/libz${CMAKE_DEBUG_POSTFIX}.lib)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/libz${CMAKE_DEBUG_POSTFIX}.lib ${fletch_BUILD_INSTALL_PREFIX}/lib/libzlib${CMAKE_DEBUG_POSTFIX}.lib)
  endif()
else()
  # APPLE
  
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/libz.dylib)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/libz.dylib ${fletch_BUILD_INSTALL_PREFIX}/lib/libzlib.dylib)
  endif()
  if(EXISTS ${fletch_BUILD_INSTALL_PREFIX}/lib/libz${CMAKE_DEBUG_POSTFIX}.dylib)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${fletch_BUILD_INSTALL_PREFIX}/lib/libz${CMAKE_DEBUG_POSTFIX}.dylib ${fletch_BUILD_INSTALL_PREFIX}/lib/libzlib${CMAKE_DEBUG_POSTFIX}.dylib)
  endif()
endif()