# Get system name (convert to lower case).
sys_name=`uname -s | tr '[:upper:]' '[:lower:]'`

host=`hostname`

if [ "$USER" = "" ]; then
  # Bash doesn't define $USER on certain condition. Just set it.
  USER=$LOGNAME; export USER
fi

if [ "$HOSTNAME" = "" ]; then
  HOSTNAME=`hostname -s`; export HOSTNAME
fi

# Set our path.
if [ X"${sys_name}" = X"linux" ]; then
    PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH; export PATH
elif [ X"${sys_name}" = X"sunos" ]; then
    PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:$PATH; export PATH
else
  # What is it? Use standard stuff.
  PATH=/bin:/usr/bin:/sbin:/usr/sbin

  echo "Unknown system - ${sys_name}." 1>&2
fi

if [ -d /usr/openwin/bin ]; then
    PATH=$PATH:/usr/openwin/bin
fi

if [ -d /usr/bin/X11 ]; then
    PATH=$PATH:/usr/bin/X11
fi

if [ -d /usr/X11/bin ]; then
    PATH=$PATH:/usr/X11/bin
fi

if [ -d /home/${USER}/bin ]; then
    PATH=/home/${USER}/bin:$PATH
fi

if [ -d /usr/local/bin ]; then
    PATH=$PATH:/usr/local/bin
fi

if [ -d /usr/local/sbin ]; then
    PATH=$PATH:/usr/local/sbin
fi

# Allow group writes
umask 002

# Is it interactive?
if [ "$PS1" = "" ]; then
  return;
fi

# Set standard environment.
LESS=MsQe; export LESS
PAGER=less; export PAGER

if [ "${CLEARCASE_ROOT}" = "" ]; then
    PS1='\u@\h:\w\$ '
else
   view_tag='$CLEARCASE_ROOT'
   PS1="$view_tag \! % "
fi

PS2='> '

# Set backspace key to ^H.
stty erase ^H

#
# Speed up compiles on Solaris box by by using memory based file system
# for creating tmp files.
#
TMPDIR=/tmp; export TMPDIR

# Bash aliases
alias compress='compress -v'
alias dir='ls -l'
alias h='history'
alias gzip='gzip -v --best'
alias gunzip='gunzip -v'
alias j='jobs -l'
alias path='echo $path'
alias pgp=gpg
alias uncompress='uncompress -v'
alias rm='rm -i'

if [ "$TERM" = "xterm" ]; then
    # Set the xterm's title bar.
    Xlabel() { echo -ne "\033]0;$@\007"; }

    # This function is used by cd, pushd, and popd below.
    xlabel() {
    if [ "$CLEARCASE_CMDLINE" != "" ]; then
        label=`echo "$CLEARCASE_CMDLINE" | sed 's/setview //'`
	echo -ne "\033]0;${label}:${@} \007"
    else
        echo -ne "\033]0;${host}:${@} \007" ;
    fi
    }

    cd() { builtin cd $* ; xlabel `dirs` ; }
    pushd() { builtin pushd $* ; xlabel `dirs` ; }
    popd() { builtin popd $* ; xlabel `dirs` ; }
fi

#
# Clear Case environment.
#
if [ -e /usr/atria ]; then
    PATH=$PATH:/usr/atria/bin:$HOME/bin/clearcase

    # You have to share with your peers.
    CLEARCASE_BLD_UMASK=2; export CLEARCASE_BLD_UMASK

    alias ct=cleartool
    alias gdiff='ct diff -pre -graph'
    alias lsco='cleartool lsco -avobs -cview -short 2> /dev/null'
    alias lsv='cleartool lsview'
    alias lsp='cleartool lsp'
    alias setview='cleartool setview'
    # Get a version tree for a file.
    alias tree=xlsvtree

    # What view am I looking at?
    alias pwv='printenv | grep CLEARCASE_CMDLINE'


    # Add bash ClearCase support
    if [ -f ${HOME}/.bash-cc/bashrc_cc ]; then
	. ${HOME}/.bash-cc/bashrc_cc
    fi
fi

alias g=gvim

# gkm's mkid aliases
alias aid='lid -ils'
alias eid='lid -Redit'
alias gid='lid -Rgrep'

# Tornado tcl scripts require this on Solaris.
ZHONE_BASE=/vob; export ZHONE_BASE

