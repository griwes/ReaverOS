function(_reaveros_add_uefi_image_target architecture)
    set(_targetfs_contents ${REAVEROS_BINARY_DIR}/images/mount/uefi-efipart-${architecture})
    set(_targetfs_path ${REAVEROS_BINARY_DIR}/install/images/uefi-efipart-${architecture}.img)

    file(MAKE_DIRECTORY ${REAVEROS_BINARY_DIR}/install/images)

    add_custom_command(OUTPUT ${_targetfs_path} "always rebuilt"
        DEPENDS
            toolchain-dosfstools-install
            toolchain-mtools-install

            loader-uefi-${architecture}
            kernel-${architecture}
            image-initrd-${architecture}

            # this should be dynamically generated
            # from an in file that is dynamically generated by the loader above
            # but for now we'll just use the static file to make our life easier
            # there isn't anything useful for this to do quite yet
            ${REAVEROS_SOURCE_DIR}/loaders/uefi/config/reaveros.conf

        COMMAND rm -rf ${_targetfs_contents}
        COMMAND mkdir -p ${_targetfs_contents}/EFI/BOOT
        COMMAND cp
            ${REAVEROS_BINARY_DIR}/install/loaders/uefi-${architecture}/loader-uefi
            ${_targetfs_contents}/EFI/BOOT/BOOTX64.EFI
        COMMAND cp
            ${REAVEROS_SOURCE_DIR}/loaders/uefi/config/reaveros.conf
            ${_targetfs_contents}/EFI/BOOT/reaveros.conf

        COMMAND mkdir -p ${_targetfs_contents}/reaver
        COMMAND cp
            ${REAVEROS_BINARY_DIR}/install/kernels/${architecture}/kernel
            ${_targetfs_contents}/reaver/kernel.img
        COMMAND cp
            ${REAVEROS_BINARY_DIR}/install/images/initrd-${architecture}.img
            ${_targetfs_contents}/reaver/initrd.img

        COMMAND rm -f ${_targetfs_path}
        COMMAND fallocate -l 1474560 ${_targetfs_path}
        COMMAND ${REAVEROS_BINARY_DIR}/install/toolchain/dosfstools/sbin/mkfs.fat ${_targetfs_path}
        COMMAND ${REAVEROS_BINARY_DIR}/install/toolchain/mtools/bin/mcopy -os -i ${_targetfs_path} ${_targetfs_contents}/* ::/
    )

    add_custom_target(image-uefi-efipart-${architecture}
        DEPENDS ${_targetfs_path}
    )

    reaveros_register_target(image-uefi-efipart-${architecture} ${architecture} images uefi-efipart)
endfunction()

if ("amd64" IN_LIST REAVEROS_ARCHITECTURES AND "uefi" IN_LIST REAVEROS_LOADERS)
    reaveros_add_aggregate_targets(images-uefi-efipart)

    _reaveros_add_uefi_image_target(amd64)
endif()
