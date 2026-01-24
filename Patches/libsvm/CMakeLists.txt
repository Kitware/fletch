cmake_minimum_required(VERSION 3.16.0)
project(libsvm VERSION 3.11 LANGUAGES CXX)

# Build shared library from svm.cpp
add_library(svm SHARED svm.cpp)

# Set library properties
set_target_properties(svm PROPERTIES
  PUBLIC_HEADER svm.h
  VERSION ${PROJECT_VERSION}
  SOVERSION 2
)

# Platform-specific settings
if(MSVC)
  # Export all symbols on Windows
  set_target_properties(svm PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
  target_compile_definitions(svm PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

# Link math library on Unix
if(UNIX)
  target_link_libraries(svm PRIVATE m)
endif()

# Install targets
install(TARGETS svm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION include
)
