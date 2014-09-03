#!/bin/sh

# LOCAL configuration
# NFD1_IP="10.10.0.1"		# NFD-1 ip address (see demo setup slides)
# NFD2_IP="10.10.0.2"		# NFD-2 ip address
# NFD3_IP="10.10.0.3"		# NFD-3 ip address
# PROD_NFD1_IP="10.10.0.8"	# producer connected to NFD-1 (NDN-Comm live streaming)
# PROD_NFD21_IP="10.10.0.6"	# producer 1 connected to NFD-2 (remap-1)
# PROD_NFD22_IP="10.10.0.4"	# producer 2 connected to NFD-2 (remap-2)
# PROD_NFD31_IP="10.10.0.5"	# demo producer 1 connected to NFD-3
# PROD_NFD32_IP="10.10.0.7"	# demo producer 2 connected to NFD-3

# TESTBED configuration
# nfd1 
NFD1_IP="128.195.4.36" # ndn.uci
NFD1_PREFIX="/ndn/edu/uci"
# nfd2 
NFD2_IP="192.172.226.248" # ndn.caida
NFD2_PREFIX="/ndn/org/caida"
# nfd3 
NFD3_IP="128.196.203.36" # ndn.arizona
NFD3_PREFIX="/ndn/edu/arizona"
# ndncomm ip address
PROD_NFD1_IP="131.179.142.10"
# remap1 ip address
PROD_NFD21_IP="131.179.141.42"
# remap2 ip address
PROD_NFD22_IP="131.179.141.43"
# demo 1
PROD_NFD31_IP="131.179.142.11"
# demo 2
PROD_NFD32_IP="131.179.142.12"

PROD_NFD1="ndncomm"		# NFD-1 producer (NDN-Comm) producer username (in NDN-RTC)
PROD_NFD21="remap1"		# NFD-2 producer 1 (remap-1) username
PROD_NFD22="remap2"		# NFD-2 producer 2 (remap-2) username
PROD_NFD31="demo1"		# NFD-3 producer 1 (demo-1) username
PROD_NFD32="demo2"		# NFD-3 producer 2 (demo-2) username

PROD_NFD1_PREFIX="${NFD1_PREFIX}/ndnrtc/user/${PROD_NFD1}"
PROD_NFD21_PREFIX="${NFD2_PREFIX}/ndnrtc/user/${PROD_NFD21}"
PROD_NFD22_PREFIX="${NFD2_PREFIX}/ndnrtc/user/${PROD_NFD22}"
PROD_NFD31_PREFIX="${NFD3_PREFIX}/ndnrtc/user/${PROD_NFD31}"
PROD_NFD32_PREFIX="${NFD3_PREFIX}/ndnrtc/user/${PROD_NFD32}"

# registers prefix in NFD
# arg1: prefix
# arg2: ip address of the remote hub
# arg3: cost for the route defined by prefix 
function registerPrefix()
{
	local prefix=$1
	local ip=$2
	local cost=$3
	
	nfdc register -c $cost $prefix udp://$ip
}

# starts NFD HTTP server binded to IP
# arg1: binding ip address for HTPP server
function setupHttpServer()
{
	local bindip=$1
	nfd-status-http-server -a $bindip &> /dev/null &
}

# sets up NFD-1 routes:
# - registers prefixes for remap-1 and remap-2 producers for two faces:
# one pointing to NFD-2 (less costly) and the other one pointing to NFD-3 
# (more costly)
# - registers prefixes for NDN-Comm producer for the face pointing to NDN-Comm 
# machine
function setupNfd1()
{
	# register producer-1  on nfd-2 and nfd-3
	c1="registerPrefix $PROD_NFD21_PREFIX $NFD2_IP 1"
	c2="registerPrefix $PROD_NFD21_PREFIX $NFD3_IP 2"
	
	# register producer-2 on nfd-2 and nfd-3
	c3="registerPrefix $PROD_NFD22_PREFIX $NFD2_IP 1"
	c4="registerPrefix $PROD_NFD22_PREFIX $NFD3_IP 2"

	# register ndncomm producer 
	c5="registerPrefix $PROD_NFD1_PREFIX $PROD_NFD1_IP 0"
	
	# echo $c1
	# echo $c2
	# echo $c3
	# echo $c4
	# echo $c5	
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4
	eval $c5

	setupHttpServer $NFD1_IP
}

