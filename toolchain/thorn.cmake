ExternalProject_Add(toolchain-thorn
    DOWNLOAD_COMMAND ""
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/thorn
    BUILD_ALWAYS 1

    STEP_TARGETS install

    DEPENDS toolchain-cmake-install

    INSTALL_DIR ${REAVEROS_BINARY_DIR}/install/toolchain/thorn

    ${_REAVEROS_CONFIGURE_HANDLED_BY_BUILD}

    CMAKE_ARGS
        -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER}
        -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

reaveros_register_target(toolchain-thorn-install toolchain)
