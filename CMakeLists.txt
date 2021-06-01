cmake_minimum_required(VERSION 3.14)
project(___PROJECTNAME___)
 
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/3rdparty" "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/3rdparty")

# includes
include(AddTarget)
include(InstallConanPackages)
include(CppGlobalConfig)

# output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# config cpp
CppGlobalConfig(
    std         17 
    msvc_flags  /utf-8  /MDd
    msvc_defs   -D_USE_MATH_DEFINES
) 

# install conan dependencies and find packages
InstallConanPackages( 
    cwd                  "${CMAKE_SOURCE_DIR}/3rdparty"
    packages             "opencv/4.5.2"
    bin_dir              "${CMAKE_BINARY_DIR}/bin/${CMAKE_BUILD_TYPE}"
)

# add src
add_subdirectory("./src")