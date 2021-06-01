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
    该选项存在表示要生成可执行文件，否则生成静态库。

header_only
    该选项表示创建头文件库

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
        "exe;header_only;shared;verbose"                        # optional args
        "name"                       # one value args
        "libs;includes;libs_public;includes_public;src;depends;bin_dir"  # multi value args
        ${ARGN}
    )
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "unrecognized argument(s): ${arg_UNPARSED_ARGUMENTS}")
    endif()
    
    if(arg_verbose)
        set(SIMPLEPRINT_DISABLED OFF)
    else()
        set(SIMPLEPRINT_DISABLED ON)
    endif()

    print_to_buffer("\n >>>>> TARGET <${arg_name}> MANIFEST <<<<< \n") 

    if(arg_exe AND arg_header_only)
        message(FATAL_ERROR "conflicting options `exe` and `header_only`")
    endif()

    if(arg_exe)
        add_executable("${arg_name}" ${arg_src})
        print_to_buffer(" [type]\n    executable")  
    elseif(arg_header_only)
        if(arg_src)
            message(FATAL_ERROR "cannot provide source files to header-only target")
        endif()
        add_library("${arg_name}" INTERFACE)
        print_to_buffer(" [type]\n    header_only library")  
    else()
        if(arg_shared)
        add_library("${arg_name}" SHARED ${arg_src})  
        else()
        add_library("${arg_name}" ${arg_src})
        endif()
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

        # 先看`大写_INCLUDE_DIRS`，`大写_INCLUDE_DIRS`为空再看`小写_INCLUDE_DIRS`
        if(${_dep}_INCLUDE_DIRS)
            list(APPEND Includes "${${_dep}_INCLUDE_DIRS}")
        else()
            string(TOLOWER "${_dep}" _dep_lower) 
            list(APPEND Includes "${${_dep_lower}_INCLUDE_DIRS}")
        endif()
 
        if(${_dep}_LIBRARIES) 
            list(APPEND Libs  "${${_dep}_LIBRARIES}")
        else()
            string(TOLOWER "${_dep}" _dep_lower) 
            list(APPEND Libs "${${_dep_lower}_LIBRARIES}")
        endif()
        
    endforeach()

  #  message("i=${Includes}")
  #  message("l=${Libs}")
    if(arg_header_only)
        target_include_directories("${arg_name}" INTERFACE ${Includes})
        target_link_libraries("${arg_name}" INTERFACE ${Libs})
    else()
        target_include_directories("${arg_name}" PRIVATE ${Includes})
        target_link_libraries("${arg_name}" PRIVATE ${Libs})
    endif()

    target_include_directories("${arg_name}" PUBLIC ${arg_includes_public})
    target_link_libraries("${arg_name}" PUBLIC  ${arg_libs_public}) 

    print_to_buffer(" [src]")
    print_list_to_buffer("${arg_src}" "   ")  
    print_to_buffer(" [includes]")
    print_list_to_buffer("${Includes}" "   ")   
    print_to_buffer(" [libs]")
    print_list_to_buffer("${Libs}" "   ")  
    print_to_buffer(" [public includes]")
    print_list_to_buffer("${arg_includes_public}" "   ")   
    print_to_buffer(" [public libs]")
    print_list_to_buffer("${arg_libs_public}" "   ")  
    dump_buffer()

    if(arg_bin_dir AND NOT arg_header_only)
        foreach(dir ${arg_bin_dir})
            add_custom_command(TARGET ${arg_name} POST_BUILD        # Adds a post-build event to MyTest
            COMMAND ${CMAKE_COMMAND} -E copy_directory  # which executes "cmake - E copy_if_different..."
                "${dir}"      # <--this is in-file
                "$<TARGET_FILE_DIR:${arg_name}>")                 # <--this is out-file path
        endforeach() 
    endif()
endfunction(AddTarget) 