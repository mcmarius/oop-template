###############################################################################
# Discovery half of cmake/RegisterTests.cmake: runs the test executable, turns
# its list of test cases into add_test() calls and writes them to a file ctest
# includes before running the tests.
#
# Framework agnostic, keep identical on every branch, see
# cmake/RegisterTests.cmake
#
# add_command / generate_testname_guards / escape_square_brackets are taken from
# CMake's own GoogleTestAddTests.cmake (BSD-3-Clause).
###############################################################################

function(add_command NAME TEST_NAME)
    set(args "")
    foreach(arg IN LISTS ARGN)
        if(arg MATCHES "[^-./:a-zA-Z0-9_]")
            string(APPEND args " [==[${arg}]==]")
        else()
            string(APPEND args " ${arg}")
        endif()
    endforeach()
    string(APPEND script "${NAME}(${TEST_NAME} ${args})\n")
    set(script "${script}" PARENT_SCOPE)
endfunction()

function(generate_testname_guards OUTPUT OPEN_GUARD_VAR CLOSE_GUARD_VAR)
    set(open_guard "[=[")
    set(close_guard "]=]")
    set(counter 1)
    while("${OUTPUT}" MATCHES "${close_guard}")
        math(EXPR counter "${counter} + 1")
        string(REPEAT "=" ${counter} equals)
        set(open_guard "[${equals}[")
        set(close_guard "]${equals}]")
    endwhile()
    set(${OPEN_GUARD_VAR} "${open_guard}" PARENT_SCOPE)
    set(${CLOSE_GUARD_VAR} "${close_guard}" PARENT_SCOPE)
endfunction()

function(escape_square_brackets OUTPUT BRACKET PLACEHOLDER PLACEHOLDER_VAR OUTPUT_VAR)
    if("${OUTPUT}" MATCHES "\\${BRACKET}")
        set(placeholder "${PLACEHOLDER}")
        while("${OUTPUT}" MATCHES "${placeholder}")
            set(placeholder "${placeholder}_")
        endwhile()
        string(REPLACE "${BRACKET}" "${placeholder}" OUTPUT "${OUTPUT}")
        set(${PLACEHOLDER_VAR} "${placeholder}" PARENT_SCOPE)
        set(${OUTPUT_VAR} "${OUTPUT}" PARENT_SCOPE)
    endif()
endfunction()

# replaces wildcard characters with "?", which still matches what it replaces
function(escape_name_pattern NAME CHARACTERS OUT_NAME OUT_CHANGED)
    string(LENGTH "${NAME}" length)
    set(out "")
    set(index 0)
    set(changed FALSE)

    while(index LESS length)
        string(SUBSTRING "${NAME}" ${index} 1 char)
        string(LENGTH "${char}" char_length)
        string(FIND "${CHARACTERS}" "${char}" position)

        if(char_length GREATER 0 AND position GREATER -1)
            string(APPEND out "?")
            set(changed TRUE)
        else()
            string(APPEND out "${char}")
        endif()

        math(EXPR index "${index} + 1")
    endwhile()

    set(${OUT_NAME} "${out}" PARENT_SCOPE)
    set(${OUT_CHANGED} "${changed}" PARENT_SCOPE)
endfunction()

# same length and every character equal or matched by "?"
function(matches_pattern PATTERN VALUE OUT_MATCH)
    string(LENGTH "${PATTERN}" pattern_length)
    string(LENGTH "${VALUE}" value_length)

    if(NOT pattern_length EQUAL value_length)
        set(${OUT_MATCH} FALSE PARENT_SCOPE)
        return()
    endif()

    set(index 0)
    while(index LESS pattern_length)
        string(SUBSTRING "${PATTERN}" ${index} 1 pattern_char)
        string(SUBSTRING "${VALUE}" ${index} 1 value_char)
        string(FIND "?" "${pattern_char}" wildcard)

        if(wildcard EQUAL -1 AND NOT "${pattern_char}" STREQUAL "${value_char}")
            set(${OUT_MATCH} FALSE PARENT_SCOPE)
            return()
        endif()

        math(EXPR index "${index} + 1")
    endwhile()

    set(${OUT_MATCH} TRUE PARENT_SCOPE)
endfunction()

# how many of the known cases a pattern selects
function(count_matching_cases PATTERN NAMES OUT_COUNT)
    set(count 0)

    foreach(name IN LISTS NAMES)
        matches_pattern("${PATTERN}" "${name}" matches)
        if(matches)
            math(EXPR count "${count} + 1")
        endif()
    endforeach()

    set(${OUT_COUNT} ${count} PARENT_SCOPE)
endfunction()

