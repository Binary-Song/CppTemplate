include(CMakeParseArguments)

#[[

InstallConanPackages( 
    <cwd             输出目录>
    [packages        包名1 包名2 ...]
    [bin_dir         动态库拷贝目的地]
)

调用 `conan install` 安装所有conan依赖。

cwd
        工作目录。存放conan生成的各种FindXXX.cmake文件

packages
        conan包的名称。例如opencv/4.5.2

bin_dir
        动态库拷贝目的地（绝对路径）。安装包后，会将所有的动态库拷贝到此路径。

例：

InstallConanPackages( 
    cwd                  "${CMAKE_SOURCE_DIR}/3rdparty"
    packages             "opencv/4.5.2"
    bin_dir              "${CMAKE_BINARY_DIR}/bin/${CMAKE_BUILD_TYPE}"
)

]] 
function(InstallConanPackages) 

    cmake_parse_arguments( 
        "arg"                               # prefix
        ""                                  # optional args
        "cwd;"                               # one value args
        "packages;bin_dir"                  # multi value args
        ${ARGN}
    )
     
    # 检查参数

    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "unrecognized argument(s): ${arg_UNPARSED_ARGUMENTS}")
    endif()
 
    if(NOT arg_cwd)
        message(FATAL_ERROR "cwd required")
    endif()

    if(NOT CMAKE_BUILD_TYPE)
        message(FATAL_ERROR "Set CMAKE_BUILD_TYPE first!")
    endif()

    # 生成conanfile.txt
    foreach(p ${arg_packages})
        set(packages_str "${packages_str}\n${p}")
    endforeach()
    
    if(arg_bin_dir) 
        file(WRITE "${arg_cwd}/conanfile.txt" "
[requires] 
${packages_str}
[generators]
cmake_find_package 
[imports]
bin, * -> ${arg_bin_dir}
        ") 
    else()
        file(WRITE "${arg_cwd}/conanfile.txt" "
[requires] 
${packages_str}
[generators]
cmake_find_package 
        ")
    endif()

    # 将cwd添加到CMAKE_MODULE_PATH里面
    set(CMAKE_MODULE_PATH "${arg_cwd};${CMAKE_MODULE_PATH}" PARENT_SCOPE)

    # 执行 conan install
    execute_process(
        COMMAND "conan" "install" "${arg_cwd}" "-s" "build_type=${CMAKE_BUILD_TYPE}"
        WORKING_DIRECTORY "${arg_cwd}"
        RESULT_VARIABLE process_result
        OUTPUT_QUIET
    )

    if(NOT ${process_result} EQUAL 0)
        message(FATAL_ERROR "Error occurred while installing conan dependencies. (returned: ${process_result})")
    endif()
 
    
endfunction()