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

#include "hpet.h"
#include "../../../util/log.h"
#include "../../../util/pointer_types.h"
#include "../../common/acpi/acpi.h"
#include "../cpu/cpu.h"
#include "../cpu/irqs.h"

namespace
{
class hpet_timer
{
    enum class _registers
    {
        general_capabilities = 0x0,
        general_configuration = 0x10,
        interrupt_status = 0x20,
        main_counter = 0xf0
    };

    enum class _timer_registers
    {
        configuration = 0x100,
        comparator = 0x108,
        fsb_route = 0x110
    };

    auto _timer_register(std::uintptr_t timer, _timer_registers reg)
    {
        return static_cast<_registers>(timer * 0x20 + static_cast<std::uintptr_t>(reg));
    }

    class hpet_comparator
    {
    public:
        bool valid() const
        {
            return _parent;
        }

        bool initialize(std::uintptr_t timer, hpet_timer * parent)
        {
            _timer = timer;
            _parent = parent;

            auto conf_and_caps = _read(_timer_registers::configuration);

            if (!(conf_and_caps & (1 << 15)))
            {
                kernel::log::println(
                    " >>> Comparator {} does not support FSB interrupt mappings; disabling.", _timer);
                _parent = nullptr;
                return false;
            }

            if (!(conf_and_caps & (1 << 5)))
            {
                kernel::log ::println(
                    " >>> Comparator {} does not support 64 bit operations; disabling.", _timer);
                _parent = nullptr;
                return false;
            }

            // enable FSB interrupts
            _write(_timer_registers::configuration, conf_and_caps | (1 << 14));
            conf_and_caps = _read(_timer_registers::configuration);

            // ensure edge mode
            if (conf_and_caps & (1 << 1))
            {
                _write(_timer_registers::configuration, conf_and_caps ^ (1 << 1));
                conf_and_caps = _read(_timer_registers::configuration);
            }

            // disable 32-bit operations if enabled
            if (conf_and_caps & (1 << 8))
            {
                _write(_timer_registers::configuration, conf_and_caps ^ (1 << 8));
                conf_and_caps = _read(_timer_registers::configuration);
            }

            // disable interrupts if enabled
            if (conf_and_caps & (1 << 2))
            {
                _write(_timer_registers::configuration, conf_and_caps ^ (1 << 2));
                conf_and_caps = _read(_timer_registers::configuration);
            }

            // setup FSB interrupt destination
            std::uint64_t fsb_address = (0xfee << 20) | (kernel::amd64::cpu::current_core()->apic_id() << 12);
            std::uint64_t fsb_data = kernel::amd64::irq::hpet_timer;

            _write(_timer_registers::fsb_route, (fsb_address << 32) | fsb_data);

            return true;
        }

    private:
        hpet_timer * _parent = nullptr;
        std::uintptr_t _timer = -1;

        std::uint64_t _read(_timer_registers reg)
        {
            return _parent->_read(_parent->_timer_register(_timer, reg));
        }

        void _write(_timer_registers reg, std::uint64_t value)
        {
            return _parent->_write(_parent->_timer_register(_timer, reg), value);
        }
    };

    friend class hpet_comparator;

public:
    hpet_timer() = default;

    void initialize(kernel::phys_addr_t base, std::uintptr_t min_tick)
    {
        _base = base;
        _min_tick = min_tick;

        kernel::log::println(" >> Initializing HPET with information from registers...");

        _write(_registers::general_configuration, 0x1);
        auto caps = _read(_registers::general_capabilities);

        _comparator_count = ((caps & 0b111110000000) >> 8) + 1;
        kernel::log::println(" >> HPET comparator count: {}.", _comparator_count);

        _period = caps >> 32;
        auto frequency = 1000000000000000ull / _period;

        auto size = (caps & (1 << 13)) ? 64 : 32;

        if (size == 32)
        {
            _max_tick = (~0u / 1000000) * _period;

            if (!_max_tick)
            {
                _max_tick = -1;
            }
        }

        else
        {
            _max_tick = (~0ull / 1000000) * _period;
        }

        kernel::log::println(" >> HPET counter period: {}fs.", _period);
        kernel::log::println(" >> HPET counter frequency: {}Hz", frequency);

        auto object_idx = 0ull;
        for (auto comparator = 0ull; comparator < _comparator_count; ++comparator)
        {
            kernel::log::println(" >> Initializing comparator {}...", comparator);
            if (_comparators[object_idx].initialize(comparator, this))
            {
                ++object_idx;
            }
        }

        _comparator_count = object_idx;

        if (!_comparator_count)
        {
            PANIC("Failed to initialize any of the HPET comparators!");
        }
    }

private:
    kernel::phys_addr_t _base;
    std::uintptr_t _comparator_count;
    std::uintptr_t _period;
    std::uintptr_t _min_tick;
    std::uintptr_t _max_tick;
    hpet_comparator _comparators[32];

    std::uint64_t _read(_registers reg)
    {
        return *kernel::phys_ptr_t<std::uint64_t>{ _base + static_cast<std::uint64_t>(reg) };
    }

    void _write(_registers reg, std::uint64_t value)
    {
        *kernel::phys_ptr_t<std::uint64_t>{ _base + static_cast<std::uint64_t>(reg) } = value;
    }
};

hpet_timer timer;
}

namespace kernel::amd64::hpet
{
void initialize()
{
    auto result = acpi::parse_hpet();
    timer.initialize(result.base, result.min_tick);
}
}
