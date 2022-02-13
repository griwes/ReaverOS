function(_reaveros_add_initrd_image_target architecture)
    set(_working_path ${REAVEROS_BINARY_DIR}/images/initrd-${architecture})
    set(_target_path ${REAVEROS_BINARY_DIR}/install/images/initrd-${architecture}.img)

    file(MAKE_DIRECTORY ${REAVEROS_BINARY_DIR}/install/images)
    file(MAKE_DIRECTORY ${_working_path})

    add_custom_command(OUTPUT ${_target_path} "always rebuilt"
        DEPENDS
            # all-${architecture}-userspace-services-core
            # all-${architecture}-userspace-services-storage
            # all-${architecture}-userspace-services-filesystem

        COMMAND rm -rf ${_working_path}
        COMMAND mkdir ${_working_path}

        COMMAND find ${_working_path} | cpio --create > ${_target_path}
    )

    add_custom_target(image-initrd-${architecture}
        DEPENDS ${_target_path}
    )

    reaveros_register_target(image-initrd-${architecture} ${architecture} images initrd)
endfunction()

reaveros_add_aggregate_targets(images-initrd)

foreach (architecture IN LISTS REAVEROS_ARCHITECTURES)
    _reaveros_add_initrd_image_target(${architecture})
endforeach()

