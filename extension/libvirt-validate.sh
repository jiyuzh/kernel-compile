#!/usr/bin/env bash
set -Eeuo pipefail

# below are a implementation of https://gitweb.gentoo.org/repo/gentoo.git/tree/app-emulation/libvirt/libvirt-8.4.0.ebuild

echo 'LibVirt FuseFS:'

check_flags \
	FUSE_FS

echo

echo 'LibVirt LVM:'

check_flags \
	BLK_DEV_DM \
	DM_MULTIPATH \
	DM_SNAPSHOT

echo

echo 'LibVirt LXC:'

check_flags \
	BLK_CGROUP \
	CGROUP_CPUACCT \
	CGROUP_DEVICE \
	CGROUP_FREEZER \
	CGROUP_NET_PRIO \
	CGROUP_PERF \
	CGROUPS \
	CGROUP_SCHED \
	CPUSETS \
	IPC_NS \
	MACVLAN \
	NAMESPACES \
	NET_CLS_CGROUP \
	NET_NS \
	PID_NS \
	POSIX_MQUEUE \
	SECURITYFS \
	USER_NS \
	UTS_NS \
	VETH

if [ "$kernelMajor" -lt 4 ] || ([ "$kernelMajor" -eq 4 ] && [ "$kernelMinor" -lt 8 ]); then
	check_flags DEVPTS_MULTIPLE_INSTANCES
fi

echo

echo 'LibVirt Networking (Basic):'

check_flags \
	BRIDGE_EBT_MARK_T \
	BRIDGE_NF_EBTABLES \
	NETFILTER_ADVANCED \
	NETFILTER_XT_CONNMARK \
	NETFILTER_XT_MARK \
	NETFILTER_XT_TARGET_CHECKSUM \
	IP_NF_FILTER \
	IP_NF_MANGLE \
	IP_NF_NAT \
	IP_NF_TARGET_MASQUERADE \
	IP6_NF_FILTER \
	IP6_NF_MANGLE \
	IP6_NF_NAT

echo

echo 'LibVirt Networking (Bandwidth Support):'

check_flags \
	BRIDGE_EBT_T_NAT \
	IP_NF_TARGET_REJECT \
	NET_ACT_POLICE \
	NET_CLS_FW \
	NET_CLS_U32 \
	NET_SCH_HTB \
	NET_SCH_INGRESS \
	NET_SCH_SFQ

echo
