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

#include "time.h"
#include "../arch/timers.h"
#include "../util/log.h"

namespace
{
kernel::time::timer * hpc = nullptr;
}

namespace kernel::time
{
void initialize()
{
    log::println("[TIME] Initializing the time subsystem...");

    arch::timers::initialize();
}

timer & high_precision_clock()
{
    if (!hpc)
    {
        PANIC("High precision clock requested, but not registered!");
    }

    return *hpc;
}
}
