macro(print_to_buffer msg)
    if(NOT SIMPLEPRINT_DISABLED)
        set(_buffer "${_buffer}${msg}\n")
    endif()
endmacro()

macro(print_list_to_buffer list prefix)
    if(NOT SIMPLEPRINT_DISABLED)
    foreach(_elem ${list})
        set(_buffer "${_buffer}${prefix}${_elem}\n")
    endforeach()
    endif()
endmacro()


macro(dump_buffer) 
    if(NOT SIMPLEPRINT_DISABLED)
    message("${_buffer}") 
    endif()
endmacro()

macro(print_error msg)
    message(FATAL_ERROR "${msg}") 
endmacro()