#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake to fix a minor ffmpeg find flag
#-

message("Patching VXL in ${VXL_source}")

file(COPY ${VXL_patch}/FindFFMPEG.cmake
  DESTINATION ${VXL_source}/config/cmake/Modules/NewCMake/
)
