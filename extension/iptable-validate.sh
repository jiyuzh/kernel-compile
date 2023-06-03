#!/usr/bin/env bash
set -Eeuo pipefail

echo 'Netfilter Engine:'

check_flags \
	CONFIG_NETFILTER \
	CONFIG_NETFILTER_ADVANCED \
	CONFIG_BRIDGE_NETFILTER

echo

echo 'Core Netfilter Configuration:'

check_flags \
	CONFIG_NETFILTER_INGRESS \
	CONFIG_NETFILTER_FAMILY_BRIDGE \
	CONFIG_NETFILTER_FAMILY_ARP \
	CONFIG_NF_CONNTRACK_MARK \
	CONFIG_NF_CONNTRACK_SECMARK \
	CONFIG_NF_CONNTRACK_ZONES \
	CONFIG_NF_CONNTRACK_PROCFS \
	CONFIG_NF_CONNTRACK_EVENTS \
	CONFIG_NF_CONNTRACK_TIMEOUT \
	CONFIG_NF_CONNTRACK_TIMESTAMP \
	CONFIG_NF_CONNTRACK_LABELS \
	CONFIG_NF_CT_PROTO_DCCP \
	CONFIG_NF_CT_PROTO_SCTP \
	CONFIG_NF_CT_PROTO_UDPLITE \
	CONFIG_NETFILTER_NETLINK_GLUE_CT \
	CONFIG_NF_NAT_NEEDED \
	CONFIG_NF_NAT_PROTO_DCCP \
	CONFIG_NF_NAT_PROTO_UDPLITE \
	CONFIG_NF_NAT_PROTO_SCTP \
	CONFIG_NF_NAT_REDIRECT \
	CONFIG_NF_TABLES_INET \
	CONFIG_NF_TABLES_NETDEV \
	CONFIG_NETFILTER_NETLINK \
	CONFIG_NETFILTER_NETLINK_ACCT \
	CONFIG_NETFILTER_NETLINK_QUEUE \
	CONFIG_NETFILTER_NETLINK_LOG \
	CONFIG_NETFILTER_NETLINK_OSF \
	CONFIG_NF_CONNTRACK \
	CONFIG_NF_LOG_COMMON \
	CONFIG_NF_LOG_NETDEV \
	CONFIG_NETFILTER_CONNCOUNT \
	CONFIG_NF_CT_PROTO_GRE \
	CONFIG_NF_CONNTRACK_AMANDA \
	CONFIG_NF_CONNTRACK_FTP \
	CONFIG_NF_CONNTRACK_H323 \
	CONFIG_NF_CONNTRACK_IRC \
	CONFIG_NF_CONNTRACK_BROADCAST \
	CONFIG_NF_CONNTRACK_NETBIOS_NS \
	CONFIG_NF_CONNTRACK_SNMP \
	CONFIG_NF_CONNTRACK_PPTP \
	CONFIG_NF_CONNTRACK_SANE \
	CONFIG_NF_CONNTRACK_SIP \
	CONFIG_NF_CONNTRACK_TFTP \
	CONFIG_NF_CT_NETLINK \
	CONFIG_NF_CT_NETLINK_TIMEOUT \
	CONFIG_NF_CT_NETLINK_HELPER \
	CONFIG_NF_NAT \
	CONFIG_NF_NAT_AMANDA \
	CONFIG_NF_NAT_FTP \
	CONFIG_NF_NAT_IRC \
	CONFIG_NF_NAT_SIP \
	CONFIG_NF_NAT_TFTP \
	CONFIG_NETFILTER_SYNPROXY \
	CONFIG_NF_TABLES \
	CONFIG_NF_TABLES_SET \
	CONFIG_NFT_NUMGEN \
	CONFIG_NFT_CT \
	CONFIG_NFT_FLOW_OFFLOAD \
	CONFIG_NFT_COUNTER \
	CONFIG_NFT_CONNLIMIT \
	CONFIG_NFT_LOG \
	CONFIG_NFT_LIMIT \
	CONFIG_NFT_MASQ \
	CONFIG_NFT_REDIR \
	CONFIG_NFT_NAT \
	CONFIG_NFT_TUNNEL \
	CONFIG_NFT_OBJREF \
	CONFIG_NFT_QUEUE \
	CONFIG_NFT_QUOTA \
	CONFIG_NFT_REJECT \
	CONFIG_NFT_REJECT_INET \
	CONFIG_NFT_COMPAT \
	CONFIG_NFT_HASH \
	CONFIG_NFT_FIB \
	CONFIG_NFT_FIB_INET \
	CONFIG_NFT_SOCKET \
	CONFIG_NFT_OSF \
	CONFIG_NFT_TPROXY \
	CONFIG_NF_DUP_NETDEV \
	CONFIG_NFT_DUP_NETDEV \
	CONFIG_NFT_FWD_NETDEV \
	CONFIG_NFT_FIB_NETDEV \
	CONFIG_NF_FLOW_TABLE_INET \
	CONFIG_NF_FLOW_TABLE \
	CONFIG_NETFILTER_XTABLES

