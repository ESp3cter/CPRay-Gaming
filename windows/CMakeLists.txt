cmake_minimum_required(VERSION 3.14)
project(cpray_gaming LANGUAGES CXX)

set(BINARY_NAME "cpray_gaming")

cmake_policy(SET CMP0069 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0069 NEW)

# Flutter wrapper
add_subdirectory(flutter)
add_subdirectory(runner)
