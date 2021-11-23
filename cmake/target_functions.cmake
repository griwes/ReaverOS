function(_reaveros_add_target_maybe_tests _name)
    add_custom_target(${_name})
    if (REAVEROS_ENABLE_UNIT_TESTS)
        add_custom_target(${_name}-build-tests)
    endif()
endfunction()

function(reaveros_add_aggregate_targets _suffix)
    if (NOT "${_suffix}" STREQUAL "")
        _reaveros_add_target_maybe_tests(all-${_suffix})
        set(_suffix "-${_suffix}")
    else()
        add_custom_target(all-build-tests)
    endif()

    foreach (architecture IN LISTS REAVEROS_ARCHITECTURES)
        _reaveros_add_target_maybe_tests(all-${architecture}${_suffix})
    endforeach()

    set(_modes freestanding hosted)
    if (REAVEROS_ENABLE_UNIT_TESTS)
        list(APPEND _modes tests)
    endif()
    foreach (mode IN LISTS _modes)
        _reaveros_add_target_maybe_tests(all-${mode}${_suffix})
        foreach (architecture IN LISTS REAVEROS_ARCHITECTURES)
            _reaveros_add_target_maybe_tests(all-${architecture}-${mode}${_suffix})
        endforeach()
    endforeach()
endfunction()

function(_reaveros_register_target_impl _target _head _tail)
    list(LENGTH _tail _tail_length)
    math(EXPR _tail_length_prev "${_tail_length} - 1")

    foreach (_index RANGE 0 ${_tail_length_prev})
        list(GET _tail ${_index} _current_element)
        set(_full_list ${_head} ${_current_element})

        string(REPLACE ";" "-" _aggregate_target "${_full_list}")
        if (TARGET all-${_aggregate_target})
            #message("add_dependencies(all-${_aggregate_target} ${_target})")
            add_dependencies(all-${_aggregate_target} ${_target})
            #else()
            #message("skipping add_dependencies(all-${_aggregate_target} ${_target})")
        endif()

        math(EXPR _index_next "${_index} + 1")
        if (${_index_next} LESS ${_tail_length})
            list(SUBLIST _tail ${_index_next} -1 _current_tail)

            _reaveros_register_target_impl(${_target} "${_full_list}" "${_current_tail}")
        endif()
    endforeach()
endfunction()

function(reaveros_register_target _target)
    _reaveros_register_target_impl(${_target} "" "${ARGN}")
endfunction()

function(reaveros_add_component _directory _prefix)
    message(STATUS "Adding component ${CMAKE_CURRENT_SOURCE_DIR}/${_directory}...")

    if (NOT ${_prefix} STREQUAL "")
        set(_prefix "${_prefix}-")
    endif()

    foreach (_architecture IN LISTS REAVEROS_COMPONENT_ARCHITECTURES)
        foreach (_mode IN LISTS REAVEROS_COMPONENT_MODES)
            if (REAVEROS_COMPONENT_SKIP_MODE_NAME AND NOT _mode STREQUAL "tests")
                set(_component_name ${_prefix}${_directory}-${_architecture})
            else()
                set(_component_name ${_prefix}${_directory}-${_mode}-${_architecture})
            endif()
            cmake_language(EVAL CODE "set(_depends ${REAVEROS_COMPONENT_DEPENDS})")
            cmake_language(EVAL CODE "set(_install_path ${REAVEROS_COMPONENT_INSTALL_PATH})")

            ExternalProject_Add(${_component_name}
                EXCLUDE_FROM_ALL TRUE

                DOWNLOAD_COMMAND ""
                SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${_directory}
                BUILD_ALWAYS 1

                STEP_TARGETS build install

                DEPENDS toolchain-llvm-install ${_depends}

                INSTALL_DIR ${REAVEROS_BINARY_DIR}/install/${_install_path}

                ${_REAVEROS_CONFIGURE_HANDLED_BY_BUILD}

                CMAKE_COMMAND ${REAVEROS_CMAKE}
                CMAKE_ARGS
                    --no-warn-unused-cli
                    -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
                    -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
                    -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_TOOLCHAIN_FILE=${REAVEROS_BINARY_DIR}/install/toolchain/files/${_architecture}-${_mode}.cmake
                    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
                    -DREAVEROS_ARCH=${_architecture}
            )

            reaveros_register_target(${_component_name}-install ${_architecture} ${_mode} ${ARGN} ${_directory})

            if (${_mode} STREQUAL "tests")
                reaveros_register_target(${_component_name}-build build-tests ${_architecture} ${_mode} ${ARGN} ${_directory})

                set_property(GLOBAL APPEND PROPERTY _REAVEROS_COMPONENTS "${_component_name}")
                if (NOT _directory STREQUAL "kernel")
                    set(_labels "${_architecture};${ARGN};${_prefix}${_directory}")
                else()
                    set(_labels "${_architecture};${ARGN}")
                endif()
                set_target_properties("${_component_name}"
                    PROPERTIES
                        _REAVEROS_COMPONENT_LABELS "${_labels}"
                        _REAVEROS_COMPONENT_TEST_NAME "${_prefix}${_directory}-${_architecture}"
                )
            endif()
        endforeach()
    endforeach()
endfunction()

