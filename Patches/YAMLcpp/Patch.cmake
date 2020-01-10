
message("Patching yaml in ${YAMLcpp_source}")

file(COPY
  ${YAMLcpp_patch}/CMakeLists.txt
  DESTINATION ${YAMLcpp_source}/
)

file(COPY
  ${YAMLcpp_patch}/src/node_data.cpp
  DESTINATION ${YAMLcpp_source}/src
)
