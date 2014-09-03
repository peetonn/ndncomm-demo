#!/bin/sh
NFD1_IP="10.10.0.1"
NFD2_IP="10.10.0.2"
NFD3_IP="10.10.0.3"
PROD_NFD1_IP="10.10.0.8"
PROD_NFD22_IP="10.10.0.4"
PROD_NFD21_IP="10.10.0.6"	
PROD_NFD31_IP="10.10.0.5"
PROD_NFD32_IP="10.10.0.7"

PROD_NFD1="ndncomm"
PROD_NFD21="remap1"
PROD_NFD22="remap2"
PROD_NFD31="demo1"
PROD_NFD32="demo2"

PREFIX="/test"
NDNRTCPREFIX="${PREFIX}/ndnrtc/user"

function registerPrefix()
{
	local prefix=$1
	local ip=$2
	local cost=$3
	
	ndndc add $prefix udp $ip
}

function setupHttpServer()
{
	#local bindip=$1
	#nfd-status-http-server -a $bindip &
	echo ""
}

function setupNfd1()
{
	# register producer-1  on nfd-2 and nfd-3
	c1="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD2_IP 1"
	c2="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD3_IP 2"
	
	# register producer-2 on nfd-2 and nfd-3
	c3="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD2_IP 1"
	c4="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD3_IP 2"

	# register ndncomm producer 
	c5="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1} $PROD_NFD1_IP 0"
	
	echo $c1
	echo $c2
	echo $c3
	echo $c4
	echo $c5	
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4
	eval $c5

	setupHttpServer $NFD1_IP
}

function setupNfd2()
{
	# register producer-1 and producer-2
	c1="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $PROD_NFD21_IP 0"
	c2="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $PROD_NFD22_IP 0"
	
	# register producer ndncomm for nfd-1
	c3="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1_IP} $NFD1_IP 1"
	
	# register producer ndncomm for nfd-2
	c4="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1_IP} $NFD3_IP 2"
	
	echo $c1
	echo $c2
	echo $c3
	echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4

	setupHttpServer $NFD2_IP	
}

function setupNfd3()
{
	# register producer-1 on nfd-1 and nfd-2
	c1="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD1_IP 2"
	c2="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD2_IP 1"

	# register producer-2 on nfd-1 and nfd-2
	c3="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD1_IP 2"
	c4="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD2_IP 1"
	
	# register producer ndncomm on nfd-1 and nfd-2
	c5="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1} $NFD1_IP 1"
	c6="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1} $NFD2_IP 2"
	
	# register demo producers
	c7="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD31} $PROD_NFD31_IP 0"
	c8="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD32} $PROD_NFD32_IP 0"
	
	echo $c1
	echo $c2
	echo $c3
	echo $c4
	echo $c5
	echo $c6
	echo $c7
	echo $c8
	
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

function setupDemo1()
{
	# establish routes for all possible producers:
	# ndncomm
	c1="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1} $NFD3_IP 0"
	# producer-1
	c2="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD3_IP 0"	
	# producer-2
	c3="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD3_IP 0"	
	# demo-2
	c4="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD32} $NFD3_IP 0"		
	
	echo $c1
	echo $c2
	echo $c3
	echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4	

	setupHttpServer $PROD_NFD31_IP
}

function setupDemo2()
{
	# establish routes for all possible producers:
	# ndncomm
	c1="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD1} $NFD3_IP 0"
	# producer-1
	c2="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD21} $NFD3_IP 0"	
	# producer-2
	c3="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD22} $NFD3_IP 0"	
	# demo-2
	c4="registerPrefix ${NDNRTCPREFIX}/${PROD_NFD31} $NFD3_IP 0"		
	
	echo $c1
	echo $c2
	echo $c3
	echo $c4
	
	eval $c1
	eval $c2
	eval $c3
	eval $c4	

	setupHttpServer $PROD_NFD32_IP
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

        demo1)
            setupDemo1
            ;;
            
        demo2)
            setupDemo2
            ;;            
        *)
            echo $"Usage: $0 {nfd1|nfd2|nfd3|demo1|demo2}"
            exit 1
esac