#!/usr/bin/env bash
set -Eeuo pipefail

# below are from https://github.com/moby/moby/blob/2deec80/contrib/check-config.sh

echo 'Docker Necessary:'

printf -- '- '
if [ "$(stat -f -c %t /sys/fs/cgroup 2> /dev/null)" = '63677270' ]; then
	wrap_good 'cgroup hierarchy' 'cgroupv2'
	cgroupv2ControllerFile='/sys/fs/cgroup/cgroup.controllers'
	if [ -f "$cgroupv2ControllerFile" ]; then
		echo '  Controllers:'
		for controller in cpu cpuset io memory pids; do
			if grep -qE '(^| )'"$controller"'($| )' "$cgroupv2ControllerFile"; then
				echo "  - $(wrap_good "$controller" 'available')"
			else
				echo "  - $(wrap_bad "$controller" 'missing')"
			fi
		done
	else
		wrap_bad "$cgroupv2ControllerFile" 'nonexistent??'
	fi
	# TODO find an efficient way to check if cgroup.freeze exists in subdir
else
	cgroupSubsystemDir="$(sed -rne '/^[^ ]+ ([^ ]+) cgroup ([^ ]*,)?(cpu|cpuacct|cpuset|devices|freezer|memory)[, ].*$/ { s//\1/p; q }' /proc/mounts)"
	cgroupDir="$(dirname "$cgroupSubsystemDir")"
	if [ -d "$cgroupDir/cpu" ] || [ -d "$cgroupDir/cpuacct" ] || [ -d "$cgroupDir/cpuset" ] || [ -d "$cgroupDir/devices" ] || [ -d "$cgroupDir/freezer" ] || [ -d "$cgroupDir/memory" ]; then
		echo "$(wrap_good 'cgroup hierarchy' 'properly mounted') [$cgroupDir]"
	else
		if [ "$cgroupSubsystemDir" ]; then
			echo "$(wrap_bad 'cgroup hierarchy' 'single mountpoint!') [$cgroupSubsystemDir]"
		else
			wrap_bad 'cgroup hierarchy' 'nonexistent??'
		fi
		EXITCODE=1
		echo "    $(wrap_color '(see https://github.com/tianon/cgroupfs-mount)' yellow)"
	fi
fi

if [ "$(cat /sys/module/apparmor/parameters/enabled 2> /dev/null)" = 'Y' ]; then
	printf -- '- '
	if command -v apparmor_parser > /dev/null 2>&1; then
		wrap_good 'apparmor' 'enabled and tools installed'
	else
		wrap_bad 'apparmor' 'enabled, but apparmor_parser missing'
		printf '    '
		if command -v apt-get > /dev/null 2>&1; then
			wrap_color '(use "apt-get install apparmor" to fix this)'
		elif command -v yum > /dev/null 2>&1; then
			wrap_color '(your best bet is "yum install apparmor-parser")'
		else
			wrap_color '(look for an "apparmor" package for your distribution)'
		fi
		EXITCODE=1
	fi
fi

check_flags \
	NAMESPACES NET_NS PID_NS IPC_NS UTS_NS \
	CGROUPS CGROUP_CPUACCT CGROUP_DEVICE CGROUP_FREEZER CGROUP_SCHED CPUSETS MEMCG \
	KEYS \
	VETH BRIDGE BRIDGE_NETFILTER \
	IP_NF_FILTER IP_NF_TARGET_MASQUERADE \
	NETFILTER_XT_MATCH_ADDRTYPE \
	NETFILTER_XT_MATCH_CONNTRACK \
	NETFILTER_XT_MATCH_IPVS \
	NETFILTER_XT_MARK \
	IP_NF_NAT NF_NAT \
	POSIX_MQUEUE
# (POSIX_MQUEUE is required for bind-mounting /dev/mqueue into containers)

if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 8 ]); then
	check_flags DEVPTS_MULTIPLE_INSTANCES
fi

if [ "$KERNEL_MAJOR" -lt 5 ] || [ "$KERNEL_MAJOR" -eq 5 -a "$KERNEL_MINOR" -le 1 ]; then
	check_flags NF_NAT_IPV4
fi

if [ "$KERNEL_MAJOR" -lt 5 ] || [ "$KERNEL_MAJOR" -eq 5 -a "$KERNEL_MINOR" -le 2 ]; then
	check_flags NF_NAT_NEEDED
