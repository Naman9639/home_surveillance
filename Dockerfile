RUN set -xe
   &&  echo '#!/bin/sh' > /usr/sbin/policy-rc.d
   &&  echo 'exit 101' >> /usr/sbin/policy-rc.d
   &&  chmod +x /usr/sbin/policy-rc.d
   &&  dpkg-divert --local --rename --add /sbin/initctl
   &&  cp -a /usr/sbin/policy-rc.d /sbin/initctl
   &&  sed -i 's/^exit.*/exit 0/' /sbin/initctl
   &&  echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
   &&  echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean
   &&  echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean
   &&  echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean
   &&  echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages
   &&  echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes
RUN rm -rf /var/lib/apt/lists/*
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
CMD ["/bin/bash"]

RUN apt-get update
   &&  apt-get install -y build-essential cmake curl gfortran git graphicsmagick libgraphicsmagick1-dev libatlas-dev libavcodec-dev libavformat-dev libboost-all-dev libgtk2.0-dev libjpeg-dev liblapack-dev libswscale-dev pkg-config python-dev python-numpy python-protobuf software-properties-common zip
   &&  apt-get clean
   &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash -e
RUN git clone https://github.com/torch/distro.git ~/torch --recursive
RUN cd ~/torch
   &&  ./install.sh
   &&  cd install/bin
   &&  ./luarocks install nn
   &&  ./luarocks install dpnn
   &&  ./luarocks install image
   &&  ./luarocks install optim
   &&  ./luarocks install csvigo
   &&  ./luarocks install torchx
   &&  ./luarocks install tds
RUN cd ~
   &&  mkdir -p ocv-tmp
   &&  cd ocv-tmp
   &&  curl -L https://github.com/Itseez/opencv/archive/2.4.11.zip -o ocv.zip
   &&  unzip ocv.zip
   &&  cd opencv-2.4.11
   &&  mkdir release
   &&  cd release
   &&  cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_PYTHON_SUPPORT=ON ..
   &&  make -j8
   &&  make install
   &&  rm -rf ~/ocv-tmp
RUN cd ~
   &&  mkdir -p dlib-tmp
   &&  cd dlib-tmp
   &&  curl -L https://github.com/davisking/dlib/archive/v19.0.tar.gz -o dlib.tar.bz2
   &&  tar xf dlib.tar.bz2
   &&  cd dlib-19.0/python_examples
   &&  mkdir build
   &&  cd build
   &&  cmake ../../tools/python
   &&  cmake --build . --config Release
   &&  cp dlib.so /usr/local/lib/python2.7/dist-packages
   &&  rm -rf ~/dlib-tmp

RUN ln -s /root/torch/install/bin/* /usr/local/bin
RUN apt-get update
   &&  apt-get install -y curl git graphicsmagick python-dev python-pip python-numpy python-nose python-scipy python-pandas python-protobuf wget zip
   &&  apt-get clean
   &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD dir:769f80f6852228e5675bb5bf57c4a1f7d32ff8e95ebdf36a11b9b55b2ceb9106 in /root/openface
RUN cd ~/openface
   &&  ./models/get-models.sh
   &&  pip2 install -r requirements.txt
   &&  python2 setup.py install
   &&  pip2 install -r demos/web/requirements.txt
   &&  pip2 install -r training/requirements.txt
RUN echo 'Hello from openface :)'
VOLUME [/Users]
EXPOSE 4000/tcp 5000/tcp 80/tcp 8000/tcp 8080/tcp 9000/tcp
CMD ["--port 5000"]
/bin/bash
