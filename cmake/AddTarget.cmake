include(CMakeParseArguments)
#[[   

AddTarget(
    [exe]       
    <name      目标名>
    [src       源文件1 源文件2 ...]
    [includes  包含路径1 包含路径2 ...] 
    [libs      链接目标1 链接目标2 ...]
    [depends   依赖模块1 依赖模块2 ...]
)

创建一个目标，`exe`选项表示要生成可执行文件，没有该选项表示要生成静态库。
依赖模块 X 表示在目标的include目录里面加上 X_INCLUDE_DIRS，链接库里面加上 X_LIBRARIES。

]] 
function(AddTarget)
    cmake_parse_arguments(
        "arg"                        # prefix
        "exe"                        # optional args
        "name"                       # one value args
        "libs;includes;src;depends"  # multi value args
        ${ARGN}
    )
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "unrecognized argument(s): ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(arg_exe)
        add_executable("${arg_name}" ${arg_src})
    else()
        add_library("${arg_name}" ${arg_src})
    endif()

    set(Includes "${arg_includes}")
    set(Libs "${arg_libs}")

    foreach(_dep   ${arg_depends})

        if(NOT ${_dep}_INCLUDE_DIRS )
            message( "calling find_package(${_dep}) ...")
            find_package(${_dep}) 
        endif()

        if(NOT ${_dep}_INCLUDE_DIRS )
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
    
endfunction(AddTarget) 