# sets up NFD-2 routes:
# - register prefixes for remap-1 and remap-2 prodcuers for two faces: 
# one pointing to remap-1 producer and the other one pointing to remap-2
# producer
# - registers prefixes for NDN-Comm producer for two faces:
# one pointing to NFD-1 (less costly) and the other one pointing to NFD-3
# (more costly)
function setupNfd2()
{
	# register producer-1 and producer-2
	c1="registerPrefix $PROD_NFD21_PREFIX $PROD_NFD21_IP 0"
	c2="registerPrefix $PROD_NFD22_PREFIX $PROD_NFD22_IP 0"
	
	# register producer ndncomm for nfd-1
	c3="registerPrefix $PROD_NFD1_PREFIX $NFD1_IP 1"
	
	# register producer ndncomm for nfd-2
	c4="registerPrefix $PROD_NFD1_PREFIX $NFD3_IP 2"
	
	# echo $c1
	# echo $c2
	# echo $c3
	# echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4

	setupHttpServer $NFD2_IP	
}

# sets up NFD-3 routes:
# - remap-1 on NFD-1 (more costly) and NFD-2 (less costly)
# - remap-2 on NFD-1 (more costly) and NFD-2 (less costly)
# - NDN-Comm on NFD-1 (less costly) and NFD-2 (more costly)
# - demo-1 on the face to demo-1 producer
# - demo-2 on the face to demo-2 producer
function setupNfd3()
{
	# register producer-1 on nfd-1 and nfd-2
	c1="registerPrefix $PROD_NFD21_PREFIX $NFD1_IP 2"
	c2="registerPrefix $PROD_NFD21_PREFIX $NFD2_IP 1"

	# register producer-2 on nfd-1 and nfd-2
	c3="registerPrefix $PROD_NFD22_PREFIX $NFD1_IP 2"
	c4="registerPrefix $PROD_NFD22_PREFIX $NFD2_IP 1"
	
	# register producer ndncomm on nfd-1 and nfd-2
	c5="registerPrefix $PROD_NFD1_PREFIX $NFD1_IP 1"
	c6="registerPrefix $PROD_NFD1_PREFIX $NFD2_IP 2"
	
	# register demo producers
	c7="registerPrefix $PROD_NFD31_PREFIX $PROD_NFD31_IP 0"
	c8="registerPrefix $PROD_NFD32_PREFIX $PROD_NFD32_IP 0"
	
	# echo $c1
	# echo $c2
	# echo $c3
	# echo $c4
	# echo $c5
	# echo $c6
	# echo $c7
	# echo $c8
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4
	eval $c5
	eval $c6
	eval $c7
	eval $c8		

	setupHttpServer $NFD3_IP	
}

function setupRouteToHub()
{
	local route=$1
	local hub_ip=$2

	c="registerPrefix ${route} ${hub_ip} 0"
	eval $c
	ndnping ndn:$route
}

function setupProducer()
{
	local producerPrefix=$1
	local hub_ip=$2	

	c1="nfdc register ${producerPrefix} udp://${hub_ip}"	
	c2="ndnping ndn:${producerPrefix} > /dev/null &"
	
	# echo $c1
	# echo $c2

	eval $c1
	eval $c2
	sleep 5
	killall ndnping
}

function setupRemap1()
{
	setupProducer $PROD_NFD21_PREFIX $NFD2_IP
}

function setupRemap2()
{
	setupProducer $PROD_NFD22_PREFIX $NFD2_IP
}

function setupNdncomm()
{
	setupProducer $PROD_NFD1_PREFIX $NFD1_IP
}

