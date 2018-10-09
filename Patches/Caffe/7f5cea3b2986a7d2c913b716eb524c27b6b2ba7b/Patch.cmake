# This patch is targeted at non-windows systems
if(WIN32)
  message(FATAL_ERROR "This caffe patch is only for non-windows")
else()
  file(COPY
    ${Caffe_patch}/Dependencies.cmake
    DESTINATION
    ${Caffe_source}/cmake/
    )

  # Fixes issue where __inbinary and __insource lists were empty.
  file(COPY
    ${Caffe_patch}/ConfigGen.cmake
    DESTINATION
    ${Caffe_source}/cmake/
    )
endif()

file(COPY
  ${Caffe_patch}/cmake/Cuda.cmake
  DESTINATION
  ${Caffe_source}/cmake/
  )
