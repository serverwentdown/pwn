FROM registry.makerforce.io/ambrose/env:latest

USER root

# required for pwntools
RUN pip3 install --upgrade pip

RUN apk add --no-cache \
	libcrypto1.1@edge libssl1.1@edge radare2@community \
	volatility \
	john \
	libffi-dev libressl-dev linux-headers python3-dev \
	httpie \
	jq \
	socat \
	netcat-openbsd \
	binwalk@testing \
	exiftool \
	graphicsmagick \
	testdisk \
	squashfs-tools \
	lzo-dev \
	libpcap

# required for pwntools
RUN apk add --no-cache \
	python2 \
	&& pip3 install \
	unicorn pandoc

RUN pip3 install \
	pwntools \
	requests \
	python-lzo \
	crcmod
	
RUN git clone https://github.com/bwall/HashPump.git \
	&& cd HashPump \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf HashPump

RUN git clone https://github.com/robertdavidgraham/masscan \
	&& cd masscan \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf masscan

RUN wget -O /usr/local/bin/jwt_tool.py \
	https://raw.githubusercontent.com/ticarpi/jwt_tool/master/jwt_tool.py \
	&& chmod +x /usr/local/bin/jwt_tool.py

RUN wget -O /usr/local/bin/ubidump.py \
	https://raw.githubusercontent.com/nlitsme/ubidump/master/ubidump.py \
	&& chmod +x /usr/local/bin/ubidump.py \
	&& sed -i '1s/^/#!\/usr\/bin\/env python3\n/' /usr/local/bin/ubidump.py
	
RUN wget -O /tmp/sqlmap.tar.gz \
	https://github.com/sqlmapproject/sqlmap/tarball/master \
	&& mkdir -p /usr/local/lib/sqlmap \
	&& cd /usr/local/lib/sqlmap \
	&& tar -xvf /tmp/sqlmap.tar.gz --strip=1 \
	&& rm /tmp/sqlmap.tar.gz \
	&& ln -s /usr/local/lib/sqlmap/sqlmap.py /usr/local/bin/sqlmap
	
USER ambrose
