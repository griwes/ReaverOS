/*
 * Copyright © 2021 Michał 'Griwes' Dominiak
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include "gdt.h"

#include <cstdint>

namespace kernel::amd64::cpu
{
class core
{
public:
    void initialize_ids(std::uint32_t apic_id, std::uint32_t acpi_id)
    {
        _is_valid = true;
        _apic_id = apic_id;
        _acpi_id = acpi_id;
    }

    void set_nmi(std::uint32_t interrupt, std::uint16_t flags)
    {
        _nmi_valid = true;
        _nmi_vector = interrupt;
        _nmi_flags = flags;
    }

    auto apic_id()
    {
        return _apic_id;
    }

    auto acpi_id()
    {
        return _acpi_id;
    }

    void initialize_gdt();
    void load_gdt();
    void initialize_idt();
    void load_idt();

private:
    std::uint32_t _is_valid : 1 = false;
    std::uint32_t _nmi_valid : 1 = false;

    std::uint32_t _apic_id = 0;
    std::uint32_t _acpi_id = 0;

    std::uint32_t _nmi_vector = 0;
    std::uint16_t _nmi_flags = 0;

    gdt::entry _gdt[7];
    gdt::gdtr_t _gdtr;
};
}
