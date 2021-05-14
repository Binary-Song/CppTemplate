include(CMakeParseArguments)

#[[

InstallConanPackages(
    <conanfile.txt 所在的路径>
    <output             输出目录>
    [packages_to_find   包名1 包名2 ...]  
)

调用 `conan install` 安装所有conan依赖。
如果指定了packages_to_find列表，则会尝试用find_package(...)寻找列表中指定名称的包。
 
例：

InstallConanPackages(
    input                   ".."
    output                  "./3rdparty"
    packages_to_find        "fmt" "boost"
)

]] 
MACRO(InstallConanPackages input)
 
    set(args "${ARGV}")
    list(POP_FRONT args) 

    cmake_parse_arguments( 
        "arg"                               # prefix
        ""                                  # optional args
        "output;"                           # one value args
        "packages_to_find"                  # multi value args
        ${args}
    )
    
    

    # arg checking 

    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "unrecognized argument(s): ${arg_UNPARSED_ARGUMENTS}")
    endif()
 
    if(NOT arg_output)
        message(FATAL_ERROR "output directory required")
    endif()

    # Add to CMAKE_MODULE_PATH
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${arg_output}" PARENT_SCOPE)

    execute_process(
        COMMAND "conan" "install" "${input}"  "-s" "build_type=${CMAKE_BUILD_TYPE}"
        WORKING_DIRECTORY "${arg_output}"
        RESULT_VARIABLE process_result
        OUTPUT_QUIET
    ) 

    if(NOT ${process_result} EQUAL 0)
        message(FATAL_ERROR "error occurred while installing conan dependencies (returned: ${process_result})")
    endif()

    foreach(_pname ${arg_packages_to_find})
        find_package(${_pname} MODULE )
    endforeach()
     
ENDMACRO()