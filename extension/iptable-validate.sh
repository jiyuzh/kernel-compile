#!/usr/bin/env bash
set -Eeuo pipefail

echo 'Netfilter Engine:'

check_flags \
	NETFILTER \
	NETFILTER_ADVANCED \
	BRIDGE_NETFILTER

echo

echo 'Core Netfilter Configuration:'

check_flags \
	NETFILTER_INGRESS \
	NETFILTER_FAMILY_BRIDGE \
	NETFILTER_FAMILY_ARP \
	NF_CONNTRACK_MARK \
	NF_CONNTRACK_SECMARK \
	NF_CONNTRACK_ZONES \
	NF_CONNTRACK_PROCFS \
	NF_CONNTRACK_EVENTS \
	NF_CONNTRACK_TIMEOUT \
	NF_CONNTRACK_TIMESTAMP \
	NF_CONNTRACK_LABELS \
	NF_CT_PROTO_DCCP \
	NF_CT_PROTO_SCTP \
	NF_CT_PROTO_UDPLITE \
	NETFILTER_NETLINK_GLUE_CT \
	NF_NAT_NEEDED \
	NF_NAT_PROTO_DCCP \
	NF_NAT_PROTO_UDPLITE \
	NF_NAT_PROTO_SCTP \
	NF_NAT_REDIRECT \
	NF_TABLES_INET \
	NF_TABLES_NETDEV \
	NETFILTER_NETLINK \
	NETFILTER_NETLINK_ACCT \
	NETFILTER_NETLINK_QUEUE \
	NETFILTER_NETLINK_LOG \
	NETFILTER_NETLINK_OSF \
	NF_CONNTRACK \
	NF_LOG_COMMON \
	NF_LOG_NETDEV \
	NETFILTER_CONNCOUNT \
	NF_CT_PROTO_GRE \
	NF_CONNTRACK_AMANDA \
	NF_CONNTRACK_FTP \
	NF_CONNTRACK_H323 \
	NF_CONNTRACK_IRC \
	NF_CONNTRACK_BROADCAST \
	NF_CONNTRACK_NETBIOS_NS \
	NF_CONNTRACK_SNMP \
	NF_CONNTRACK_PPTP \
	NF_CONNTRACK_SANE \
	NF_CONNTRACK_SIP \
	NF_CONNTRACK_TFTP \
	NF_CT_NETLINK \
	NF_CT_NETLINK_TIMEOUT \
	NF_CT_NETLINK_HELPER \
	NF_NAT \
	NF_NAT_AMANDA \
	NF_NAT_FTP \
	NF_NAT_IRC \
	NF_NAT_SIP \
	NF_NAT_TFTP \
	NETFILTER_SYNPROXY \
	NF_TABLES \
	NF_TABLES_SET \
	NFT_NUMGEN \
	NFT_CT \
	NFT_FLOW_OFFLOAD \
	NFT_COUNTER \
	NFT_CONNLIMIT \
	NFT_LOG \
	NFT_LIMIT \
	NFT_MASQ \
	NFT_REDIR \
	NFT_NAT \
	NFT_TUNNEL \
	NFT_OBJREF \
	NFT_QUEUE \
	NFT_QUOTA \
	NFT_REJECT \
	NFT_REJECT_INET \
	NFT_COMPAT \
	NFT_HASH \
	NFT_FIB \
	NFT_FIB_INET \
	NFT_SOCKET \
	NFT_OSF \
	NFT_TPROXY \
	NF_DUP_NETDEV \
	NFT_DUP_NETDEV \
	NFT_FWD_NETDEV \
	NFT_FIB_NETDEV \
	NF_FLOW_TABLE_INET \
	NF_FLOW_TABLE \
	NETFILTER_XTABLES

echo

echo 'Xtables combined modules:'

check_flags \
	NETFILTER_XT_MARK \
	NETFILTER_XT_CONNMARK \
	NETFILTER_XT_SET

echo

echo 'Xtables targets:'

check_flags \
	NETFILTER_XT_TARGET_AUDIT \
	NETFILTER_XT_TARGET_CHECKSUM \
	NETFILTER_XT_TARGET_CLASSIFY \
	NETFILTER_XT_TARGET_CONNMARK \
	NETFILTER_XT_TARGET_CONNSECMARK \
	NETFILTER_XT_TARGET_CT \
	NETFILTER_XT_TARGET_DSCP \
	NETFILTER_XT_TARGET_HL \
	NETFILTER_XT_TARGET_HMARK \
	NETFILTER_XT_TARGET_IDLETIMER \
	NETFILTER_XT_TARGET_LED \
	NETFILTER_XT_TARGET_LOG \
	NETFILTER_XT_TARGET_MARK \
	NETFILTER_XT_NAT \
	NETFILTER_XT_TARGET_NETMAP \
	NETFILTER_XT_TARGET_NFLOG \
	NETFILTER_XT_TARGET_NFQUEUE \
	NETFILTER_XT_TARGET_NOTRACK \
	NETFILTER_XT_TARGET_RATEEST \
	NETFILTER_XT_TARGET_REDIRECT \
	NETFILTER_XT_TARGET_TEE \
	NETFILTER_XT_TARGET_TPROXY \
	NETFILTER_XT_TARGET_TRACE \
	NETFILTER_XT_TARGET_SECMARK \
	NETFILTER_XT_TARGET_TCPMSS \
	NETFILTER_XT_TARGET_TCPOPTSTRIP

