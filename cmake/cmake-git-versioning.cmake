# cmake-git-versioning.cmake
# CMake module to generate version information from git

include(FindGit)

# Get the directory where this module is located
get_filename_component(GIT_VERSION_MODULE_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
get_filename_component(GIT_VERSION_BASE_DIR "${GIT_VERSION_MODULE_DIR}" DIRECTORY)

# Function to extract git version information and set CMake variables
function(get_git_version_info)
    # Get git information
    if(GIT_FOUND)
        # Get git describe
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_DESCRIBE
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Get git commit hash (short)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_HASH_SHORT
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Get git commit hash (full)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_HASH_FULL
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Get the latest tag
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(NOT GIT_TAG)
            set(GIT_TAG "unknown")
        endif()

        # Check if working directory is dirty
        execute_process(
            COMMAND ${GIT_EXECUTABLE} diff --quiet
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE GIT_DIRTY_RESULT
            ERROR_QUIET
        )
        if(GIT_DIRTY_RESULT EQUAL 0)
            set(GIT_IS_DIRTY "0")
            set(GIT_DIRTY_SUFFIX "")
        else()
            set(GIT_IS_DIRTY "1")
            set(GIT_DIRTY_SUFFIX "-dirty")
        endif()

        # Extract components from git describe
        # Format: v1.2.3 or v1.2.3-5-gabc1234 or v1.2.3-5-gabc1234-dirty
        if(GIT_DESCRIBE MATCHES "^(.+?)(-([0-9]+)-g([a-f0-9]+))?(-dirty)?$")
            set(GIT_DESCRIBE_TAG "${CMAKE_MATCH_1}")
            if(CMAKE_MATCH_3)
                set(GIT_COMMIT_COUNT "${CMAKE_MATCH_3}")
            else()
                set(GIT_COMMIT_COUNT "0")
            endif()
            if(CMAKE_MATCH_4)
                set(GIT_DESCRIBE_HASH "${CMAKE_MATCH_4}")
            else()
                set(GIT_DESCRIBE_HASH "${GIT_COMMIT_HASH_SHORT}")
            endif()
        else()
            # Fallback if pattern doesn't match
            set(GIT_DESCRIBE_TAG "${GIT_DESCRIBE}")
            set(GIT_COMMIT_COUNT "0")
            set(GIT_DESCRIBE_HASH "${GIT_COMMIT_HASH_SHORT}")
        endif()

        # Remove 'v' prefix from tag if present
        if(GIT_TAG MATCHES "^v(.+)$")
            set(GIT_TAG_NO_V "${CMAKE_MATCH_1}")
        else()
            set(GIT_TAG_NO_V "${GIT_TAG}")
        endif()

        # Also remove 'v' from describe tag if present
        if(GIT_DESCRIBE_TAG MATCHES "^v(.+)$")
            set(GIT_DESCRIBE_TAG_NO_V "${CMAKE_MATCH_1}")
        else()
            set(GIT_DESCRIBE_TAG_NO_V "${GIT_DESCRIBE_TAG}")
        endif()

        # Get git branch name
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_BRANCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Get git commit date
        execute_process(
            COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_DATE
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        # Try to extract version from git describe or tag
        if(GIT_DESCRIBE MATCHES "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)")
            set(GIT_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(GIT_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(GIT_VERSION_PATCH "${CMAKE_MATCH_3}")
        elseif(GIT_TAG_NO_V MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
            set(GIT_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(GIT_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(GIT_VERSION_PATCH "${CMAKE_MATCH_3}")
        else()
            set(GIT_VERSION_MAJOR "0")
            set(GIT_VERSION_MINOR "0")
            set(GIT_VERSION_PATCH "0")
        endif()
    else()
        # Fallback values if git is not found
        set(GIT_DESCRIBE "unknown")
        set(GIT_COMMIT_HASH_SHORT "unknown")
        set(GIT_COMMIT_HASH_FULL "unknown")
        set(GIT_BRANCH "unknown")
        set(GIT_COMMIT_DATE "unknown")
        set(GIT_VERSION_MAJOR "0")
        set(GIT_VERSION_MINOR "0")
        set(GIT_VERSION_PATCH "0")
        set(GIT_TAG "unknown")
        set(GIT_TAG_NO_V "unknown")
        set(GIT_DESCRIBE_TAG "unknown")
        set(GIT_DESCRIBE_TAG_NO_V "unknown")
        set(GIT_COMMIT_COUNT "0")
        set(GIT_DESCRIBE_HASH "unknown")
        set(GIT_IS_DIRTY "0")
        set(GIT_DIRTY_SUFFIX "")
    endif()

    # Set variables in parent scope
    set(GIT_VERSION_MAJOR ${GIT_VERSION_MAJOR} PARENT_SCOPE)
    set(GIT_VERSION_MINOR ${GIT_VERSION_MINOR} PARENT_SCOPE)
    set(GIT_VERSION_PATCH ${GIT_VERSION_PATCH} PARENT_SCOPE)
    set(GIT_DESCRIBE ${GIT_DESCRIBE} PARENT_SCOPE)
    set(GIT_COMMIT_HASH_SHORT ${GIT_COMMIT_HASH_SHORT} PARENT_SCOPE)
    set(GIT_COMMIT_HASH_FULL ${GIT_COMMIT_HASH_FULL} PARENT_SCOPE)
    set(GIT_BRANCH ${GIT_BRANCH} PARENT_SCOPE)
    set(GIT_COMMIT_DATE ${GIT_COMMIT_DATE} PARENT_SCOPE)
    set(GIT_TAG ${GIT_TAG} PARENT_SCOPE)
    set(GIT_TAG_NO_V ${GIT_TAG_NO_V} PARENT_SCOPE)
    set(GIT_DESCRIBE_TAG ${GIT_DESCRIBE_TAG} PARENT_SCOPE)
    set(GIT_DESCRIBE_TAG_NO_V ${GIT_DESCRIBE_TAG_NO_V} PARENT_SCOPE)
    set(GIT_COMMIT_COUNT ${GIT_COMMIT_COUNT} PARENT_SCOPE)
    set(GIT_DESCRIBE_HASH ${GIT_DESCRIBE_HASH} PARENT_SCOPE)
    set(GIT_IS_DIRTY ${GIT_IS_DIRTY} PARENT_SCOPE)
    set(GIT_DIRTY_SUFFIX ${GIT_DIRTY_SUFFIX} PARENT_SCOPE)
endfunction()

function(generate_git_version)
    set(options C_VERSION CXX_MODULE)
    set(oneValueArgs OUTPUT_DIR TEMPLATE_FILE OUTPUT_FILE)
    set(multiValueArgs "")
    cmake_parse_arguments(GIT_VERSION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Default output directory
    if(NOT GIT_VERSION_OUTPUT_DIR)
        set(GIT_VERSION_OUTPUT_DIR "${CMAKE_BINARY_DIR}/generated")
    endif()

    # Determine template and output file based on options
    if(GIT_VERSION_CXX_MODULE)
        if(NOT GIT_VERSION_TEMPLATE_FILE)
            set(GIT_VERSION_TEMPLATE_FILE "${GIT_VERSION_BASE_DIR}/templates/version.cppm.in")
        endif()
        if(NOT GIT_VERSION_OUTPUT_FILE)
            set(GIT_VERSION_OUTPUT_FILE "version.cppm")
        endif()
    elseif(GIT_VERSION_C_VERSION)
        if(NOT GIT_VERSION_TEMPLATE_FILE)
            set(GIT_VERSION_TEMPLATE_FILE "${GIT_VERSION_BASE_DIR}/templates/version.h.in")
        endif()
        if(NOT GIT_VERSION_OUTPUT_FILE)
            set(GIT_VERSION_OUTPUT_FILE "version.h")
        endif()
    else()
        if(NOT GIT_VERSION_TEMPLATE_FILE)
            set(GIT_VERSION_TEMPLATE_FILE "${GIT_VERSION_BASE_DIR}/templates/version.hpp.in")
        endif()
        if(NOT GIT_VERSION_OUTPUT_FILE)
            set(GIT_VERSION_OUTPUT_FILE "version.hpp")
        endif()
    endif()

    # Get git information (also sets CMake variables in parent scope)
    get_git_version_info()

    # Create output directory
    file(MAKE_DIRECTORY ${GIT_VERSION_OUTPUT_DIR})

    # Configure the template file
    set(OUTPUT_PATH "${GIT_VERSION_OUTPUT_DIR}/${GIT_VERSION_OUTPUT_FILE}")
    configure_file(
        ${GIT_VERSION_TEMPLATE_FILE}
        ${OUTPUT_PATH}
        @ONLY
    )

    # Return the output path
    set(GIT_VERSION_OUTPUT_PATH ${OUTPUT_PATH} PARENT_SCOPE)
    message(STATUS "Generated version file: ${OUTPUT_PATH}")
endfunction()

