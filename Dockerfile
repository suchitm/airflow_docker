FROM ubuntu:20.04

ENV R_VERSION=${R_VERSION:-4.0.4}
ENV TZ=America/Chicago

# set timezone for tzdata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y --no-install-recommends locales \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

RUN apt-get install -y --no-install-recommends bash \
	build-essential \
	ca-certificates \
	curl \
	git \
	libbz2-dev \
	libdb5.3-dev \
	libexpat1-dev \
	libffi-dev \ 
	libgdbm-dev \ 
	liblzma-dev \
	libncurses5-dev \ 
	libncursesw5-dev \ 
	libnss3-dev \ 
	libreadline-dev \ 
	libsqlite3-dev \ 
	libssl-dev \
	less \
	man \
	neovim \
	openssh-client \
	python3 \
	python3-pip \
	software-properties-common \
	tk-dev \
	tmux \
	wget \ 
	zlib1g-dev \
	zsh 

# airflow dependencies
RUN apt-get install -y --no-install-recommends \
	freetds-bin \
      	krb5-user \
      	ldap-utils \
      	libsasl2-2 \
      	libsasl2-modules \
	libssl1.1 \
	lsb-release \
	sasl2-bin \
	sqlite3 \
	unixodbc

RUN git clone https://github.com/suchitm/dotenv.git ~/dotenv/ && \
	ln -s ~/dotenv/dotvim/vimrc ~/.vimrc && \
	ln -s ~/dotenv/tmux/tmux.conf ~/.tmux.conf && \ 
	ln -s ~/dotvim/ ~/.vim 

# install python packages for airflow
RUN pip3 install apache-airflow==1.10.14 && \
	pip3 install apache-airflow-providers-postgres && \
	pip3 install marshmallow==2.21.0 && \
	pip3 install SQLAlchemy==1.3.23 &&

RUN airflow db init && \
	airflow users create \
		--username airflow \
		--firstname Anon \
		--lastname Anon \
		--role Admin \
		--email admin@example.com \ 
		--password airflow

#RUN apt-get install -y --no-install-recommends \ 
#	default-jdk \
#	file \
#	fonts-texgyre \
#	g++ \
#	gfortran \
#	gsfonts \
#	libbz2-dev \
#	libblas-dev \
#	libcairo2-dev \
#	libcurl4-openssl-dev \
#	libjpeg-turbo8-dev 
	#libopenblas-dev 
	#libpango1.0-dev \
	##libpcre2-dev \
#	libpng-dev \
#	libreadline-dev \
#	libssl-dev \
#	libtiff5-dev \
#	liblzma-dev \
#	libx11-dev \
#	libxml2-dev \
#	libxt-dev \
#	make \
#	pcre2-utils \
#	perl \
#	texinfo \
#	texlive-extra-utils \
#	texlive-fonts-recommended \
#	texlive-fonts-extra \
#	texlive-latex-recommended \
#	unzip \
#	x11proto-core-dev \
#	xauth \
#	xfonts-base \
#	xvfb \
#	zlib1g-dev

# install R
#RUN cd tmp/ \
#	# Download source code
#	&& curl -O https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz \
#	# Extract source code
#	&& tar -xf R-${R_VERSION}.tar.gz \
#	&& cd R-${R_VERSION} \
#	# Set compiler flags
#	&& R_PAPERSIZE=letter \
#	R_BATCHSAVE="--no-save --no-restore" \
#	R_BROWSER=xdg-open \
#	PAGER=/usr/bin/pager \
#	PERL=/usr/bin/perl \
#	R_UNZIPCMD=/usr/bin/unzip \
#	R_ZIPCMD=/usr/bin/zip \
#	R_PRINTCMD=/usr/bin/lpr \
#	LIBnn=lib \
#	AWK=/usr/bin/awk \
#	CFLAGS="-g -O2 -fstack-protector-strong -Wformat \
#		-Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
#	CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat \ 
#		-Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
#	# Configure options
#	./configure --enable-R-shlib \
#	       --enable-memory-profiling \
#	       --with-readline \
#	       --with-blas \
#	       --with-tcltk \
#	       --disable-nls \
#	       --with-recommended-packages \
#	# Build and install
#	&& make \
#	&& make install

