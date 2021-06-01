#[[   

CppGlobalConfig(  
    [std                   STANDARD]
    [<compiler_id>_flags   FLAG...] 
    [flags                 FLAG...]
    [<compiler_id>_defs    MACRO...] 
    [defs                  MACRO...] 
)

std
    编译时采用的C++标准，例如：11 14 17 等。该值直接被写入CMAKE_CXX_STANDARD中。

<compiler_id>_flags
    使用特定编译器时采用的编译选项。可以为不同的编译器指定不同的编译选项。<compiler_id>是*全部小写*的编译器标识符。例如想指定MSVC编译器使用的编译选项，这里就是`msvc_flags`；想指定GCC的，这里就是`gnu_flags`，具体参考CMAKE_CXX_COMPILER_ID。

flags
    如果<compiler_id>_flags参数没有一个指定当前编译器应该使用什么编译选项，则使用本参数指定的编译选项。

    例：
    CppGlobalConfig(
        std                  11
        msvc_flags           /utf-8 
        gnu_flags            -Wall -Werror
        flags                -Wall
    )

    则对MSVC，编译选项为/utf-8，对gcc，编译选项为-Wall -Werror，对其他编译器，编译选项为-Wall。

<compiler_id>_defs
    使用特定编译器采用的宏定义。格式为`-DXXX`或者`-DXXX=YYY`。具体参见add_compile_definitions()的说明。

defs
    如果<compiler_id>_defs参数没有一个指定当前编译器应该使用什么宏定义，则使用本参数指定的宏定义。

]] 
function(CppGlobalConfig)


# 处理<compiler_id>_x相关任务。
# x 目前可能是"flags"或者"defs"。因为过程类似，所以把过程封装起来。 
# argv 是CppGlobalConfig的实参。
macro(extract_argnames   x  argv)
    # 以下注释假设x为"flags" 
    # 预处理参数，找到<compiler_id>_flags参数中出现的所有compiler_id，放在compiler_ids中。
    # <compiler_id>_flags本身放在argnames中。
    set(compiler_ids "")
    set(argnames     "") 
    set(match_regex "^.*_${x}$")
    set(replace_regex "_${x}$")

    foreach(arg ${argv}) 
        if(${arg} MATCHES ${match_regex})
            set(argcpy  "${arg}")
            string(REGEX REPLACE "${replace_regex}" "" compilerId "${argcpy}")
            list(APPEND compiler_ids "${compilerId}")
            list(APPEND argnames "${arg}")
        endif()
    endforeach()
endmacro()

 
#[[
    # message("compiler ids = ${compiler_ids}")
    # message("arg names = ${argnames}")
    # 进行参数分析，分析出来的参数都带arg_前缀
    cmake_parse_arguments(
        "arg"                       # prefix
        ""                          # optional args
        ""                          # one value args
        "${argnames};${x}"          # multi value args
        ${argv}
    )
    string(TOLOWER "${CMAKE_CXX_COMPILER_ID}" compiler_id_lower_case)
    # message("arg_${compiler_id_lower_case}_${x} = ${arg_${compiler_id_lower_case}_${x}}")
    set(out_values "${arg_${compiler_id_lower_case}_${x}}")
    if(NOT out_values)
        set(out_values "${arg_${x}}")
    endif()
    set(out_unparsed "${arg_UNPARSED_ARGUMENTS}")
#]]
extract_argnames(flags "${ARGV}")
set(agn_f "${argnames}")      # agn = argname, cid = compiler id, f = flags, d = defs,
set(cid_f "${compiler_ids}") 
extract_argnames(defs  "${ARGV}")
set(agn_d "${argnames}")      # agn = argname, cid = compiler id, f = flags, d = defs,
set(cid_d "${compiler_ids}")
 

cmake_parse_arguments(
    "arg"                                   # prefix
    ""                                      # optional args
    ""                                      # one value args
    "${agn_f};${agn_d};flags;defs"          # multi value args
    ${ARGV}
)

string(TOLOWER "${CMAKE_CXX_COMPILER_ID}" compiler_id_lower_case)
# message("arg_${compiler_id_lower_case}_${x} = ${arg_${compiler_id_lower_case}_${x}}")
set(my_flags "${arg_${compiler_id_lower_case}_flags}")
set(my_defs  "${arg_${compiler_id_lower_case}_defs}")

if(NOT my_flags)
    set(my_flags "${arg_flags}")
endif()

if(NOT my_defs)
    set(my_defs "${arg_defs}")
endif()

if(my_flags)
    add_compile_options(${my_flags}) # 添加编译选项！
    message("flags += ${my_flags}")
endif()

if(my_defs)
    add_compile_options(${my_defs}) # 添加编译选项！
    message("defs += ${my_defs}")
endif()
# 终于定义完工具函数了！开始做事！
# 调用handle_x来处理flags和defs，输出为2个：out_values和out_unparsed
# out_values为用户给的编译选项或者宏定义，out_unparsed为cmake_parse_arguments不理解的实参。
# 每次我们都是把传给CppGlobalConfig的全部参数给cmake_parse_arguments的，比如在处理flags时
# 我们把std、xxx_defs等参数也传给cmake_parse_arguments了！而cmake_parse_arguments只能看懂xxx_flags
# 所以out_unparsed会不为空！但没关系，我们只要每个参数*最终*被认识就行。即每次的out_unparsed的*交集*为空就行！
 
# 处理std等其他参数，此时调用第3次cmake_parse_arguments
cmake_parse_arguments(
    "arg"                       # prefix
    ""                          # optional args
    "std"                          # one value args
    ""          # multi value args
    ${ARGV}
)

# 计算三次out_unparsed的*交集*，赋值给never_parsed_args
 
foreach(arg ${flags_unparsed} ${defs_unparsed} ${arg_UNPARSED_ARGUMENTS})
    string(MD5 hash "${arg}") 
    if(DEFINED ${hash}_cnt)
        math(EXPR ${hash}_cnt "${${hash}_cnt}+1")
        if(${hash}_cnt EQUAL "3")
            list(APPEND never_parsed_args "${arg}")
        endif()
    else()
        set(${hash}_cnt 1)
    endif()
endforeach()
if(never_parsed_args)
    message(FATAL_ERROR "unknown args: ${never_parsed_args}")
endif()

# 设置cpp版本
if(arg_std) 
    set(CMAKE_CXX_STANDARD ${arg_std} PARENT_SCOPE) 
    set(CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE) 
    set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)
    message("std = ${arg_std}")
endif()
 
endfunction(CppGlobalConfig)
