# This patch is targeted at non-windows systems
if(WIN32)
  message(FATAL_ERROR "This caffe patch is only for non-windows")
endif()

# Fixes issue where __inbinary and __insource lists were empty.
file(COPY
  ${Caffe_patch}/ConfigGen.cmake
  DESTINATION
  ${Caffe_source}/cmake/
  )

file(COPY
  ${Caffe_patch}/cmake/Cuda.cmake
  DESTINATION
  ${Caffe_source}/cmake/
  )

file(COPY
  ${Caffe_patch}/cmake/Misc.cmake
  DESTINATION
  ${Caffe_source}/cmake/
  )

file(COPY
  ${Caffe_patch}/cmake/Dependencies.cmake
  DESTINATION
  ${Caffe_source}/cmake/
  )
