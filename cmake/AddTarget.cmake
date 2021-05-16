include(CMakeParseArguments)
#[[   

AddTarget(
    [exe]       
    [verbose]
    <name      目标名>
    [src       源文件1 源文件2 ...]
    [includes  包含路径1 包含路径2 ...] 
    [libs      链接目标1 链接目标2 ...]
    [depends   依赖模块1 依赖模块2 ...]
    [bin_dir   动态库路径]
)

创建一个目标。

exe
    `exe`选项表示要生成可执行文件，没有该选项表示要生成静态库。

verbose
    显示目标各种信息。

depends
    依赖模块 X 表示在目标的include目录里面加上 X_INCLUDE_DIRS，链接库里面加上 X_LIBRARIES。

bin_dir
    如果bin_dir被指定，且目标是可执行文件，则会在编译后将bin_dir目录下的文件拷贝到可执行文件目录，便于可执行文件找到动态库。

例：
    AddTarget(
        exe
        name        MyTarget
        depends     opencv
        bin_dir     bin
    )
]] 
function(AddTarget)

    include(SimplePrint)
    

    cmake_parse_arguments(
        "arg"                        # prefix
        "exe;verbose"                        # optional args
        "name;bin_dir"                       # one value args
        "libs;includes;src;depends"  # multi value args
        ${ARGN}
    )
    if(arg_UNPARSED_ARGUMENTS)
        Abort("unrecognized argument(s): ${arg_UNPARSED_ARGUMENTS}")
    endif()
    
    if(arg_verbose)
        set(SIMPLEPRINT_DISABLED OFF)
    else()
        set(SIMPLEPRINT_DISABLED ON)
    endif()

    print_to_buffer("\n >>>>> TARGET <${arg_name}> MANIFEST <<<<< \n") 
    if(arg_exe)
        add_executable("${arg_name}" ${arg_src})
        print_to_buffer(" [type]\n    executable")  
    else()
        add_library("${arg_name}" ${arg_src})
        print_to_buffer(" [type]\n    static library")  
    endif()

    set(Includes "${arg_includes}")
    set(Libs "${arg_libs}")

    foreach(_dep   ${arg_depends})

        if(NOT ${_dep}_FOUND )
            set(msg_lvl ${CMAKE_MESSAGE_LOG_LEVEL})
            set(CMAKE_MESSAGE_LOG_LEVEL "WARNING")
                find_package(${_dep}  QUIET) 
            set(CMAKE_MESSAGE_LOG_LEVEL ${msg_lvl})  
        endif()

        if(NOT ${_dep}_FOUND )
            message(FATAL_ERROR "cannot find package `${_dep}` which is a dependency of ${arg_name}")
        endif()

        if(${_dep}_INCLUDE_DIRS)
            list(APPEND Includes "${${_dep}_INCLUDE_DIRS}")
        endif()
 
        if(${_dep}_LIBRARIES) 
            list(APPEND Libs     "${${_dep}_LIBRARIES}")
        endif()
        
    endforeach()

  #  message("i=${Includes}")
  #  message("l=${Libs}")

    target_include_directories("${arg_name}" PUBLIC ${Includes})
    target_link_libraries("${arg_name}" PUBLIC ${Libs})
    print_to_buffer(" [includes]")
    print_list_to_buffer("${Includes}" "   ")   
    print_to_buffer(" [libs]")
    print_list_to_buffer("${Libs}" "   ")  
    dump_buffer()

    if(arg_bin_dir)
        add_custom_command(TARGET ${arg_name} POST_BUILD        # Adds a post-build event to MyTest
        COMMAND ${CMAKE_COMMAND} -E copy_directory  # which executes "cmake - E copy_if_different..."
            "${arg_bin_dir}"      # <--this is in-file
            $<TARGET_FILE_DIR:${arg_name}>)                 # <--this is out-file path
    endif()
endfunction(AddTarget) 