echo

echo 'Xtables combined modules:'

check_flags \
	CONFIG_NETFILTER_XT_MARK \
	CONFIG_NETFILTER_XT_CONNMARK \
	CONFIG_NETFILTER_XT_SET

echo

echo 'Xtables targets:'

check_flags \
	CONFIG_NETFILTER_XT_TARGET_AUDIT \
	CONFIG_NETFILTER_XT_TARGET_CHECKSUM \
	CONFIG_NETFILTER_XT_TARGET_CLASSIFY \
	CONFIG_NETFILTER_XT_TARGET_CONNMARK \
	CONFIG_NETFILTER_XT_TARGET_CONNSECMARK \
	CONFIG_NETFILTER_XT_TARGET_CT \
	CONFIG_NETFILTER_XT_TARGET_DSCP \
	CONFIG_NETFILTER_XT_TARGET_HL \
	CONFIG_NETFILTER_XT_TARGET_HMARK \
	CONFIG_NETFILTER_XT_TARGET_IDLETIMER \
	CONFIG_NETFILTER_XT_TARGET_LED \
	CONFIG_NETFILTER_XT_TARGET_LOG \
	CONFIG_NETFILTER_XT_TARGET_MARK \
	CONFIG_NETFILTER_XT_NAT \
	CONFIG_NETFILTER_XT_TARGET_NETMAP \
	CONFIG_NETFILTER_XT_TARGET_NFLOG \
	CONFIG_NETFILTER_XT_TARGET_NFQUEUE \
	CONFIG_NETFILTER_XT_TARGET_NOTRACK \
	CONFIG_NETFILTER_XT_TARGET_RATEEST \
	CONFIG_NETFILTER_XT_TARGET_REDIRECT \
	CONFIG_NETFILTER_XT_TARGET_TEE \
	CONFIG_NETFILTER_XT_TARGET_TPROXY \
	CONFIG_NETFILTER_XT_TARGET_TRACE \
	CONFIG_NETFILTER_XT_TARGET_SECMARK \
	CONFIG_NETFILTER_XT_TARGET_TCPMSS \
	CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP

echo

echo 'Xtables matches:'

