#!/usr/bin/env bash
set -Eeuo pipefail

set_flag_str SYSTEM_TRUSTED_KEYS ""

if kern_ver_ge 5 13; then
	set_flag_str SYSTEM_REVOCATION_KEYS ""
fi

set_flag_num FRAME_WARN 0

enable_flags \
	DEBUG_INFO

if kern_ver_ge 5 15; then
	enable_flags WERROR
fi

disable_flags \
	SECURITY_DMESG_RESTRICT \
	DEBUG_INFO_REDUCED
