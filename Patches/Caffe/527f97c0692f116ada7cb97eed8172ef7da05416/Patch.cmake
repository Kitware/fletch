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

  file(COPY
    ${Caffe_patch}/caffe.proto
    DESTINATION
    ${Caffe_source}/src/caffe/proto/
    )

  file(COPY
    ${Caffe_patch}/net.cpp
    DESTINATION
    ${Caffe_source}/src/caffe/
    )

  file(COPY
    ${Caffe_patch}/upgrade_proto.cpp
    DESTINATION
    ${Caffe_source}/src/caffe/util/
    )

else()
  message(FATAL_ERROR "This caffe patch is only for windows")
endif()