check_flags \
	CONFIG_IP_VS_IPV6 \
	CONFIG_IP_VS_DEBUG \
	CONFIG_NETFILTER_XT_MATCH_ADDRTYPE \
	CONFIG_NETFILTER_XT_MATCH_BPF \
	CONFIG_NETFILTER_XT_MATCH_CGROUP \
	CONFIG_NETFILTER_XT_MATCH_CLUSTER \
	CONFIG_NETFILTER_XT_MATCH_COMMENT \
	CONFIG_NETFILTER_XT_MATCH_CONNBYTES \
	CONFIG_NETFILTER_XT_MATCH_CONNLABEL \
	CONFIG_NETFILTER_XT_MATCH_CONNLIMIT \
	CONFIG_NETFILTER_XT_MATCH_CONNMARK \
	CONFIG_NETFILTER_XT_MATCH_CONNTRACK \
	CONFIG_NETFILTER_XT_MATCH_CPU \
	CONFIG_NETFILTER_XT_MATCH_DCCP \
	CONFIG_NETFILTER_XT_MATCH_DEVGROUP \
	CONFIG_NETFILTER_XT_MATCH_DSCP \
	CONFIG_NETFILTER_XT_MATCH_ECN \
	CONFIG_NETFILTER_XT_MATCH_ESP \
	CONFIG_NETFILTER_XT_MATCH_HASHLIMIT \
	CONFIG_NETFILTER_XT_MATCH_HELPER \
	CONFIG_NETFILTER_XT_MATCH_HL \
	CONFIG_NETFILTER_XT_MATCH_IPCOMP \
	CONFIG_NETFILTER_XT_MATCH_IPRANGE \
	CONFIG_NETFILTER_XT_MATCH_IPVS \
	CONFIG_NETFILTER_XT_MATCH_L2TP \
	CONFIG_NETFILTER_XT_MATCH_LENGTH \
	CONFIG_NETFILTER_XT_MATCH_LIMIT \
	CONFIG_NETFILTER_XT_MATCH_MAC \
	CONFIG_NETFILTER_XT_MATCH_MARK \
	CONFIG_NETFILTER_XT_MATCH_MULTIPORT \
	CONFIG_NETFILTER_XT_MATCH_NFACCT \
	CONFIG_NETFILTER_XT_MATCH_OSF \
	CONFIG_NETFILTER_XT_MATCH_OWNER \
	CONFIG_NETFILTER_XT_MATCH_POLICY \
	CONFIG_NETFILTER_XT_MATCH_PHYSDEV \
	CONFIG_NETFILTER_XT_MATCH_PKTTYPE \
	CONFIG_NETFILTER_XT_MATCH_QUOTA \
	CONFIG_NETFILTER_XT_MATCH_RATEEST \
	CONFIG_NETFILTER_XT_MATCH_REALM \
	CONFIG_NETFILTER_XT_MATCH_RECENT \
	CONFIG_NETFILTER_XT_MATCH_SCTP \
	CONFIG_NETFILTER_XT_MATCH_SOCKET \
	CONFIG_NETFILTER_XT_MATCH_STATE \
	CONFIG_NETFILTER_XT_MATCH_STATISTIC \
	CONFIG_NETFILTER_XT_MATCH_STRING \
	CONFIG_NETFILTER_XT_MATCH_TCPMSS \
	CONFIG_NETFILTER_XT_MATCH_TIME \
	CONFIG_NETFILTER_XT_MATCH_U32 \
	CONFIG_IP_SET \
	CONFIG_IP_SET_BITMAP_IP \
	CONFIG_IP_SET_BITMAP_IPMAC \
	CONFIG_IP_SET_BITMAP_PORT \
	CONFIG_IP_SET_HASH_IP \
	CONFIG_IP_SET_HASH_IPMARK \
	CONFIG_IP_SET_HASH_IPPORT \
	CONFIG_IP_SET_HASH_IPPORTIP \
	CONFIG_IP_SET_HASH_IPPORTNET \
	CONFIG_IP_SET_HASH_IPMAC \
	CONFIG_IP_SET_HASH_MAC \
	CONFIG_IP_SET_HASH_NETPORTNET \
	CONFIG_IP_SET_HASH_NET \
	CONFIG_IP_SET_HASH_NETNET \
	CONFIG_IP_SET_HASH_NETPORT \
	CONFIG_IP_SET_HASH_NETIFACE \
	CONFIG_IP_SET_LIST_SET \
	CONFIG_IP_VS

# set_flag_num CONFIG_IP_SET_MAX 256
# set_flag_num CONFIG_IP_VS_TAB_BITS 12

echo

echo 'IPVS transport protocol load balancing support:'