function(register_tests_discover)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "TEST_EXECUTABLE;TEST_WORKING_DIR;LIST_ARGS;LIST_NOISE;SELECT_ARG;NAME_ESCAPE;LIST_TIMEOUT;TIMEOUT;TEST_LIST;CTEST_FILE" "TEST_PROPERTIES")

    if(NOT EXISTS "${ARG_TEST_EXECUTABLE}")
        message(FATAL_ERROR
            "Specified test executable does not exist.\n"
            "  Path: '${ARG_TEST_EXECUTABLE}'"
        )
    endif()

    execute_process(
        COMMAND "${ARG_TEST_EXECUTABLE}" ${ARG_LIST_ARGS}
        WORKING_DIRECTORY "${ARG_TEST_WORKING_DIR}"
        TIMEOUT ${ARG_LIST_TIMEOUT}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error_output
        RESULT_VARIABLE result
    )

    # a failed listing is not the same as an empty one
    if(NOT result EQUAL 0)
        string(REPLACE "\n" "\n    " output "${output}${error_output}")
        message(FATAL_ERROR
            "Could not list the test cases of the test executable.\n"
            "  Path: '${ARG_TEST_EXECUTABLE}'\n"
            "  Working directory: '${ARG_TEST_WORKING_DIR}'\n"
            "  Listing arguments: ${ARG_LIST_ARGS}\n"
            "  Result: ${result}\n"
            "  Output:\n"
            "    ${output}\n"
            "The listing runs the executable; a crash here (runtime library\n"
            "missing next to it, wrong architecture) looks exactly like this."
        )
    endif()

    string(ASCII 27 escape)
    string(REGEX REPLACE "${escape}\\[[0-9;]*m" "" output "${output}")
    string(REPLACE "\r" "" output "${output}")

    # googletest indents the cases under a suite line, boost::ut lists flat names
    string(FIND "${output}" "\n  " indent_position)

    if(NOT indent_position EQUAL -1)
        set(hierarchical TRUE)
    else()
        set(hierarchical FALSE)
    endif()

    string(LENGTH "${ARG_LIST_NOISE}" noise_length)

    # brackets would end the guard written around a name
    generate_testname_guards("${output}" open_guard close_guard)
    escape_square_brackets("${output}" "[" "__osb" open_sb output)
    escape_square_brackets("${output}" "]" "__csb" close_sb output)

    string(REPLACE "\n" ";" lines "${output}")

    set(names "")
    set(suite "")

    foreach(line IN LISTS lines)
        # ^ and $ in a CMake regex are not per line, hence the per line noise removal
        if(noise_length GREATER 0)
            string(REGEX REPLACE "${ARG_LIST_NOISE}" "" line "${line}")
        endif()

        string(STRIP "${line}" stripped)
        string(LENGTH "${stripped}" line_length)

        if(line_length EQUAL 0)
            continue()
        endif()

        if(hierarchical)
            if(line MATCHES "^  +")
                set(name "${suite}.${stripped}")
                string(REGEX REPLACE " +#.*$" "" name "${name}")
            else()
                set(suite "${stripped}")
                string(REGEX REPLACE "\\.( *#.*)?$" "" suite "${suite}")
                continue()
            endif()
        else()
            set(name "${stripped}")
        endif()

        # an option line of a usage message is not a test case
        if(stripped MATCHES "^-")
            message(FATAL_ERROR
                "This does not look like a test case name, it looks like the\n"
                "output of '${ARG_LIST_ARGS}' is not a list of test cases:\n"
                "  '${stripped}'"
            )
        endif()

        # ';' ends a CMake list, a newline or a quote breaks the generated script
        if(name MATCHES "[;\n\"]")
            message(FATAL_ERROR
                "A test case name may not contain ';', a newline or a quote:\n"
                "  '${name}'"
            )
        endif()

        list(FIND names "${name}" duplicate)
        if(NOT duplicate EQUAL -1)
            # ctest test names are unique: a duplicate silently replaces the first
            message(FATAL_ERROR
                "Two test cases share the same name, test case names have to be\n"
                "unique across all suites: '${name}'"
            )
        endif()

        list(APPEND names "${name}")
    endforeach()

    list(LENGTH names count)

    if(count EQUAL 0)
        message(FATAL_ERROR
            "No test case is registered by '${ARG_TEST_EXECUTABLE}'.\n"
            "  Listing arguments: ${ARG_LIST_ARGS}\n"
            "  Output:\n    ${output}\n"
            "Register the suites (boost::ut: suite<\"...\">, googletest: TEST()),\n"
            "refusing to report success for a test executable that runs nothing."
        )
    endif()

    set(script "")
    set(discovered "")

    foreach(name IN LISTS names)
        set(selection "${ARG_SELECT_ARG}")
        string(LENGTH "${selection}" selection_length)

        if(selection_length GREATER 0)
            escape_name_pattern("${name}" "${ARG_NAME_ESCAPE}" pattern changed)

            if(changed)
                count_matching_cases("${pattern}" "${names}" matching)

                # "?" matches any character: the escaped name could run a
                # different case and still report success
                if(NOT matching EQUAL 1)
                    message(FATAL_ERROR
                        "Cannot select the test case '${name}' on its own, its name\n"
                        "contains a character the framework treats as a wildcard and\n"
                        "the escaped name '${pattern}' matches ${matching} of the\n"
                        "registered test cases. Rename the test case."
                    )
                endif()
            endif()

            string(REPLACE "<name>" "${pattern}" selection "${selection}")
        endif()

        if(open_sb)
            string(REPLACE "${open_sb}" "[" name "${name}")
        endif()

        if(close_sb)
            string(REPLACE "${close_sb}" "]" name "${name}")
        endif()

        set(guarded_name "${open_guard}${name}${close_guard}")

        add_command(add_test
            "${guarded_name}"
            "${ARG_TEST_EXECUTABLE}"
            ${selection}
        )

        add_command(set_tests_properties
            "${guarded_name}"
            PROPERTIES
            WORKING_DIRECTORY "${ARG_TEST_WORKING_DIR}"
            TIMEOUT "${ARG_TIMEOUT}"
            ${ARG_PROPERTIES}
        )

        # unbalanced brackets would invalidate the generated list: registered, but
        # left out of TEST_LIST
        if(NOT "${name}" MATCHES [[(\[|\])]])
            list(APPEND discovered "${name}")
        endif()
    endforeach()

    string(LENGTH "${ARG_TEST_LIST}" test_list_length)

    if(test_list_length GREATER 0)
        add_command(set "" "${ARG_TEST_LIST}" "${discovered}")
    endif()

    file(WRITE "${ARG_CTEST_FILE}" "${script}")
endfunction()
