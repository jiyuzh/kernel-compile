#!/usr/bin/env bash
set -Eeuo pipefail

# make libvirt happy
# https://gitweb.gentoo.org/repo/gentoo.git/tree/app-emulation/libvirt/libvirt-8.4.0.ebuild
# ditto rewrite_docker
module_flags \
	DM_MULTIPATH \
	DM_SNAPSHOT \
	MACVLAN \
	NET_CLS_CGROUP \
	VETH \
	BRIDGE \
	NET_ACT_POLICE \
	NET_CLS_FW \
	NET_CLS_U32 \
	NET_SCH_HTB \
	NET_SCH_INGRESS \
	NET_SCH_SFQ \
	KVM_INTEL \
	KVM_AMD

