#!/usr/bin/env bash
set -Eeuo pipefail

# though not necessary, it is still good to have them
module_flags \
	VSOCKETS \
	HYPERV

enable_flags \
	HYPERV_IOMMU \
	HYPERV_TIMER

module_flags \
	HYPERV_BALLOON \
	HYPERV_KEYBOARD \
	HYPERV_NET \
	HYPERV_STORAGE \
	HYPERV_UTILS \
	HYPERV_VSOCKETS \
	PCI_HYPERV \
	PCI_HYPERV_INTERFACE

# module_flags \
# 	DRM \
# 	DRM_HYPERV

module_flags \
	HID \
	HID_HYPERV_MOUSE

disable_flags \
	FB_HYPERV