echo

echo 'Xtables matches:'

check_flags \
	IP_VS_IPV6 \
	IP_VS_DEBUG \
	NETFILTER_XT_MATCH_ADDRTYPE \
	NETFILTER_XT_MATCH_BPF \
	NETFILTER_XT_MATCH_CGROUP \
	NETFILTER_XT_MATCH_CLUSTER \
	NETFILTER_XT_MATCH_COMMENT \
	NETFILTER_XT_MATCH_CONNBYTES \
	NETFILTER_XT_MATCH_CONNLABEL \
	NETFILTER_XT_MATCH_CONNLIMIT \
	NETFILTER_XT_MATCH_CONNMARK \
	NETFILTER_XT_MATCH_CONNTRACK \
	NETFILTER_XT_MATCH_CPU \
	NETFILTER_XT_MATCH_DCCP \
	NETFILTER_XT_MATCH_DEVGROUP \
	NETFILTER_XT_MATCH_DSCP \
	NETFILTER_XT_MATCH_ECN \
	NETFILTER_XT_MATCH_ESP \
	NETFILTER_XT_MATCH_HASHLIMIT \
	NETFILTER_XT_MATCH_HELPER \
	NETFILTER_XT_MATCH_HL \
	NETFILTER_XT_MATCH_IPCOMP \
	NETFILTER_XT_MATCH_IPRANGE \
	NETFILTER_XT_MATCH_IPVS \
	NETFILTER_XT_MATCH_L2TP \
	NETFILTER_XT_MATCH_LENGTH \
	NETFILTER_XT_MATCH_LIMIT \
	NETFILTER_XT_MATCH_MAC \
	NETFILTER_XT_MATCH_MARK \
	NETFILTER_XT_MATCH_MULTIPORT \
	NETFILTER_XT_MATCH_NFACCT \
	NETFILTER_XT_MATCH_OSF \
	NETFILTER_XT_MATCH_OWNER \
	NETFILTER_XT_MATCH_POLICY \
	NETFILTER_XT_MATCH_PHYSDEV \
	NETFILTER_XT_MATCH_PKTTYPE \
	NETFILTER_XT_MATCH_QUOTA \
	NETFILTER_XT_MATCH_RATEEST \
	NETFILTER_XT_MATCH_REALM \
	NETFILTER_XT_MATCH_RECENT \
	NETFILTER_XT_MATCH_SCTP \
	NETFILTER_XT_MATCH_SOCKET \
	NETFILTER_XT_MATCH_STATE \
	NETFILTER_XT_MATCH_STATISTIC \
	NETFILTER_XT_MATCH_STRING \
	NETFILTER_XT_MATCH_TCPMSS \
	NETFILTER_XT_MATCH_TIME \
	NETFILTER_XT_MATCH_U32 \
	IP_SET \
	IP_SET_BITMAP_IP \
	IP_SET_BITMAP_IPMAC \
	IP_SET_BITMAP_PORT \
	IP_SET_HASH_IP \
	IP_SET_HASH_IPMARK \
	IP_SET_HASH_IPPORT \
	IP_SET_HASH_IPPORTIP \
	IP_SET_HASH_IPPORTNET \
	IP_SET_HASH_IPMAC \
	IP_SET_HASH_MAC \
	IP_SET_HASH_NETPORTNET \
	IP_SET_HASH_NET \
	IP_SET_HASH_NETNET \
	IP_SET_HASH_NETPORT \
	IP_SET_HASH_NETIFACE \
	IP_SET_LIST_SET \
	IP_VS

# set_flag_num IP_SET_MAX 256
# set_flag_num IP_VS_TAB_BITS 12

echo

echo 'IPVS transport protocol load balancing support:'

check_flags \
	IP_VS_PROTO_TCP \
	IP_VS_PROTO_UDP \
	IP_VS_PROTO_AH_ESP \
	IP_VS_PROTO_ESP \
	IP_VS_PROTO_AH \
	IP_VS_PROTO_SCTP

echo

echo 'IPVS scheduler:'

check_flags \
	IP_VS_RR \
	IP_VS_WRR \
	IP_VS_LC \
	IP_VS_WLC \
	IP_VS_FO \
	IP_VS_OVF \
	IP_VS_LBLC \
	IP_VS_LBLCR \
	IP_VS_DH \
	IP_VS_SH \
	IP_VS_MH \
	IP_VS_SED \
	IP_VS_NQ

echo

# echo 'IPVS SH scheduler:'

# set_flag_num IP_VS_SH_TAB_BITS 8

# echo

# echo 'IPVS MH scheduler:'

# set_flag_num IP_VS_MH_TAB_INDEX 12

# echo

