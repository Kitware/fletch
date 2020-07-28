
message("Patching yaml in ${YAMLcpp_source}")

file(COPY
  ${YAMLcpp_patch}/CMakeLists.txt
  DESTINATION ${YAMLcpp_source}/
)

file(COPY
  ${YAMLcpp_patch}/src/node_data.cpp
  DESTINATION ${YAMLcpp_source}/src
)

file(COPY
  ${YAMLcpp_patch}/include/yaml-cpp/node/detail/iterator.h
  DESTINATION ${YAMLcpp_source}/include/yaml-cpp/node/detail/
)