if [ -d ${ZHONE_BASE}/tools/sun4-solaris2/bin ]; then
    PATH=${ZHONE_BASE}/tools/sun4-solaris2/bin:$PATH
fi

if [ -d ${ZHONE_BASE}/tools/gnu/sparc-sun-solaris2.6/bin ]; then
    PATH=${ZHONE_BASE}/tools/gnu/sparc-sun-solaris2.6/bin:$PATH
fi

if [ -d ${ZHONE_BASE}/zhonetools/bin ]; then
    PATH=${ZHONE_BASE}/zhonetools/bin:$PATH
fi

EDITOR=vim; export EDITOR

alias ct='/usr/atria/bin/cleartool'
alias mt=/'usr/atria/bin/multitool'
alias cvpo='/vob/zhonetools/bin/cleanVPO.ksh'

alias cdw='cd /work/$USER/'

stty intr 
stty erase ^H
stty werase ^W
stty kill ^U

set -o vi


#
# Set up environment for building vxWorks
#
vxenv()
{
    # Get system name (convert to lower case).
    sys_name=`uname -s | tr '[:upper:]' '[:lower:]'`

    if [ X"${sys_name}" = X"linux" ]; then
	WIND_HOST_TYPE=x86-linux2; export WIND_HOST_TYPE
    elif [ X"${sys_name}" = X"sunos" ]; then
	WIND_HOST_TYPE=sun4-solaris2; export WIND_HOST_TYPE
    else
        echo "Unknown system - ${sys_name}." 1>&2
	return
    fi

    case $1 in
    5.4 )
    #
    # Set up RTI (Real Time Innovations) environment.
    # This is for VxWorks Stethoscope/Performance Pak.
    #
    if [ -d /vob/TORNADO/rti/rtilib.3.9f ]; then
        RTILIBHOME=/vob/TORNADO/rti/rtilib.3.9f; export RTILIBHOME
    fi

    WIND_BASE=${ZHONE_BASE}/TORNADO; export WIND_BASE
    WIND_REGISTRY=`hostname`; export WIND_REGISTRY
    PATH=$PATH:$WIND_BASE/host/$WIND_HOST_TYPE/bin; export PATH
    LD_LIBRARY_PATH=$WIND_BASE/host/$WIND_HOST_TYPE/lib; export LD_LIBRARY_PATH

    CONVERT=${ZHONE_BASE}/zhonetools/solaris2/bin/convert.Solaris.800a

    VXENV=$1
    ;;

    6.3 )
    WIND_PLATFORM=vxworks-6.3; export WIND_PLATFORM
    WIND_PREFERRED_PACKAGES=vxworks-6.3; export WIND_PREFERRED_PACKAGES
    WIND_HOME=${ZHONE_BASE}/TORNADO6; export WIND_HOME
    WIND_BASE=${WIND_HOME}/${WIND_PLATFORM}; export WIND_BASE
    WIND_SCOPETOOLS_BASE=${WIND_HOME}/scopetools-5.5; export WIND_SCOPETOOLS_BASE
    WIND_TOOLS=${WIND_HOME}/workbench-2.5; export WIND_TOOLS
    WIND_DFW_PATH=${WIND_TOOLS}/dfw/0145b; export WIND_DFW_PATH
    WIND_DIAB_PATH=${WIND_HOME}/diab/5.4.0.0; export WIND_DIAB_PATH
    WIND_DOCS=${WIND_HOME}/docs; export WIND_DOCS
    WIND_EXTENSIONS=${WIND_SCOPETOOLS_BASE}/extensions; export WIND_EXTENSIONS
    WIND_FOUNDATION_PATH=${WIND_TOOLS}/foundation/4.0.9; export WIND_FOUNDATION_PATH
    WIND_GNU_PATH=${WIND_HOME}/gnu/3.4.4-${WIND_PLATFORM}; export WIND_GNU_PATH
    WIND_JRE_HOME=${WIND_HOME}/jre/1.4.2/${WIND_HOST_TYPE}; export WIND_JRE_HOME
    WIND_SAMPLES=${WIND_BASE}/target/usr/apps/samples:${WIND_BASE}/target/src/demo:${WIND_SCOPETOOLS_BASE}/target/src/linux:${WIND_SCOPETOOLS_BASE}/target/src/vxworks:${WIND_TOOLS}/samples; export WIND_SAMPLES
    WIND_SCOPETOOLS_RPMS_BASE=${WIND_SCOPETOOLS_BASE}/target/RPMS; export WIND_SCOPETOOLS_RPMS_BASE
    WIND_USERMODE_AGENT_PATH=${WIND_HOME}/linux-2.x/usermode-agent/1.1; export WIND_USERMODE_AGENT_PATH
    WIND_USR=${WIND_BASE}/target/usr; export WIND_USR
    WIND_WRSV_PATH=${WIND_TOOLS}/wrsv/4.8; export WIND_WRSV_PATH
    WIND_WRWB_PATH=${WIND_TOOLS}/wrwb/platform/eclipse; export WIND_WRWB_PATH
    WRSD_LICENSE_FILE=${WIND_HOME}/license; export WRSD_LICENSE_FILE
    LD_LIBRARY_PATH=${WIND_BASE}/host/${WIND_HOST_TYPE}/lib:${WIND_SCOPETOOLS_BASE}/host/bin/${WIND_HOST_TYPE}:${WIND_TOOLS}/wrwb/platform/eclipse/${WIND_HOST_TYPE}/bin:${WIND_TOOLS}/${WIND_HOST_TYPE}/lib:${WIND_FOUNDATION_PATH}/${WIND_HOST_TYPE}/lib; export LD_LIBRARY_PATH
    PATH=$PATH:${WIND_BASE}/host/${WIND_HOST_TYPE}/bin:${WIND_BASE}/vxtest/src/scripts:${WIND_SCOPETOOLS_BASE}/host/bin/${WIND_HOST_TYPE}:${WIND_HOME}:${WIND_TOOLS}/${WIND_HOST_TYPE}/bin:${WIND_FOUNDATION_PATH}/${WIND_HOST_TYPE}/bin:${WIND_GNU_PATH}/${WIND_HOST_TYPE}/bin:${WIND_DIAB_PATH}/SUNS/bin; export PATH
    
    CONVERT=${ZHONE_BASE}/zhonetools/solaris2/bin/convert.Solaris.800a

    VXENV=$1
    ;;

    6.8 )
    COMP_CAN=can-1.5; export COMP_CAN
    COMP_IPNET2=ip_net2-6.8; export COMP_IPNET2
    COMP_MIPC=mipc-2.0; export COMP_MIPC
    COMP_NETSTACK=netstack-6.8; export COMP_NETSTACK
    COMP_SECLIBS=seclibs-1.4; export COMP_SECLIBS
    COMP_SNMP=wrsnmp-10.4; export COMP_SNMP
    COMP_WEBCLI=webcli-4.8; export COMP_WEBCLI
    COMP_WEBSERVICES=webservices-1.7; export COMP_WEBSERVICES
    COMP_WINDML=windml-5.3; export COMP_WINDML
    COMP_WLAN=wlan-3.2; export COMP_WLAN
    COMP_WRLOAD=wrload-1.0; export COMP_WRLOAD
    
    WIND_PLATFORM=vxworks-6.8; export WIND_PLATFORM
    WIND_PREFERRED_PACKAGES=vxworks-6.8; export WIND_PREFERRED_PACKAGES
    WIND_RSS_CHANNELS=http://www.windriver.com/feeds/workbench_300.xml; export WIND_RSS_CHANNELS
    WIND_HOME=${ZHONE_BASE}/TORNADO68; export WIND_HOME
    WIND_COMPONENTS=${WIND_HOME}/components; export WIND_COMPONENTS
    WIND_DIAB_PATH=${WIND_HOME}/diab/5.8.0.0; export WIND_DIAB_PATH
    WIND_DOCS=${WIND_HOME}/docs; export WIND_DOCS
    WIND_INSTALLER_HOME=${WIND_HOME}/maintenance/wrInstaller; export WIND_INSTALLER_HOME
    WRSD_LICENSE_FILE=${WIND_HOME}/license; export WRSD_LICENSE_FILE
    WRVX_COMPBASE=${WIND_HOME}/components; export WRVX_COMPBASE
    WIND_JRE_HOME=${WIND_HOME}/jre/1.5.0_11/${WIND_HOST_TYPE}; export WIND_JRE_HOME
    WIND_BASE=${WIND_HOME}/${WIND_PLATFORM}; export WIND_BASE
    WIND_TOOLS=${WIND_HOME}/workbench-3.2; export WIND_TOOLS
    WIND_UTILITIES=${WIND_HOME}/utilities-1.0; export WIND_UTILITIES
    WIND_GNU_PATH=${WIND_HOME}/gnu/4.1.2-${WIND_PLATFORM}; export WIND_GNU_PATH
    WIND_USR=${WIND_BASE}/target/usr; export WIND_USR
    WIND_DFW_PATH=${WIND_TOOLS}/dfw/0145b; export WIND_DFW_PATH
    WIND_FOUNDATION_PATH=${WIND_TOOLS}/foundation; export WIND_FOUNDATION_PATH
    WIND_SCOPETOOLS_BASE=${WIND_TOOLS}/analysis; export WIND_SCOPETOOLS_BASE
    WIND_SCOPETOOLS_RPMS_BASE=${WIND_TOOLS}/analysis/target/RPMS; export WIND_SCOPETOOLS_RPMS_BASE
    WIND_WB_SCRIPTS=${WIND_TOOLS}/scripts/; export WIND_WB_SCRIPTS
    WIND_WRLINUX_LAYERS=${WIND_TOOLS}/analysis/wrlinux; export WIND_WRLINUX_LAYERS
    WIND_WRSV_PATH=${WIND_TOOLS}/wrsysviewer/4.8; export WIND_WRSV_PATH
    WIND_WRWB_PATH=${WIND_TOOLS}/wrwb/platform/${WIND_HOST_TYPE}/eclipse; export WIND_WRWB_PATH
    WIND_COMPONENTS_INCLUDES=${WIND_COMPONENTS}/windml-5.3/h:${WIND_COMPONENTS}/webservices-1.7/h:${WIND_COMPONENTS}/webcli-4.8/target/h; export WIND_COMPONENTS_INCLUDES
    WIND_COMPONENTS_LIBNAMES=windml-5.3_dyn:windml-5.3:webservices-1.7:webcli-4.8:ip_net2-6.8; export WIND_COMPONENTS_LIBNAMES
    WIND_COMPONENTS_LIBPATHS=${WIND_COMPONENTS}/obj/vxworks-6.8/krnl/lib; export WIND_COMPONENTS_LIBPATHS
    WIND_VXCONFIG=${WIND_COMPONENTS}/windml-5.3/osconfig/vxworks:${WIND_COMPONENTS}/ip_net2-6.8/osconfig/vxworks; export WIND_VXCONFIG
    WIND_USERMODE_AGENT=${WIND_HOME}/linux-2.x/usermode-agent/bin/usermode-agent.sh; export WIND_USERMODE_AGENT
    WIND_USERMODE_AGENT_PATH=${WIND_HOME}/linux-2.x/usermode-agent; export WIND_USERMODE_AGENT_PATH
    WIND_EXTENSIONS=${WIND_COMPONENTS}/windml-5.3/extensions:${WIND_COMPONENTS}/webservices-1.7/extensions:${WIND_COMPONENTS}/webcli-4.8/extensions:${WIND_COMPONENTS}/ip_net2-6.8/extensions:${WIND_COMPONENTS}/extensions:${WIND_TOOLS}/analysis/extensions:${WIND_TOOLS}/wrsysviewer:${WIND_TOOLS}/wrwb/tools:${WIND_TOOLS}/wrwb/wrlinux:${WIND_TOOLS}/wrwb/wrhv:${WIND_TOOLS}/wrwb/vthreads:${WIND_TOOLS}/wrwb/vxworksmilshae:${WIND_TOOLS}/wrwb/vxworksmils:${WIND_TOOLS}/wrwb/vxworkscert:${WIND_TOOLS}/wrwb/vxworks653:${WIND_TOOLS}/wrwb/vxworks55:${WIND_TOOLS}/wrwb/vxworks:${WIND_TOOLS}/wrwb/wrworkbench:${WIND_HOME}/wrmscomponents/diagnostics/extensions:${WIND_HOME}/wrlinux-2.0/extensions:${WIND_HOME}/unittester-2.5/extensions:${WIND_HOME}/unittester-2.4/extensions:${WIND_HOME}/studio-2.0/extensions:${WIND_COMPONENTS}/windml-5.1/extensions:${WIND_COMPONENTS}/windml-5.0/extensions:${WIND_COMPONENTS}/windml-4.2/extensions:${WIND_COMPONENTS}/windml-4.1/extensions:${WIND_COMPONENTS}/webservices-1.5/extensions:${WIND_COMPONENTS}/webservices-1.4/extensions:${WIND_COMPONENTS}/webservices-1.3/extensions:${WIND_COMPONENTS}/webcli-4.7/extensions:${WIND_COMPONENTS}/opc-3.1/extensions:${WIND_COMPONENTS}/dcom-2.3/extensions:${WIND_DOCS}/extensions; export WIND_EXTENSIONS
    WIND_SAMPLES=${WIND_COMPONENTS}/windml-5.3/samples:${WIND_COMPONENTS}/webservices-1.7/tutorials:${WIND_COMPONENTS}/webcli-4.8/samples:${WIND_COMPONENTS}/ip_net2-6.8/samples:${WIND_USR}/apps/samples:${WIND_BASE}/target/src/demo:${WIND_SCOPETOOLS_BASE}/target/src/linux:${WIND_SCOPETOOLS_BASE}/target/src/vxworks:${WIND_TOOLS}/samples; export WIND_SAMPLES
    LD_LIBRARY_PATH=${WIND_BASE}/host/${WIND_HOST_TYPE}/lib:${WIND_TOOLS}/foundation/${WIND_HOST_TYPE}/lib:${WIND_TOOLS}/analysis/host/bin/${WIND_HOST_TYPE}:${WIND_TOOLS}/wrwb/platform/${WIND_HOST_TYPE}/eclipse/${WIND_HOST_TYPE}/bin:${WIND_TOOLS}/${WIND_HOST_TYPE}/lib; export LD_LIBRARY_PATH
    LM_A_APP_DISABLE_CACHE_READ=set; export LM_A_APP_DISABLE_CACHE_READ
    TCLLIBPATH=${WIND_BASE}/host/resource/tcl; export TCLLIBPATH
    PATH=${WIND_COMPONENTS}/windml-5.3/host/${WIND_HOST_TYPE}/bin:${WIND_COMPONENTS}/webservices-1.7/host/${WIND_HOST_TYPE}/bin:${WIND_COMPONENTS}/wrll-wrsnmp/packages/wrsnmp-10.3/host/${WIND_HOST_TYPE}/bin:${WIND_COMPONENTS}/webcli-4.8/host/${WIND_HOST_TYPE}/bin:${WIND_COMPONENTS}/ip_net2-6.8/host/${WIND_HOST_TYPE}/bin:${WIND_BASE}/host/${WIND_HOST_TYPE}/bin:${WIND_BASE}/vxtest/src/scripts:${WIND_HOME}:${WIND_UTILITIES}/${WIND_HOST_TYPE}/bin:${WIND_FOUNDATION_PATH}/${WIND_HOST_TYPE}/bin:${WIND_SCOPETOOLS_BASE}/host/bin/${WIND_HOST_TYPE}:${WIND_TOOLS}/${WIND_HOST_TYPE}/bin:${WIND_GNU_PATH}/${WIND_HOST_TYPE}/bin:${WIND_DIAB_PATH}/SUNS/bin:${WIND_FOUNDATION_PATH}/${WIND_HOST_TYPE}/bin:$PATH; export PATH
    CONVERT=${WIND_HOME}/ocd-3.2/host/${WIND_HOST_TYPE}/bin/convert
    VXENV=$1
    ;;

    * )
    echo "Usage: $0 < 5.4 | 6.3 | 6.8 >" >&2
    return
    ;;
    esac

    export VXENV

    vconv()
    {
	${CONVERT} $1 -w -b -c -a
    }
}

if [ "${VXENV}" != "" ]; then
   echo "Setting build environment for vxWorks ${VXENV}."
   vxenv ${VXENV}
fi

alias zoidescr='cd /vob/docs/ZOIDescriptions/znid/8'
alias zoitest='cd /vob/docs/ZOITestCases/znid/8'
alias zoicmscore='cd /vob/ONT/bcm963xx/userspace/private/libs/cms_core'
alias ct='cleartool'
alias xcc='xclearcase&'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


alias mconfig='/usr/bin/git --git-dir=/home/manh/.cfg --work-tre=/home/manh
