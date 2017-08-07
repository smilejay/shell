#!/bin/bash
set -x

sync_tree() {
    url="git://git.kernel.org/${UPSTREAMPATH}"
	
    [ -d /home/repo/${SPPATH} ] || { mkdir -p /home/repo/${SPPATH}; cd /home/repo/${SPPATH}; git init >> $GITLOG 2>&1; }
	if [ $? -ne 0 ]; then
		echo "git fail" | mutt -s "$REPNAME: git init failed" -a $GITLOG -- smile665@gmail.com
	fi

    cd /home/repo/${SPPATH}
    [ ! -f config ] && touch config
    grep -q 'otc-origin-upstream' config || cat >> config << EOF
[remote "otc-origin-upstream"]
	url = $url
	fetch = +refs/heads/*:refs/heads/*
EOF

    date >> $GITLOG
    echo "updating repository \"${REPNAME}\"..." >> $GITLOG 2>&1
    tsocks git fetch -q otc-origin-upstream >> $GITLOG 2>&1
    if [ $? -ne 0 ]; then
		echo "git fail" | mutt -s "$REPNAME: git fetch failed" -a $GITLOG -- smile665@gmail.com
    fi

    rsync -av --delete /home/repo/${SPPATH}  /home/repo/pub/ >> $GITLOG 2>&1

}

sync_tree_extern() {
    url="http://xenbits.xen.org/${UPSTREAMPATH}"
    export http_proxy=proxy_in_your_company:_port

    [ -d /home/repo/${SPPATH} ] || { mkdir -p /home/repo/${SPPATH}; cd /home/repo/${SPPATH}; git init >> $GITLOG 2>&1; }
    if [ $? -ne 0 ]; then
	echo "git fail" | mutt -s "$REPNAME: git clone failed" -a $GITLOG --  smile665@gmail.com
    fi
    cd /home/repo/${SPPATH}
    [ ! -f config ] && touch config
    grep -q 'xensource-upstream' config || cat >> config << EOF
[remote "xensource-upstream"]
    url = $url
    fetch = +refs/heads/*:refs/heads/*
EOF
    date >> $GITLOG
    echo "updating repository \"${REPNAME}\"..." >> $GITLOG 2>&1
    git fetch -q xensource-upstream >> $GITLOG 2>&1
    if [ $? -ne 0 ]; then
        echo "git fail" | mutt -s "$REPNAME: git fetch failed" -a $GITLOG -- smile665@gmail.com
    fi

    rsync -av --delete /home/repo/${SPPATH}  /home/repo/pub/ >> $GITLOG 2>&1
    export http_proxy=""
}

git_pull_extern()
{
	[ -d /home/repo/${SPPATH} ] || { echo "dir ${SPPATH} doesn't exist" | mutt -s "${SPPATH} doesn't exist" smile665@gmail.com; }
	cd /home/repo/${SPPATH}
	tsocks git pull >> $GITLOG 2>&1
	if [ $? -ne 0 ]; then
		echo "git pull fail" | mutt -s "$REPNAME: git pull failed" -a $GITLOG -- smile665@gmail.com
	fi
	rsync -av --delete /home/repo/${SPPATH}  /home/repo/pub/ >> $GITLOG 2>&1
}


PIDFILE=/home/repo/git-sync.pid
export GITLOG=/var/log/repo-sync/git-sync.log


[ -f $PIDFILE ] && echo "[git-sync-tree.sh is already running, exit]" >> $GITLOG && exit 1

trap "rm -f $PIDFILE; exit 0" INT TERM EXIT SEGV
echo $$ > $PIDFILE

echo '--start-----------------------------------------------------------------------------' >> $GITLOG
# We are syncing the tree to temporary repositories to minimize impact on published tree

export https_proxy=proxy_in_your_company:_port

UPSTREAMPATH=pub/scm/linux/kernel/git/torvalds/linux.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
sync_tree      #down for maintenance; use github.com temproarily

UPSTREAMPATH=pub/scm/virt/kvm/kvm.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
sync_tree #down for maintenance

UPSTREAMPATH=pub/scm/virt/kvm/qemu-kvm.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
sync_tree   #down for maintenance

#UPSTREAMPATH=pub/scm/linux/kernel/git/xiantao/kvm-ia64.git
#UPSTREAMPATH=pub/scm/linux/kernel/git/x86/linux-2.6-tip.git
#UPSTREAMPATH=pub/scm/linux/kernel/git/sfr/linux-next.git

UPSTREAMPATH=pub/scm/linux/kernel/git/jeremy/xen.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
sync_tree      #down for maintenance


UPSTREAMPATH=git-http/qemu-xen-unstable.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
sync_tree_extern

UPSTREAMPATH=git-http/qemu-upstream-unstable.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
git_pull_extern

UPSTREAMPATH=seabios.git
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
git_pull_extern

UPSTREAMPATH=qemu.git             #pure qemu.git upstream
REPNAME=`basename ${UPSTREAMPATH}`
SPPATH=snapshots/${REPNAME}
LOCALPATH=$UPSTREAMPATH
git_pull_extern


echo "$(date) update git-index.html" >> $GITLOG
export http_proxy=""
wget http://localhost/gitweb/gitweb.cgi -O /var/www/html/git-index.html
if [ $? -ne 0 ]; then
    echo "update git-index.html failed" | mutt -s "update git-index.html failed." -a $GITLOG -- smile665@gmail.com
fi

rm -f $PIDFILE

echo '--git sync END-------------------------------------------------------------------------------' >> $GITLOG
