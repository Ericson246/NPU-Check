cmake_minimum_required(VERSION 3.18.1)

project(neural_gauge_native VERSION 1.0.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add llama.cpp library path
# NOTE: You need to clone llama.cpp into this directory
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp")

# Include llama.cpp headers
include_directories(
    ${LLAMA_CPP_DIR}
    ${LLAMA_CPP_DIR}/common
    ${LLAMA_CPP_DIR}/include
)

# Add llama.cpp source files
file(GLOB LLAMA_SOURCES
    "${LLAMA_CPP_DIR}/src/*.cpp"
    "${LLAMA_CPP_DIR}/common/*.cpp"
)

# Compiler flags for optimization
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -DNDEBUG")

# Platform-specific flags
if(ANDROID)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
endif()

# Create native library
add_library(neural_gauge_native SHARED
    native_lib.cpp
    ${LLAMA_SOURCES}
)

# Link libraries
target_link_libraries(neural_gauge_native
    android
    log
)

# Enable NEON on ARM
if(ANDROID_ABI STREQUAL "arm64-v8a")
    target_compile_options(neural_gauge_native PRIVATE -mfpu=neon)
endif()
