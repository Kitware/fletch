if(WIN32)
  file(COPY
    ${Caffe_patch}/WindowsDownloadPrebuiltDependencies.cmake
    DESTINATION
    ${Caffe_source}/cmake/
    )
  file(COPY
    ${Caffe_patch}/FindBoost.cmake
    DESTINATION
    ${Caffe_source}/cmake/modules/
    )
  file(COPY
    ${Caffe_patch}/FindGFlags.cmake
    DESTINATION
    ${Caffe_source}/cmake/modules/
    )

  file(COPY
    ${Caffe_patch}/FindGLog.cmake
    DESTINATION
    ${Caffe_source}/cmake/modules/
    )

  file(COPY
    ${Caffe_patch}/CMakeLists.txt
    DESTINATION
    ${Caffe_source}/
    )
  file(COPY
    ${Caffe_patch}/cmake/Cuda.cmake
    DESTINATION
    ${Caffe_source}/cmake/
    )

else()
  message(FATAL_ERROR "This caffe patch is only for windows")
endif()
