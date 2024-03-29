cmake_minimum_required(VERSION 3.4.1)

if (NOT DEFINED MODULE_NAME)
    message(FATAL_ERROR "MODULE_NAME is not set")
else ()
    project(${MODULE_NAME})
endif ()

add_definitions(-DRIRU_MODULE)
add_definitions(-DRIRU_MODULE_API_VERSION=${RIRU_MODULE_API_VERSION})
add_definitions(-DRIRU_MODULE_VERSION=${RIRU_MODULE_VERSION})
add_definitions(-DRIRU_MODULE_VERSION_NAME="${RIRU_MODULE_VERSION_NAME}")
add_definitions(-DRIRU_MODULE_MIN_API_VERSION=${RIRU_MODULE_MIN_API_VERSION})

if (RIRU_MODULE_MIN_API_VERSION LESS 24)
    add_definitions(-DRIRU_MODULE_LEGACY_INIT)
endif ()

message("Build type: ${CMAKE_BUILD_TYPE}")

set(CMAKE_CXX_STANDARD 11)

set(LINKER_FLAGS "-ffixed-x18 -Wl,--hash-style=both")
set(C_FLAGS "-Werror=format -fdata-sections -ffunction-sections")
set(CMAKE_ANDROID_STL_TYPE "none")
set(CXX_FLAGS "${CXX_FLAGS} -fno-exceptions -fno-rtti")

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(C_FLAGS "${C_FLAGS} -Os -fvisibility=hidden -fvisibility-inlines-hidden")
    set(LINKER_FLAGS "${LINKER_FLAGS} -Wl,-exclude-libs,ALL -Wl,--gc-sections -Wl,--strip-all")
else ()
    set(C_FLAGS "${C_FLAGS} -O0")
endif ()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${C_FLAGS} ${CXX_FLAGS}")

set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${LINKER_FLAGS}")

find_package(riru REQUIRED CONFIG)
find_package(nativehelper REQUIRED CONFIG)

add_library(${MODULE_NAME} SHARED main.cpp)
add_library(${MODULE_NAME}-tensor SHARED tensor.cpp)
target_link_libraries(${MODULE_NAME} log riru::riru nativehelper::nativehelper_header_only)
set_target_properties(${MODULE_NAME} PROPERTIES LINK_FLAGS_RELEASE -s)
target_link_libraries(${MODULE_NAME}-tensor log riru::riru nativehelper::nativehelper_header_only)
set_target_properties(${MODULE_NAME}-tensor PROPERTIES LINK_FLAGS_RELEASE -s)
