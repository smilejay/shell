#!/bin/bash
# a script to install python 2.7 on CentOS 6.x system.
# CentOS 6.x has python 2.6 by default, while some software (e.g. django1.7)
# need python 2.7.

# install some necessary tools & libs
echo "install some necessary tools & libs"
yum -y groupinstall "Development tools"
yum -y install openssl-devel zlib-devel ncurses-devel bzip2-devel readline-devel
yum -y install libtool-ltdl-devel sqlite-devel tk-devel tcl-devel
sleep 5

# download and install python
version='2.7.8'
python_url="https://www.python.org/ftp/python/$version/Python-${version}.tgz"

# check current python version
echo "before installation, your python version is: $(python -V &2>1)"
python -V 2>&1 | grep "$version"
if [ $? -eq 0 ]; then
  echo "current version is the same as this installation."
  echo "Quit as no need to install."
  exit 0
fi

echo "download/build/install your python"
cd /tmp
wget --no-check-certificate $python_url
tar -zxf Python-${version}.tgz
cd Python-${version}
./configure
make -j 4
make install
sleep 5

echo "check your installed python"
python -V 2>&1 | grep "$version"
if [ $? -ne 0 ]; then
  echo "python -V is not your installed version"
  /usr/local/bin/python -V 2>&1 | grep "$version"
  if [ $? -ne 0 ]; then
    echo "installation failed. use '/usr/local/bin/python -V' to have a check"
  fi
  exit 1
fi
sleep 5

# install setuptools
echo "install setuptools"
wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py
# check easy_install version
easy_install --version
sleep 5

# install pip for the new python
echo "install pip for the new python"
easy_install pip
# check pip version
pip -V

echo "Finished. Well done!"
echo "If 'python -V' still shows the old version, you may need to re-login."
echo "And/or set /usr/local/bin in the front of your PATH environment variable."
echo "-------------------------"
