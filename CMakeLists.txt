cmake_minimum_required(VERSION 3.14)
project(___PROJECTNAME___)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/3rdparty" "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/3rdparty")

# includes
include(AddTarget)
include(InstallConanPackages)
include(CppGlobalConfig)

# config cpp
CppGlobalConfig(
    std         17 
    msvc_flags  /utf-8  /MDd
    msvc_defs   -D_USE_MATH_DEFINES
) 

# install conan dependencies and find packages
InstallConanPackages(
    "${CMAKE_CURRENT_LIST_DIR}"
    output                  "${CMAKE_CURRENT_LIST_DIR}/3rdparty"
    packages_to_find        "fmt" 
)
