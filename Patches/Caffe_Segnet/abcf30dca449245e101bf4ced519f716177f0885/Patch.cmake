# This patch is targeted at non-windows systems
if(WIN32)
  message(FATAL_ERROR "This caffe patch is only for non-windows")
else()
  file(COPY ${Caffe_Segnet_patch}/cmake/Dependencies.cmake
       DESTINATION ${Caffe_Segnet_source}/cmake/ )

# These files use the fork name in targets and installation locations

  # Fixes issue where __inbinary and __insource lists were empty.
  file(COPY ${Caffe_Segnet_patch}/cmake/ConfigGen.cmake
       DESTINATION ${Caffe_Segnet_source}/cmake/ )

  file(COPY ${Caffe_Segnet_patch}/cmake/Targets.cmake
       DESTINATION ${Caffe_Segnet_source}/cmake/ )

  file(COPY ${Caffe_Segnet_patch}/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/ )

  file(COPY ${Caffe_Segnet_patch}/docs/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/docs/ )

  file(COPY ${Caffe_Segnet_patch}/examples/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/examples/ )

  file(COPY ${Caffe_Segnet_patch}/matlab/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/matlab/ )

  file(COPY ${Caffe_Segnet_patch}/python/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/python/ )

  file(COPY ${Caffe_Segnet_patch}/src/caffe/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/src/caffe/ )

  file(COPY ${Caffe_Segnet_patch}/src/gtest/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/src/gtest/ )

  file(COPY ${Caffe_Segnet_patch}/tools/CMakeLists.txt
       DESTINATION ${Caffe_Segnet_source}/tools/ )

  
endif()