function(reaveros_include_component _directory _prefix)
    set(_component_vars
        REAVEROS_COMPONENT_ARCHITECTURES
        REAVEROS_COMPONENT_INSTALL_PATH
        REAVEROS_COMPONENT_MODES
        REAVEROS_COMPONENT_SKIP_MODE_NAME
        REAVEROS_COMPONENT_DEPENDS
    )
    foreach (_variable IN LISTS _component_vars)
        unset(${_variable})
    endforeach()

    include(${_directory}/component.cmake)

    if (NOT DEFINED REAVEROS_COMPONENT_SKIP_MODE_NAME)
        set(REAVEROS_COMPONENT_SKIP_MODE_NAME FALSE)
    endif()

    foreach (_variable IN LISTS _component_vars)
        if (NOT DEFINED ${_variable})
            message(FATAL_ERROR "Variable ${_variable} not defined for component ${CMAKE_CURRENT_SOURCE_DIR}/${_directory}!")
        endif()
    endforeach()

    reaveros_add_component(${_directory} "${_prefix}" ${ARGN})
endfunction()

function(reaveros_automatic_components _prefix)
    file(GLOB _directories RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS *)

    foreach (_directory IN LISTS _directories)
        if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_directory}
                AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_directory}/component.cmake
        )
            reaveros_include_component(${_directory} "${_prefix}" ${ARGN})
        endif()
    endforeach()
endfunction()

function(reaveros_add_ep_prune_target external_project)
    ExternalProject_Get_Property(${external_project} STAMP_DIR)

    get_property(has_git_tag TARGET ${external_project} PROPERTY _EP_GIT_TAG SET)
    if (has_git_tag)
        get_property(GIT_TAG TARGET ${external_project} PROPERTY _EP_GIT_TAG)
        set(force_download_stamp_rm_cmd
            find ${STAMP_DIR}
                -name "${external_project}-force-download-*"
                ! -name "${external_project}-force-download-${GIT_TAG}"
                -delete
        )
    else()
        set(force_download_stamp_rm_cmd true)
    endif()

    file(TOUCH ${STAMP_DIR}/${external_project}-skip-update)
    file(TOUCH ${STAMP_DIR}/${external_project}-configure)
    file(TOUCH ${STAMP_DIR}/${external_project}-build)
    file(TOUCH ${STAMP_DIR}/${external_project}-install)

    set(_commands
        COMMAND rm -rf <SOURCE_DIR> <BINARY_DIR>
        COMMAND ${force_download_stamp_rm_cmd}
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-gitclone-lastrun.txt
        COMMAND touch ${STAMP_DIR}/${external_project}-set-to-tag
        COMMAND touch ${STAMP_DIR}/${external_project}-skip-update
        COMMAND touch ${STAMP_DIR}/${external_project}-configure
        COMMAND touch ${STAMP_DIR}/${external_project}-build
        COMMAND touch ${STAMP_DIR}/${external_project}-install
    )

    ExternalProject_Add_Step(${external_project}
        prune
        ${_commands}
        EXCLUDE_FROM_MAIN TRUE
        INDEPENDENT TRUE
    )
    ExternalProject_Add_StepTargets(${external_project} prune)

    add_dependencies(all-toolchain-prune
        ${external_project}-prune
    )
endfunction()

function(reaveros_add_ep_fetch_tag_target external_project)
    ExternalProject_Get_Property(${external_project} STAMP_DIR GIT_TAG)

    ExternalProject_Add_Step(${external_project}
        set-to-tag
        COMMAND ${GIT_EXECUTABLE} fetch origin ${GIT_TAG} --depth=1
        COMMAND ${GIT_EXECUTABLE} checkout ${GIT_TAG}
        WORKING_DIRECTORY <SOURCE_DIR>
        DEPENDEES download
        DEPENDERS update configure build
        EXCLUDE_FROM_MAIN TRUE
        INDEPENDENT TRUE
    )

    file(GLOB force_download_stamps ${STAMP_DIR}/${external_project}-force-download-*)
    list(REMOVE_ITEM force_download_stamps ${STAMP_DIR}/${external_project}-force-download-${GIT_TAG})

    ExternalProject_Add_Step(${external_project}
        force-download-${GIT_TAG}
        COMMAND find ${STAMP_DIR}
            -name "${external_project}-force-download-*"
            ! -name "${external_project}-force-download-${GIT_TAG}"
            -delete
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-mkdir
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-download
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-gitclone-lastrun.txt
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-configure
        DEPENDERS mkdir download update set-to-tag prune
        EXCLUDE_FROM_MAIN TRUE
        INDEPENDENT TRUE
    )

    add_custom_command(TARGET ${external_project}
        COMMAND touch ${STAMP_DIR}/${external_project}-set-to-tag
        COMMAND touch ${STAMP_DIR}/${external_project}-skip-update
        COMMAND touch ${STAMP_DIR}/${external_project}-configure
        COMMAND touch ${STAMP_DIR}/${external_project}-build
        COMMAND touch ${STAMP_DIR}/${external_project}-install
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-prune
    )
    add_custom_command(TARGET ${external_project}-install
        COMMAND touch ${STAMP_DIR}/${external_project}-set-to-tag
        COMMAND touch ${STAMP_DIR}/${external_project}-skip-update
        COMMAND touch ${STAMP_DIR}/${external_project}-configure
        COMMAND touch ${STAMP_DIR}/${external_project}-build
        COMMAND touch ${STAMP_DIR}/${external_project}-install
        COMMAND rm -rf ${STAMP_DIR}/${external_project}-prune
    )
endfunction()

