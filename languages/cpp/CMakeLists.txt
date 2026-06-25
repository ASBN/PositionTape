cmake_minimum_required(VERSION 3.16)
project(position_tape_cpp LANGUAGES CXX)

enable_testing()

add_library(position_tape INTERFACE)
target_include_directories(position_tape INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_compile_features(position_tape INTERFACE cxx_std_17)

add_executable(position_tape_tests tests/position_tape_tests.cpp)
target_link_libraries(position_tape_tests PRIVATE position_tape)
add_test(NAME position_tape_tests COMMAND position_tape_tests)

add_executable(position_tape_basic examples/basic.cpp)
target_link_libraries(position_tape_basic PRIVATE position_tape)
