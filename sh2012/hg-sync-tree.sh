#!/bin/sh
set -x
hglog="/var/log/repo-sync/hg-sync.log"
export http_proxy=http://proxy_in_your_company:_port

echo "---------------------------------------------------" >> $hglog
repoName="xen-unstable-staging"
echo `date +%F` `date +%a` `date +%T` : pull $repoName begin >> $hglog
hgurl=http://xenbits.xen.org/staging/xen-unstable.hg
if [ ! -d /home/repo/snapshots/xen-unstable-staging.hg ]; then
    hg clone $hgurl /home/repo/snapshots/xen-unstable-staging.hg
fi
cd /home/repo/snapshots/xen-unstable-staging.hg
hg pull -u  >> $hglog 2>&1
if [ $? -ne 0 ]; then
    echo "hg fail: $repoName" | mutt -s "$repoName: hg pull failed" -a $hglog  -- smile665@gmail.com
fi
rsync -av --delete /home/repo/snapshots/xen-unstable-staging.hg /home/repo/pub/ >> $hglog 2>&1
echo `date +%F` `date +%a` `date +%T` : pull $repoName finish >> $hglog
echo "" >> $hglog


echo "---------------------------------------------------" >> $hglog
repoName="xen-unstable"
echo `date +%F` `date +%a` `date +%T` : pull $repoName begin >> $hglog
hgurl=http://xenbits.xen.org/xen-unstable.hg
if [ ! -d /home/repo/snapshots/xen-unstable.hg ]; then
    hg clone $hgurl /home/repo/snapshots/xen-unstable.hg
fi
cd /home/repo/snapshots/xen-unstable.hg
hg pull -u  >> $hglog 2>&1
if [ $? -ne 0 ]; then
    echo "hg fail: $repoName" | mutt -s "$repoName: hg pull failed" -a $hglog -- smile665@gmail.com
fi
rsync -av --delete /home/repo/snapshots/xen-unstable.hg /home/repo/pub/ >> $hglog 2>&1
echo `date +%F` `date +%a` `date +%T` : pull $repoName finish >> $hglog
echo "" >> $hglog


echo "---------------------------------------------------" >> $hglog
repoName="tboot"
echo `date +%F` `date +%a` `date +%T` : pull $repoName begin >> $hglog
hgurl=http://www.bughost.org/repos.hg/tboot.hg
if [ ! -d /home/repo/snapshots/tboot.hg ]; then
    hg clone $hgurl /home/repo/snapshots/tboot.hg
fi
cd /home/repo/snapshots/tboot.hg
hg pull -u  >> $hglog 2>&1
if [ $? -ne 0 ]; then
    echo "hg fail: $repoName" | mutt -s "$repoName: hg pull failed" -a $hglog -- smile665@gmail.com
fi
rsync -av --delete /home/repo/snapshots/tboot.hg /home/repo/pub/ >> $hglog 2>&1
echo `date +%F` `date +%a` `date +%T` : pull $repoName finish >> $hglog
echo "" >> $hglog


echo "---------------------------------------------------" >> $hglog
export http_proxy='' 
repoName="vmm_tree"
echo `date +%F` `date +%a` `date +%T` : pull $repoName begin >> $hglog
hgurl=http://my_local_site/xen/vmm_tree
if [ ! -d /home/repo/snapshots/vmm_tree.hg ]; then
    hg clone $hgurl /home/repo/snapshots/vmm_tree.hg
fi
cd /home/repo/snapshots/vmm_tree.hg
hg pull -u  >> $hglog 2>&1
if [ $? -ne 0 ]; then
    echo "hg fail: $repoName" | mutt -s "$repoName: hg pull failed" -a $hglog -- smile665@gmail.com
fi
rsync -av --delete /home/repo/snapshots/vmm_tree.hg /home/repo/pub/ >> $hglog 2>&1
echo `date +%F` `date +%a` `date +%T` : pull $repoName finish >> $hglog
echo "" >> $hglog

echo "update hg-index.html" >> $hglog
export http_proxy=''
wget http://localhost/hg -O /var/www/html/hg-index.html
if [ $? -ne 0 ]; then
    echo "update hg-index.html failed." | mutt -s "update hg-index.html failed." -a $hglog -- smile665@gmail.com
fi

echo "" >> $hglog
