#+
# This file is called as CMake -P script for the patch step of
# External_libjpeg-turbo.cmake libjpeg-turbo_patch and libjpeg-turbo_source are defined on the command
# line along with the call.
#-
# The purpose of this is to add CMake build to libsvm
message("Patching libjpeg-turbo ${libjpeg-turbo_patch} AND ${libjpeg-turbo_source}")

if (WIN32)
  file(COPY
    ${libjpeg-turbo_patch}/simd/CMakeLists.txt
    DESTINATION ${libjpeg-turbo_source}/simd/
    )
endif()

# Patch config.guess for arm boards.
file(COPY
  ${libjpeg-turbo_patch}/config.guess
  DESTINATION ${libjpeg-turbo_source}/
  )
