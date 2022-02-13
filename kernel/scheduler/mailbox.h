/*
 * Copyright © 2021-2022 Michał 'Griwes' Dominiak
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

#include "../util/fifo.h"
#include "../util/handle.h"
#include "../util/intrusive_ptr.h"

namespace kernel::scheduler
{
class process;
class thread;
}

namespace kernel::ipc
{
struct mailbox_message : util::chained_allocatable<mailbox_message>
{
    // TODO: this should be a variant, but I'd rather not stop to implement std::variant right now
    // I'll fix this when this structure *actually* wants to hold different things

    util::intrusive_ptr<handle> payload;
};

class mailbox : public util::intrusive_ptrable<mailbox>
{
public:
    void send(util::intrusive_ptr<handle> handle);

private:
    std::mutex _lock;

    util::fifo<mailbox_message> _message_queue;
    util::fifo<scheduler::thread> _waiting_threads;
};

util::intrusive_ptr<mailbox> create_mailbox();
}
