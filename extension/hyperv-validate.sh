#!/usr/bin/env bash
set -Eeuo pipefail

# ext-default-enabled: no

echo 'Hyper-V Support:'

check_flags \
	HYPERV \
	HYPERV_BALLOON \
	HYPERV_KEYBOARD \
	HYPERV_NET \
	HYPERV_STORAGE \
	HYPERV_TIMER \
	HYPERV_UTILS \
	VSOCKETS \
	HYPERV_VSOCKETS \
	PCI_HYPERV \
	PCI_HYPERV_INTERFACE

echo

CODE=${EXITCODE}
EXITCODE=0

echo 'Hyper-V Optional:'

check_flags \
	DRM \
	DRM_HYPERV \
	HID \
	HID_HYPERV_MOUSE \
	HYPERV_IOMMU

echo

EXITCODE=$CODE

echo 'Hyper-V BUG:'

check_no_flags \
	FB_HYPERV

echo