check_flags \
	CONFIG_IP_VS_PROTO_TCP \
	CONFIG_IP_VS_PROTO_UDP \
	CONFIG_IP_VS_PROTO_AH_ESP \
	CONFIG_IP_VS_PROTO_ESP \
	CONFIG_IP_VS_PROTO_AH \
	CONFIG_IP_VS_PROTO_SCTP

echo

echo 'IPVS scheduler:'

check_flags \
	CONFIG_IP_VS_RR \
	CONFIG_IP_VS_WRR \
	CONFIG_IP_VS_LC \
	CONFIG_IP_VS_WLC \
	CONFIG_IP_VS_FO \
	CONFIG_IP_VS_OVF \
	CONFIG_IP_VS_LBLC \
	CONFIG_IP_VS_LBLCR \
	CONFIG_IP_VS_DH \
	CONFIG_IP_VS_SH \
	CONFIG_IP_VS_MH \
	CONFIG_IP_VS_SED \
	CONFIG_IP_VS_NQ

echo

# echo 'IPVS SH scheduler:'

# set_flag_num CONFIG_IP_VS_SH_TAB_BITS 8

# echo

# echo 'IPVS MH scheduler:'

# set_flag_num CONFIG_IP_VS_MH_TAB_INDEX 12

# echo

echo 'IPVS application helper:'

check_flags \
	CONFIG_IP_VS_NFCT \
	CONFIG_IP_VS_FTP \
	CONFIG_IP_VS_PE_SIP

echo

echo 'IP: Netfilter Configuration:'

check_flags \
	CONFIG_NF_TABLES_IPV4 \
	CONFIG_NF_TABLES_ARP \
	CONFIG_NF_NAT_MASQUERADE_IPV4 \
	CONFIG_NF_DEFRAG_IPV4 \
	CONFIG_NF_SOCKET_IPV4 \
	CONFIG_NF_TPROXY_IPV4 \
	CONFIG_NFT_CHAIN_ROUTE_IPV4 \
	CONFIG_NFT_REJECT_IPV4 \
	CONFIG_NFT_DUP_IPV4 \
	CONFIG_NFT_FIB_IPV4 \
	CONFIG_NF_FLOW_TABLE_IPV4 \
	CONFIG_NF_DUP_IPV4 \
	CONFIG_NF_LOG_ARP \
	CONFIG_NF_LOG_IPV4 \
	CONFIG_NF_REJECT_IPV4 \
	CONFIG_NF_NAT_IPV4 \
	CONFIG_NFT_CHAIN_NAT_IPV4 \
	CONFIG_NFT_MASQ_IPV4 \
	CONFIG_NFT_REDIR_IPV4 \
	CONFIG_NF_NAT_SNMP_BASIC \
	CONFIG_NF_NAT_PROTO_GRE \
	CONFIG_NF_NAT_PPTP \
	CONFIG_NF_NAT_H323 \
	CONFIG_IP_NF_IPTABLES \
	CONFIG_IP_NF_MATCH_AH \
	CONFIG_IP_NF_MATCH_ECN \
	CONFIG_IP_NF_MATCH_RPFILTER \
	CONFIG_IP_NF_MATCH_TTL \
	CONFIG_IP_NF_FILTER \
	CONFIG_IP_NF_TARGET_REJECT \
	CONFIG_IP_NF_TARGET_SYNPROXY \
	CONFIG_IP_NF_NAT \
	CONFIG_IP_NF_TARGET_MASQUERADE \
	CONFIG_IP_NF_TARGET_NETMAP \
	CONFIG_IP_NF_TARGET_REDIRECT \
	CONFIG_IP_NF_MANGLE \
	CONFIG_IP_NF_TARGET_CLUSTERIP \
	CONFIG_IP_NF_TARGET_ECN \
	CONFIG_IP_NF_TARGET_TTL \
	CONFIG_IP_NF_RAW \
	CONFIG_IP_NF_SECURITY \
	CONFIG_IP_NF_ARPTABLES \
	CONFIG_IP_NF_ARPFILTER \
	CONFIG_IP_NF_ARP_MANGLE