fi
# check availability of BPF_CGROUP_DEVICE support
if [ "$KERNEL_MAJOR" -ge 5 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -ge 15 ]); then
	check_flags CGROUP_BPF
fi

echo

echo 'Docker Optional:'
{
	check_flags USER_NS
	check_distro_userns
}
{
	check_flags SECCOMP
	check_flags SECCOMP_FILTER
}
{
	check_flags CGROUP_PIDS
}
{
	check_flags MEMCG_SWAP
	# Kernel v5.8+ removes MEMCG_SWAP_ENABLED.
	if [ "$KERNEL_MAJOR" -lt 5 ] || [ "$KERNEL_MAJOR" -eq 5 -a "$KERNEL_MINOR" -le 8 ]; then
		CODE=${EXITCODE}
		check_flags MEMCG_SWAP_ENABLED
		# FIXME this check is cgroupv1-specific
		if [ -e /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes ]; then
			echo "    $(wrap_color '(cgroup swap accounting is currently enabled)' bold black)"
			EXITCODE=${CODE}
		elif is_set MEMCG_SWAP && ! is_set MEMCG_SWAP_ENABLED; then
			echo "    $(wrap_color '(cgroup swap accounting is currently not enabled, you can enable it by setting boot option "swapaccount=1")' bold black)"
		fi
	else
		# Kernel v5.8+ enables swap accounting by default.
		echo "    $(wrap_color '(cgroup swap accounting is currently enabled)' bold black)"
	fi
}
{
	if is_set LEGACY_VSYSCALL_NATIVE; then
		printf -- '- '
		wrap_bad "CONFIG_LEGACY_VSYSCALL_NATIVE" 'enabled'
		echo "    $(wrap_color '(dangerous, provides an ASLR-bypassing target with usable ROP gadgets.)' bold black)"
	elif is_set LEGACY_VSYSCALL_EMULATE; then
		printf -- '- '
		wrap_good "CONFIG_LEGACY_VSYSCALL_EMULATE" 'enabled'
	elif is_set LEGACY_VSYSCALL_NONE; then
		printf -- '- '
		wrap_bad "CONFIG_LEGACY_VSYSCALL_NONE" 'enabled'
		echo "    $(wrap_color '(containers using eglibc <= 2.13 will not work. Switch to' bold black)"
		echo "    $(wrap_color ' "CONFIG_VSYSCALL_[NATIVE|EMULATE]" or use "vsyscall=[native|emulate]"' bold black)"
		echo "    $(wrap_color ' on kernel command line. Note that this will disable ASLR for the,' bold black)"
		echo "    $(wrap_color ' VDSO which may assist in exploiting security vulnerabilities.)' bold black)"
	# else Older kernels (prior to 3dc33bd30f3e, released in v4.40-rc1) do
	#      not have these LEGACY_VSYSCALL options and are effectively
	#      LEGACY_VSYSCALL_EMULATE. Even older kernels are presumably
	#      effectively LEGACY_VSYSCALL_NATIVE.
	fi
}

if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -le 5 ]); then
	check_flags MEMCG_KMEM
fi

if [ "$KERNEL_MAJOR" -lt 3 ] || ([ "$KERNEL_MAJOR" -eq 3 ] && [ "$KERNEL_MINOR" -le 18 ]); then
	check_flags RESOURCE_COUNTERS
fi

if [ "$KERNEL_MAJOR" -lt 3 ] || ([ "$KERNEL_MAJOR" -eq 3 ] && [ "$KERNEL_MINOR" -le 13 ]); then
	netprio=NETPRIO_CGROUP
else
	netprio=CGROUP_NET_PRIO
fi

if [ "$KERNEL_MAJOR" -lt 5 ]; then
	check_flags IOSCHED_CFQ CFQ_GROUP_IOSCHED
fi

check_flags \
	BLK_CGROUP BLK_DEV_THROTTLING \
	CGROUP_PERF \
	CGROUP_HUGETLB \
	NET_CLS_CGROUP $netprio \
	CFS_BANDWIDTH FAIR_GROUP_SCHED RT_GROUP_SCHED \
	IP_NF_TARGET_REDIRECT \
	IP_VS \
	IP_VS_NFCT \
	IP_VS_PROTO_TCP \
	IP_VS_PROTO_UDP \
	IP_VS_RR \
	SECURITY_SELINUX \
	SECURITY_APPARMOR

