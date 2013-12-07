mycard_version=1.2.9

#dependences
sudo apt-get update
sudo apt-get install python-software-properties -y
sudo wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
sudo sh -c "echo 'deb http://archive.getdeb.net/ubuntu/ precise-getdeb games' >> /etc/apt/sources.list"
sudo add-apt-repository ppa:codegear/release -y
sudo add-apt-repository ppa:chris-lea/node.js -y
sudo apt-get update
sudo apt-get install build-essential git premake4 libfreetype6-dev libevent-dev libsqlite3-dev libirrlicht1.8-dev liblua5.2-dev libgl1-mesa-dev-lts-raring libglu-dev p7zip-full nodejs -y
sudo ln -s /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/lib/liblua.so
sudo ln -s /usr/include/irrlicht1.8 /usr/include/irrlicht

#ygopro
git clone https://github.com/mycard/ygopro.git -b server
cd ygopro/
premake4 gmake
cd build/
make config=release ygopro -j2
cd ..
ln -s bin/release/ygopro ./
strip ygopro
cd ..

#ygopro lastest data
wget --user-agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" https://my-card.in/mycard/download -O mycard.7z
7z x mycard.7z mycard-$mycard_version/ygocore -y
yes | cp -rf mycard-$mycard_version/ygocore/* ygopro/
rm -rf mycard-$mycard_version mycard.7z
cd ..

#ygopro-server
git clone https://github.com/mycard/ygopro-server.git
cd ygopro-server
npm install
sudo npm install -g coffee-script forever bunyan
ln -s ../ygopro ygocore
vim config.json