#!/usr/bin/env bash
set -Eeuo pipefail

check_str SYSTEM_TRUSTED_KEYS ""

if kern_ver_ge 5 13; then
	check_str SYSTEM_REVOCATION_KEYS ""
fi

check_num_eq FRAME_WARN 0

check_flags \
	DEBUG_INFO

if kern_ver_ge 5 15; then
	check_flags WERROR
else
	skip_flag WERROR
fi

check_no_flags \
	SECURITY_DMESG_RESTRICT \
	DEBUG_INFO_REDUCED

echo