# sets routes for demo-1's local daemon:
# - remap-1, remap-2, demo-2 and NDN-Comm are on the face towards NFD-3
function setupDemo1()
{
	# establish back routes for demo1 producer
	setupProducer $PROD_NFD31_PREFIX $NFD3_IP

	# establish routes for all possible producers:
	# ndncomm
	c1="registerPrefix $PROD_NFD1_PREFIX $NFD3_IP 0"
	# producer-1
	c2="registerPrefix $PROD_NFD21_PREFIX $NFD3_IP 0"	
	# producer-2
	c3="registerPrefix $PROD_NFD22_PREFIX $NFD3_IP 0"	
	# demo-2
	# c4="registerPrefix $PROD_NFD32_PREFIX $NFD3_IP 0"
	c4="registerPrefix $PROD_NFD32_PREFIX $PROD_NFD32_IP 0"
	
	# echo $c1
	# echo $c2
	# echo $c3
	# echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4	

	setupHttpServer $PROD_NFD31_IP
}

# sets routes for demo-2's local daemon:
# - remap-1, remap-2, demo-1 and NDN-Comm are on the face towards NFD-3
function setupDemo2()
{
	# establish back routes for demo2 producer	
	setupProducer $PROD_NFD32_PREFIX $NFD3_IP

	# establish routes for all possible producers:
	# ndncomm
	c1="registerPrefix $PROD_NFD1_PREFIX $NFD3_IP 0"
	# producer-1
	c2="registerPrefix $PROD_NFD21_PREFIX $NFD3_IP 0"	
	# producer-2
	c3="registerPrefix $PROD_NFD22_PREFIX $NFD3_IP 0"	
	# demo-2
	# c4="registerPrefix $PROD_NFD31_PREFIX $NFD3_IP 0"		
	c4="registerPrefix $PROD_NFD31_PREFIX $PROD_NFD31_IP 0"
	
	# echo $c1
	# echo $c2
	# echo $c3
	# echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4	

	setupHttpServer $PROD_NFD32_IP
}

# drops link b/w NFD-3 and NFD-2
# NOTE: should be executed on NFD-3
function linkDown()
{
	c="nfdc destroy udp://${NFD2_IP}"
	# echo $c
	eval $c
}

# restores connection b/w NFD-3 and NFD-2
# NOTE: should be executed on NFD-3
function linkUp()
{
	# register producer-1 on nfd-2
	# c1="registerPrefix $PROD_NFD21_PREFIX $NFD2_IP 1"

	# # register producer-2 on nfd-2
	# c2="registerPrefix $PROD_NFD22_PREFIX $NFD2_IP 1"
	
	# # register producer ndncomm on nfd-2
	# c3="registerPrefix $PROD_NFD1_PREFIX $NFD2_IP 2"

	# register caida on nfd-2 (UA)
	# costs are taken from arizona's NFD status page
	c1="registerPrefix /ndn/org/caida $NFD2_IP 2500"

	# register producer remap on nfd-2 (UA)
	c2="registerPrefix /ndn/edu/ucla/remap $NFD2_IP 2900"

	# echo $c1
	# echo $c2

	eval $c1
	eval $c2
}

function breakSim()
{
	local timeout=$1
	while [ 1 ]; do
		linkDown
		sleep $timeout
		linkUp
		sleep $timeout
	done;
}

case "$1" in
        nfd1)
            setupNfd1
            ;;
         
        nfd2)
            setupNfd2
            ;;
         
        nfd3)
            setupNfd3
            ;;

        remap1)
			setupRemap1
			;;

        remap2)
			setupRemap2
			;;

        ndncomm)
			setupNdncomm
			;;

        demo1)
            setupDemo1
            ;;
            
        demo2)
            setupDemo2
            ;;      
        
        sim)
			breakSim 60
        	;;   

        down)
			linkDown
            ;;     

        up)
			linkUp
            ;;                  
        *)
            echo $"Usage: $0 {nfd1|nfd2|nfd3|demo1|demo2|remap1|remap2|ndncomm|down|up}"
            exit 1
esac
