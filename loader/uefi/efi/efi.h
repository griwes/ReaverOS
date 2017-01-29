/**
 * Reaver Project OS, Rose, Licence
 *
 * Copyright © 2016-2017 Michał "Griwes" Dominiak
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation is required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 **/

#pragma once

#include <climits>

#ifndef EFIAPI
#ifdef _MSC_EXTENSIONS
#define EFIAPI __cdecl
#else
#define EFIAPI __attribute__((ms_abi))
#endif
#endif

#include "types.h"

namespace efi_loader
{
constexpr auto EFI_SYSTEM_TABLE_SIGNATURE = 0x5453595320494249;
constexpr auto EFI_2_60_SYSTEM_TABLE_REVISION = ((2 << 16) | (60));
constexpr auto EFI_2_50_SYSTEM_TABLE_REVISION = ((2 << 16) | (50));
constexpr auto EFI_2_40_SYSTEM_TABLE_REVISION = ((2 << 16) | (40));
constexpr auto EFI_2_31_SYSTEM_TABLE_REVISION = ((2 << 16) | (31));
constexpr auto EFI_2_30_SYSTEM_TABLE_REVISION = ((2 << 16) | (30));
constexpr auto EFI_2_20_SYSTEM_TABLE_REVISION = ((2 << 16) | (20));
constexpr auto EFI_2_10_SYSTEM_TABLE_REVISION = ((2 << 16) | (10));
constexpr auto EFI_2_00_SYSTEM_TABLE_REVISION = ((2 << 16) | (00));
constexpr auto EFI_1_10_SYSTEM_TABLE_REVISION = ((1 << 16) | (10));
constexpr auto EFI_1_02_SYSTEM_TABLE_REVISION = ((1 << 16) | (02));

constexpr auto EFI_SYSTEM_TABLE_REVISION = EFI_2_60_SYSTEM_TABLE_REVISION;
constexpr auto EFI_SPECIFICATION_VERSION = EFI_SYSTEM_TABLE_REVISION;

constexpr auto high_bit = 1ull << (sizeof(EFI_STATUS) * CHAR_BIT - 1);

constexpr auto EFI_SUCCESS = 0;
constexpr auto EFI_LOAD_ERROR = 1 | high_bit;
constexpr auto EFI_INVALID_PARAMETER = 2 | high_bit;
constexpr auto EFI_UNSUPPORTED = 3 | high_bit;
constexpr auto EFI_BAD_BUFFER_SIZE = 4 | high_bit;
constexpr auto EFI_BUFFER_TOO_SMALL = 5 | high_bit;
constexpr auto EFI_NOT_READY = 6 | high_bit;
constexpr auto EFI_DEVICE_ERROR = 7 | high_bit;
constexpr auto EFI_WRITE_PROTECTED = 8 | high_bit;
constexpr auto EFI_OUT_OF_RESOURCES = 9 | high_bit;
constexpr auto EFI_VOLUME_CORRUPTED = 10 | high_bit;
constexpr auto EFI_VOLUME_FULL = 11 | high_bit;
constexpr auto EFI_NO_MEDIA = 12 | high_bit;
constexpr auto EFI_MEDIA_CHANGED = 13 | high_bit;
constexpr auto EFI_NOT_FOUND = 14 | high_bit;
constexpr auto EFI_ACCESS_DENIED = 15 | high_bit;
constexpr auto EFI_NO_RESPONSE = 16 | high_bit;
constexpr auto EFI_NO_MAPPING = 17 | high_bit;
constexpr auto EFI_TIMEOUT = 18 | high_bit;
constexpr auto EFI_NOT_STARTED = 19 | high_bit;
constexpr auto EFI_ALREADY_STARTED = 20 | high_bit;
constexpr auto EFI_ABORTED = 21 | high_bit;
constexpr auto EFI_ICMP_ERROR = 22 | high_bit;
constexpr auto EFI_TFTP_ERROR = 23 | high_bit;
constexpr auto EFI_PROTOCOL_ERROR = 24 | high_bit;
constexpr auto EFI_INCOMPATIBLE_VERSION = 25 | high_bit;
constexpr auto EFI_SECURITY_VIOLATION = 26 | high_bit;
constexpr auto EFI_CRC_ERROR = 27 | high_bit;
constexpr auto EFI_END_OF_MEDIA = 28 | high_bit;
constexpr auto EFI_END_OF_FILE = 31 | high_bit;
constexpr auto EFI_INVALID_LANGUAGE = 32 | high_bit;
constexpr auto EFI_COMPROMISED_DATA = 33 | high_bit;
constexpr auto EFI_IP_ADDRESS_CONFLICT = 34 | high_bit;
constexpr auto EFI_HTTP_ERROR = 35 | high_bit;

struct EFI_SYSTEM_TABLE;

extern EFI_SYSTEM_TABLE * system_table;
extern EFI_HANDLE image_handle;

inline void initialize(EFI_SYSTEM_TABLE * table, EFI_HANDLE handle)
{
    system_table = table;
    image_handle = handle;
}

void * open_protocol_by_guid(EFI_HANDLE, const EFI_GUID &);
void * open_protocol_by_guid(const EFI_GUID &);
}

#define PROTO_GUID(PROTO) EFI_##PROTO##_PROTOCOL_GUID
#define PROTOCOL(PROTO) EFI_##PROTO##_PROTOCOL
#define FIND_PROTOCOL_FROM_HANDLE(HANDLE, PROTO)                                                                       \
    (reinterpret_cast<PROTOCOL(PROTO) *>(::efi_loader::open_protocol_by_guid(HANDLE, PROTO_GUID(PROTO))))
#define FIND_PROTOCOL(PROTO)                                                                                           \
    (reinterpret_cast<PROTOCOL(PROTO) *>(::efi_loader::open_protocol_by_guid(PROTO_GUID(PROTO))))
