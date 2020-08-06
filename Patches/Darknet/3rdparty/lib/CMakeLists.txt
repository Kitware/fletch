
if("${Darknet_PLATFORM}" MATCHES "(x64|ARM64)")
  add_subdirectory( x64 )
else()
  add_subdirectory( x86 )
endif()
