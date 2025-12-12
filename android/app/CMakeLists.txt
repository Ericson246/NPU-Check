cmake_minimum_required(VERSION 3.18.1)

project(neural_gauge_native VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(ANDROID_ABI STREQUAL "armeabi-v7a")
    message(STATUS "Skipping armeabi-v7a build")
    return()
endif()

# Configure llama.cpp options before adding subdirectory
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)

# Add llama.cpp as subdirectory
# The path is relative to this CMakeLists.txt (android/app)
add_subdirectory(src/main/cpp/llama.cpp)

# Optimization flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -DNDEBUG")

if(ANDROID)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    if(ANDROID_ABI STREQUAL "armeabi-v7a")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -mfloat-abi=softfp")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfpu=neon -mfloat-abi=softfp")
    endif()
endif()

# Create our native library
add_library(neural_gauge_native SHARED
    src/main/cpp/native_lib.cpp
)

# Link against llama and android libs
# linking 'llama' should automatically handle include directories
target_link_libraries(neural_gauge_native
    llama
    android
    log
)

# ARM specific flags - ONLY for 32-bit ARM
if(ANDROID_ABI STREQUAL "armeabi-v7a")
    target_compile_options(neural_gauge_native PRIVATE -mfpu=neon -mfloat-abi=softfp)
endif()