echo 'IPVS application helper:'

check_flags \
	IP_VS_NFCT \
	IP_VS_FTP \
	IP_VS_PE_SIP

echo

echo 'IP: Netfilter Configuration:'

check_flags \
	NF_TABLES_IPV4 \
	NF_TABLES_ARP \
	NF_NAT_MASQUERADE_IPV4 \
	NF_DEFRAG_IPV4 \
	NF_SOCKET_IPV4 \
	NF_TPROXY_IPV4 \
	NFT_CHAIN_ROUTE_IPV4 \
	NFT_REJECT_IPV4 \
	NFT_DUP_IPV4 \
	NFT_FIB_IPV4 \
	NF_FLOW_TABLE_IPV4 \
	NF_DUP_IPV4 \
	NF_LOG_ARP \
	NF_LOG_IPV4 \
	NF_REJECT_IPV4 \
	NF_NAT_IPV4 \
	NFT_CHAIN_NAT_IPV4 \
	NFT_MASQ_IPV4 \
	NFT_REDIR_IPV4 \
	NF_NAT_SNMP_BASIC \
	NF_NAT_PROTO_GRE \
	NF_NAT_PPTP \
	NF_NAT_H323 \
	IP_NF_IPTABLES \
	IP_NF_MATCH_AH \
	IP_NF_MATCH_ECN \
	IP_NF_MATCH_RPFILTER \
	IP_NF_MATCH_TTL \
	IP_NF_FILTER \
	IP_NF_TARGET_REJECT \
	IP_NF_TARGET_SYNPROXY \
	IP_NF_NAT \
	IP_NF_TARGET_MASQUERADE \
	IP_NF_TARGET_NETMAP \
	IP_NF_TARGET_REDIRECT \
	IP_NF_MANGLE \
	IP_NF_TARGET_CLUSTERIP \
	IP_NF_TARGET_ECN \
	IP_NF_TARGET_TTL \
	IP_NF_RAW \
	IP_NF_SECURITY \
	IP_NF_ARPTABLES \
	IP_NF_ARPFILTER \
	IP_NF_ARP_MANGLE

echo

echo 'IPv6: Netfilter Configuration:'

check_flags \
	NF_TABLES_IPV6 \
	NF_NAT_MASQUERADE_IPV6 \
	NF_TABLES_BRIDGE \
	BPFILTER \
	NF_SOCKET_IPV6 \
	NF_TPROXY_IPV6 \
	NFT_CHAIN_ROUTE_IPV6 \
	NFT_CHAIN_NAT_IPV6 \
	NFT_MASQ_IPV6 \
	NFT_REDIR_IPV6 \
	NFT_REJECT_IPV6 \
	NFT_DUP_IPV6 \
	NFT_FIB_IPV6 \
	NF_FLOW_TABLE_IPV6 \
	NF_DUP_IPV6 \
	NF_REJECT_IPV6 \
	NF_LOG_IPV6 \
	NF_NAT_IPV6 \
	IP6_NF_IPTABLES \
	IP6_NF_MATCH_AH \
	IP6_NF_MATCH_EUI64 \
	IP6_NF_MATCH_FRAG \
	IP6_NF_MATCH_OPTS \
	IP6_NF_MATCH_HL \
	IP6_NF_MATCH_IPV6HEADER \
	IP6_NF_MATCH_MH \
	IP6_NF_MATCH_RPFILTER \
	IP6_NF_MATCH_RT \
	IP6_NF_MATCH_SRH \
	IP6_NF_TARGET_HL \
	IP6_NF_FILTER \
	IP6_NF_TARGET_REJECT \
	IP6_NF_TARGET_SYNPROXY \
	IP6_NF_MANGLE \
	IP6_NF_RAW \
	IP6_NF_SECURITY \
	IP6_NF_NAT \
	IP6_NF_TARGET_MASQUERADE \
	IP6_NF_TARGET_NPT \
	NF_DEFRAG_IPV6 \
	NFT_BRIDGE_REJECT \
	NF_LOG_BRIDGE \
	BRIDGE_NF_EBTABLES \
	BRIDGE_EBT_BROUTE \
	BRIDGE_EBT_T_FILTER \
	BRIDGE_EBT_T_NAT \
	BRIDGE_EBT_802_3 \
	BRIDGE_EBT_AMONG \
	BRIDGE_EBT_ARP \
	BRIDGE_EBT_IP \
	BRIDGE_EBT_IP6 \
	BRIDGE_EBT_LIMIT \
	BRIDGE_EBT_MARK \
	BRIDGE_EBT_PKTTYPE \
	BRIDGE_EBT_STP \
	BRIDGE_EBT_VLAN \
	BRIDGE_EBT_ARPREPLY \
	BRIDGE_EBT_DNAT \
	BRIDGE_EBT_MARK_T \
	BRIDGE_EBT_REDIRECT \
	BRIDGE_EBT_SNAT \
	BRIDGE_EBT_LOG \
	BRIDGE_EBT_NFLOG \
	BPFILTER_UMH

echo

EXITCODE=0