echo

echo 'IPv6: Netfilter Configuration:'

check_flags \
	CONFIG_NF_TABLES_IPV6 \
	CONFIG_NF_NAT_MASQUERADE_IPV6 \
	CONFIG_NF_TABLES_BRIDGE \
	CONFIG_BPFILTER \
	CONFIG_NF_SOCKET_IPV6 \
	CONFIG_NF_TPROXY_IPV6 \
	CONFIG_NFT_CHAIN_ROUTE_IPV6 \
	CONFIG_NFT_CHAIN_NAT_IPV6 \
	CONFIG_NFT_MASQ_IPV6 \
	CONFIG_NFT_REDIR_IPV6 \
	CONFIG_NFT_REJECT_IPV6 \
	CONFIG_NFT_DUP_IPV6 \
	CONFIG_NFT_FIB_IPV6 \
	CONFIG_NF_FLOW_TABLE_IPV6 \
	CONFIG_NF_DUP_IPV6 \
	CONFIG_NF_REJECT_IPV6 \
	CONFIG_NF_LOG_IPV6 \
	CONFIG_NF_NAT_IPV6 \
	CONFIG_IP6_NF_IPTABLES \
	CONFIG_IP6_NF_MATCH_AH \
	CONFIG_IP6_NF_MATCH_EUI64 \
	CONFIG_IP6_NF_MATCH_FRAG \
	CONFIG_IP6_NF_MATCH_OPTS \
	CONFIG_IP6_NF_MATCH_HL \
	CONFIG_IP6_NF_MATCH_IPV6HEADER \
	CONFIG_IP6_NF_MATCH_MH \
	CONFIG_IP6_NF_MATCH_RPFILTER \
	CONFIG_IP6_NF_MATCH_RT \
	CONFIG_IP6_NF_MATCH_SRH \
	CONFIG_IP6_NF_TARGET_HL \
	CONFIG_IP6_NF_FILTER \
	CONFIG_IP6_NF_TARGET_REJECT \
	CONFIG_IP6_NF_TARGET_SYNPROXY \
	CONFIG_IP6_NF_MANGLE \
	CONFIG_IP6_NF_RAW \
	CONFIG_IP6_NF_SECURITY \
	CONFIG_IP6_NF_NAT \
	CONFIG_IP6_NF_TARGET_MASQUERADE \
	CONFIG_IP6_NF_TARGET_NPT \
	CONFIG_NF_DEFRAG_IPV6 \
	CONFIG_NFT_BRIDGE_REJECT \
	CONFIG_NF_LOG_BRIDGE \
	CONFIG_BRIDGE_NF_EBTABLES \
	CONFIG_BRIDGE_EBT_BROUTE \
	CONFIG_BRIDGE_EBT_T_FILTER \
	CONFIG_BRIDGE_EBT_T_NAT \
	CONFIG_BRIDGE_EBT_802_3 \
	CONFIG_BRIDGE_EBT_AMONG \
	CONFIG_BRIDGE_EBT_ARP \
	CONFIG_BRIDGE_EBT_IP \
	CONFIG_BRIDGE_EBT_IP6 \
	CONFIG_BRIDGE_EBT_LIMIT \
	CONFIG_BRIDGE_EBT_MARK \
	CONFIG_BRIDGE_EBT_PKTTYPE \
	CONFIG_BRIDGE_EBT_STP \
	CONFIG_BRIDGE_EBT_VLAN \
	CONFIG_BRIDGE_EBT_ARPREPLY \
	CONFIG_BRIDGE_EBT_DNAT \
	CONFIG_BRIDGE_EBT_MARK_T \
	CONFIG_BRIDGE_EBT_REDIRECT \
	CONFIG_BRIDGE_EBT_SNAT \
	CONFIG_BRIDGE_EBT_LOG \
	CONFIG_BRIDGE_EBT_NFLOG \
	CONFIG_BPFILTER_UMH
