#!/bin/bash

#installing tcpreplay
rm -rf tcpreplay-4.1.0/
tar -xf ./tcpreplay-4.1.0.tar.gz
cd tcpreplay-4.1.0/
./configure
make
sudo make install


cd /users/said/

#installing ifstat
sudo apt-get install ifstat


#installing NetClassify
rm -rf NetClassify/
tar -xvzf NetClassify.tar.gz
sudo apt-get install qt4-qmake
cd NetClassify
qmake-qt4
make