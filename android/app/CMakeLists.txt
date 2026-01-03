cmake_minimum_required(VERSION 3.18.1)

project(neural_gauge_native VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Force Enable NEON for ARM architectures
if(ANDROID_ABI STREQUAL "armeabi-v7a")
    add_compile_options(-mfpu=neon -mfloat-abi=softfp -funsafe-math-optimizations)
    add_definitions(-D__ARM_NEON)
endif()

if(ANDROID_ABI STREQUAL "armeabi-v7a" OR ANDROID_ABI STREQUAL "arm64-v8a")
    set(LLAMA_NEON ON CACHE BOOL "Enable NEON" FORCE)
endif()

# Disable llama.cpp options we don't need for a mobile library
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "Build tests")
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "Build examples")
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "Build server")

# Add llama.cpp as a subdirectory. This will configure and build it.
add_subdirectory(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/llama.cpp"
    "${CMAKE_BINARY_DIR}/llama_build"
)

# Create our native library
add_library(neural_gauge_native SHARED
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/native_lib.cpp"
)

# Link against the llama library and other Android libraries
target_link_libraries(neural_gauge_native
    llama
    android
    log
)

# Include llama.cpp headers so native_lib.cpp can find them
target_include_directories(neural_gauge_native PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/llama.cpp"
)