if ! is_set EXT4_USE_FOR_EXT2; then
	check_flags EXT3_FS EXT3_FS_XATTR EXT3_FS_POSIX_ACL EXT3_FS_SECURITY
	if ! is_set EXT3_FS || ! is_set EXT3_FS_XATTR || ! is_set EXT3_FS_POSIX_ACL || ! is_set EXT3_FS_SECURITY; then
		echo "    $(wrap_color '(enable these ext3 configs if you are using ext3 as backing filesystem)' bold black)"
	fi
fi

check_flags EXT4_FS EXT4_FS_POSIX_ACL EXT4_FS_SECURITY
if ! is_set EXT4_FS || ! is_set EXT4_FS_POSIX_ACL || ! is_set EXT4_FS_SECURITY; then
	if is_set EXT4_USE_FOR_EXT2; then
		echo "    $(wrap_color 'enable these ext4 configs if you are using ext3 or ext4 as backing filesystem' bold black)"
	else
		echo "    $(wrap_color 'enable these ext4 configs if you are using ext4 as backing filesystem' bold black)"
	fi
fi

echo '- Network Drivers:'
echo "  - \"$(wrap_color 'overlay' blue)\":"
check_flags VXLAN BRIDGE_VLAN_FILTERING | sed 's/^/    /'
echo '      Optional (for encrypted networks):'
check_flags CRYPTO CRYPTO_AEAD CRYPTO_GCM CRYPTO_SEQIV CRYPTO_GHASH \
	XFRM XFRM_USER XFRM_ALGO INET_ESP | sed 's/^/      /'
if [ "$KERNEL_MAJOR" -lt 5 ] || [ "$KERNEL_MAJOR" -eq 5 -a "$KERNEL_MINOR" -le 3 ]; then
	check_flags INET_XFRM_MODE_TRANSPORT | sed 's/^/      /'
fi
echo "  - \"$(wrap_color 'ipvlan' blue)\":"
check_flags IPVLAN | sed 's/^/    /'
echo "  - \"$(wrap_color 'macvlan' blue)\":"
check_flags MACVLAN DUMMY | sed 's/^/    /'
echo "  - \"$(wrap_color 'ftp,tftp client in container' blue)\":"
check_flags NF_NAT_FTP NF_CONNTRACK_FTP NF_NAT_TFTP NF_CONNTRACK_TFTP | sed 's/^/    /'

# only fail if no storage drivers available
CODE=${EXITCODE}
EXITCODE=0
STORAGE=1

echo '- Storage Drivers:'
# echo "  - \"$(wrap_color 'aufs' blue)\":"
# check_flags AUFS_FS | sed 's/^/    /'
# if ! is_set AUFS_FS && grep -q aufs /proc/filesystems; then
# 	echo "      $(wrap_color '(note that some kernels include AUFS patches but not the AUFS_FS flag)' bold black)"
# fi
# [ "$EXITCODE" = 0 ] && STORAGE=0
# EXITCODE=0

echo "  - \"$(wrap_color 'btrfs' blue)\":"
check_flags BTRFS_FS | sed 's/^/    /'
check_flags BTRFS_FS_POSIX_ACL | sed 's/^/    /'
[ "$EXITCODE" = 0 ] && STORAGE=0
EXITCODE=0

echo "  - \"$(wrap_color 'devicemapper' blue)\":"
check_flags BLK_DEV_DM DM_THIN_PROVISIONING | sed 's/^/    /'
[ "$EXITCODE" = 0 ] && STORAGE=0
EXITCODE=0

echo "  - \"$(wrap_color 'overlay' blue)\":"
check_flags OVERLAY_FS | sed 's/^/    /'
[ "$EXITCODE" = 0 ] && STORAGE=0
EXITCODE=0

# echo "  - \"$(wrap_color 'zfs' blue)\":"
# printf '    - '
# check_device /dev/zfs
# printf '    - '
# check_command zfs
# printf '    - '
# check_command zpool
# [ "$EXITCODE" = 0 ] && STORAGE=0
# EXITCODE=0

EXITCODE=$CODE
[ "$STORAGE" = 1 ] && EXITCODE=1

echo

check_limit_over() {
	if [ "$(cat "$1")" -le "$2" ]; then
		wrap_bad "- $1" "$(cat "$1")"
		wrap_color "    This should be set to at least $2, for example set: sysctl -w kernel/keys/root_maxkeys=1000000" bold black
		EXITCODE=1
	else
		wrap_good "- $1" "$(cat "$1")"
	fi
}

echo 'Limits:'
check_limit_over /proc/sys/kernel/keys/root_maxkeys 10000
echo
