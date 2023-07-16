set(REAVEROS_COMPONENT_ARCHITECTURES ${REAVEROS_ARCHITECTURES})
set(REAVEROS_COMPONENT_INSTALL_PATH [=[sysroots/${_architecture}-${_mode}]=])
set(REAVEROS_COMPONENT_MODES uefi freestanding hosted tests)
set(REAVEROS_COMPONENT_DEPENDS_HOSTED [=[library-rosert-hosted-${_architecture}]=])
