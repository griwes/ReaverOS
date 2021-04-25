ExternalProject_Add(toolchain-dosfstools
    GIT_REPOSITORY ${REAVEROS_DOSFSTOOLS_REPO}
    GIT_TAG ${REAVEROS_DOSFSTOOLS_TAG}
    GIT_SHALLOW TRUE
    UPDATE_DISCONNECTED 1

    STEP_TARGETS install

    INSTALL_DIR ${REAVEROS_BINARY_DIR}/install/toolchains/dosfstools

    ${_REAVEROS_CONFIGURE_HANDLED_BY_BUILD}

    CONFIGURE_COMMAND cd <SOURCE_DIR> && <SOURCE_DIR>/autogen.sh
    COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
        "CC=${CMAKE_C_COMPILER_LAUNCHER} ${CMAKE_C_COMPILER}"
        "CXX=${CMAKE_CXX_COMPILER_LAUNCHER} ${CMAKE_CXX_COMPILER}"
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
)
reaveros_add_ep_prune_target(toolchain-dosfstools)
reaveros_add_ep_fetch_tag_target(toolchain-dosfstools)

reaveros_register_target(toolchain-dosfstools-install toolchains)

ExternalProject_Add(toolchain-mtools
    URL ${REAVEROS_MTOOLS_DIR}/${REAVEROS_MTOOLS_VER}
    UPDATE_DISCONNECTED 1

    STEP_TARGETS install

    INSTALL_DIR ${REAVEROS_BINARY_DIR}/install/toolchains/mtools

    ${_REAVEROS_CONFIGURE_HANDLED_BY_BUILD}

    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
        "CC=${CMAKE_C_COMPILER_LAUNCHER} ${CMAKE_C_COMPILER}"
        "CXX=${CMAKE_CXX_COMPILER_LAUNCHER} ${CMAKE_CXX_COMPILER}"
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
)
reaveros_add_ep_prune_target(toolchain-mtools)

reaveros_register_target(toolchain-mtools-install toolchains)
