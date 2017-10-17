if(NOT HAVE_PYTHON)
  message(STATUS "Python interface is disabled or not all required dependencies found. Building without it...")
  return()
endif()

include_directories(${PYTHON_INCLUDE_DIRS} ${NUMPY_INCLUDE_DIR} ${Boost_INCLUDE_DIRS})
file(GLOB_RECURSE python_srcs ${PROJECT_SOURCE_DIR}/python/*.cpp)

add_library(py${tgtName} SHARED ${python_srcs})
target_link_libraries(py${tgtName} ${Caffe_LINK} ${PYTHON_LIBRARIES} ${Boost_LIBRARIES})
set_target_properties(py${tgtName} PROPERTIES PREFIX "" OUTPUT_NAME "_${tgtName}")
caffe_default_properties(py${tgtName})

if(UNIX OR APPLE)
    set(__linkname "${PROJECT_SOURCE_DIR}/python/${tgtName}/_${tgtName}.so")
    add_custom_command(TARGET py${tgtName} POST_BUILD
                       COMMAND ln -sf $<TARGET_LINKER_FILE:py${tgtName}> "${__linkname}"
                       COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_SOURCE_DIR}/python/${tgtName}/proto
                       COMMAND touch ${PROJECT_SOURCE_DIR}/python/${tgtName}/proto/__init__.py
                       COMMAND cp ${proto_gen_folder}/*.py ${PROJECT_SOURCE_DIR}/python/${tgtName}/proto/
                       COMMENT "Creating symlink ${__linkname} -> ${PROJECT_BINARY_DIR}/lib/_${tgtName}${Caffe_POSTFIX}.so")
endif()

# ---[ Install
# scripts
file(GLOB python_files *.py requirements.txt)
install(FILES ${python_files} DESTINATION python)

# module
install(DIRECTORY ${tgtName}
    DESTINATION python
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "ilsvrc_2012_mean.npy"
    PATTERN "test" EXCLUDE
    )

# _caffe.so
install(TARGETS py${tgtName}  DESTINATION python/${tgtName})

