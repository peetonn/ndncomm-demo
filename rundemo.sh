#!/bin/sh

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESDIR="${CURDIR}/."
LIBDIR="${CURDIR}/../ndnrtc-archive"
LIBNAME="libndnrtc.0.dylib"
CFGNAME="ndnrtc.cfg"
RUNDIR="../ndnrtc-archive"
APPNAME="ndnrtc-demo"

HDCOMM_DIR="ndncomm"
REMAP1_DIR="remap1"
REMAP2_DIR="remap2"
DEMO1_DIR="demo1"
DEMO2_DIR="demo2"

function assert_dir_access { 
	fail=0
    (cd ${1:?pathname expected}) || fail=1
    
    if [ "$fail" -eq "1" ]; then
    	echo ${2}
    	exit
    fi
}

assert_dir_access $RESDIR "    Can't find resources folder"
assert_dir_access $LIBDIR "    Please, run make && make ndnrtc-demo first"

LIBPATH="$(cd $LIBDIR && pwd)/${LIBNAME}"

function setupNdnrtc()
{
	# echo "${CURDIR}/${RUNDIR}/${APPNAME} ${LIBPATH} ${PARAMSPATH} 2> /dev/null"
	${CURDIR}/${RUNDIR}/${APPNAME} ${LIBPATH} ${PARAMSPATH} 2> /dev/null		
}

# create symbolic links for configuration files
function makeLinks()
{
    rm -f ./$HDCOMM_DIR.cfg
    ln -s $(cd "${RESDIR}/${HDCOMM_DIR}" && pwd)/${CFGNAME} ./$HDCOMM_DIR.cfg

    rm -f ./$DEMO1_DIR.cfg
    ln -s $(cd "${RESDIR}/${DEMO1_DIR}" && pwd)/${CFGNAME} ./$DEMO1_DIR.cfg

    rm -f ./$DEMO2_DIR.cfg
    ln -s $(cd "${RESDIR}/${DEMO2_DIR}" && pwd)/${CFGNAME} ./$DEMO2_DIR.cfg

    rm -f ./$REMAP1_DIR.cfg
    ln -s $(cd "${RESDIR}/${REMAP1_DIR}" && pwd)/${CFGNAME} ./$REMAP1_DIR.cfg  

    rm -f ./$REMAP2_DIR.cfg
    ln -s $(cd "${RESDIR}/${REMAP2_DIR}" && pwd)/${CFGNAME} ./$REMAP2_DIR.cfg  
}

makeLinks

case "$1" in
        ndncomm)
			PARAMSPATH="$(cd "${RESDIR}/${HDCOMM_DIR}" && pwd)/${CFGNAME}"
            setupNdnrtc 
            ;;
         
        # demo app started with demo configuration 
        # after starting publishing local stream, one should load
        # hdcomm configuration file and establish fetching from hdcomm
        # after establishing fetching from hdcomm, one should load 
        # remap1 configuration file and start fetching from remap1
        # finally, remap2 configuration should be loaded and fetching 
        # from remap2 should be performed
        demo1)
            PARAMSPATH="$(cd "${RESDIR}/${DEMO1_DIR}" && pwd)/${CFGNAME}"
            setupNdnrtc 
            ;;

        demo2)
            PARAMSPATH="$(cd "${RESDIR}/${DEMO2_DIR}" && pwd)/${CFGNAME}"
            setupNdnrtc 
            ;;            

        remap1)
			PARAMSPATH="$(cd "${RESDIR}/${REMAP1_DIR}" && pwd)/${CFGNAME}"
            setupNdnrtc
            ;;
         
        remap2)
			PARAMSPATH="$(cd "${RESDIR}/${REMAP2_DIR}" && pwd)/${CFGNAME}"
            setupNdnrtc
            ;;  
        *)
            echo $"Usage: $0 {ndncomm|remap1|remap2|demo1|demo2}"
            exit 1
esac
