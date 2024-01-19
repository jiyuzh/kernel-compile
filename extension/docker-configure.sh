#!/usr/bin/env bash
set -Eeuo pipefail

# make docker happy
# https://github.com/moby/moby/blob/master/contrib/check-config.sh
# these are configs need to be set on a null lsmod adapted BASE_CONFIG
module_flags \
	VETH \
	BRIDGE \
	BRIDGE_NETFILTER \
	IP_NF_IPTABLES \
	IP_NF_FILTER \
	NF_CONNTRACK \
	IP_NF_NAT \
	IP_NF_TARGET_MASQUERADE \
	NETFILTER_XT_MATCH_ADDRTYPE \
	NETFILTER_XT_MATCH_CONNTRACK \
	IP_VS \
	NETFILTER_XT_MATCH_IPVS \
	NETFILTER_XT_MARK \
	NF_NAT \
	NET_CLS_CGROUP

enable_flags RT_GROUP_SCHED
module_flags IP_NF_TARGET_REDIRECT

enable_flags \
	IP_VS_NFCT \
	IP_VS_PROTO_TCP \
	IP_VS_PROTO_UDP
module_flags IP_VS_RR

module_flags \
	VXLAN \
	NET_DSA \
	NET_DSA_TAG_8021Q \
	VLAN_8021Q

enable_flags BRIDGE_VLAN_FILTERING

module_flags \
	NET_KEY \
	XFRM_ALGO \
	XFRM_USER
enable_flags XFRM

module_flags \
	INET_ESP \
	INET_XFRM_MODE_TRANSPORT \
	IPVLAN \
	MACVLAN \
	DUMMY

module_flags \
	NF_CONNTRACK_FTP \
	NF_NAT_FTP \
	NF_CONNTRACK_TFTP \
	NF_NAT_TFTP

module_flags BTRFS_FS
enable_flags BTRFS_FS_POSIX_ACL
module_flags DM_THIN_PROVISIONING
module_flags OVERLAY_FS
