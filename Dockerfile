FROM registry.makerforce.io/ambrose/env:latest

USER root

# required for pwntools
RUN pip3 install --upgrade pip

# capstone pip version (in pwntools) conflict with capstone distro version, so install pip version first
RUN pip3 install capstone

RUN apk add --no-cache \
	libcrypto1.1@edge libssl1.1@edge radare2@community \
	volatility \
	john \
	libffi-dev libressl-dev lzo-dev linux-headers python3-dev \
	httpie \
	jq \
	socat \
	netcat-openbsd \
	binwalk@testing \
	exiftool \
	graphicsmagick \
	testdisk \
	squashfs-tools \
	libpcap

# required for pwntools
RUN wget -O /tmp/pandoc.tar.gz \
	https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-linux.tar.gz \
	&& tar -xvf /tmp/pandoc.tar.gz --strip=1 -C /usr/local \
	&& rm /tmp/pandoc.tar.gz

RUN pip3 install \
	pwntools \
	requests \
	python-lzo \
	crcmod
# lzo-dev, python-lzo and crcmod for ubidump.py
	
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
	&& tar -xvf /tmp/sqlmap.tar.gz --strip=1 -C /usr/local/lib/sqlmap \
	&& rm /tmp/sqlmap.tar.gz \
	&& ln -s /usr/local/lib/sqlmap/sqlmap.py /usr/local/bin/sqlmap
	
USER ambrose
