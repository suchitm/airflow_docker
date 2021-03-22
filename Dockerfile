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

RUN apt-get update && \
	apt-get install -y --no-install-recommends bash \
	build-essential \
	bzip2 \
	ca-certificates \
	curl \
	freetds-bin \
	git \
      	ldap-utils \
	less \
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
      	libsasl2-2 \
      	libsasl2-modules \
	libsqlite3-dev \ 
	libssl-dev \
	liblzma-dev \
	lsb-release \
	man \
	neovim \
	openssh-client \
	postgresql \
	postgresql-contrib \
	python3-venv \
	software-properties-common \
	sqlite3 \
	tk-dev \
	tmux \
	unixodbc-dev \
	wget \ 
	zlib1g-dev \
	zsh 

# installing python 3.6.6 and making it the global python
ENV HOME="/home"
WORKDIR $HOME
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv && \
	git clone https://github.com/suchitm/dotenv.git dotenv && \
	ln -s dotenv/dotvim/vimrc .vimrc && \
	ln -s dotenv/tmux/tmux.conf .tmux.conf && \ 
	ln -s dotenv/dotvim/ .vim 

ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
RUN pyenv install 3.6.6
RUN pyenv global 3.6.6

RUN pip install --upgrade pip

# install python packages for airflow
RUN pip install apache-airflow==1.10.14 \
	apache-airflow-backport-providers-google==2020.11.13 \
	apache-airflow-backport-providers-postgres \
	apache-airflow-backport-providers-ssh \
	argcomplete==1.12.2 \
	astunparse==1.6.3 \
	attrs==20.3.0 \
	azure-storage-blob>=12.0.0 \
	boto3 \ 
	fastavro==1.2.0 \
	gcsfs \
	google-cloud-bigquery==2.6.2 \
	google-cloud-bigquery-storage==2.1.0 \
	google-cloud-pubsub==1.7.0 \
	google-cloud-secret-manager==1.0.0 \
	google-cloud-storage==1.33.0 \
	google-cloud-logging==1.15.0 \
	google-cloud-error-reporting==1.1.1

RUN pip install marshmallow==2.21.0 \
	marshmallow-sqlalchemy==0.17.1 \
	pandas==1.1.4 \
	pandas-gbq==0.14.1 \
	paramiko \ 
	py7zr==0.14.1 \
	pyodbc==4.0.30 \ 
	openpyxl==3.0.7 

RUN pip install avro==1.10.1

# airflow environment variables
ENV AIRFLOW_HOME="$HOME/airflow"
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://postgres:postgres@localhost/postgres
ENV AIRFLOW__CORE__FERNET_KEY=''
ENV AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION='true'
ENV AIRFLOW__CORE__LOAD_EXAMPLES='false'
RUN mkdir "$HOME/airflow/"

# RUN airflow db init

#RUN sed -i 's/airflow\/dags/airflow\/gcs\/dags/' /home/airflow/airflow.cfg && \
#	sed -i 's/sqlite:\/\/\/\/home\/airflow\/airflow.db/postgresql+psycopg2:\/\/postgres:postgres@localhost\/postgres/' /home/airflow/airflow.cfg && \
#	sed -i 's/SequentialExecutor/LocalExecutor/' /home/airflow/airflow.cfg 

#RUN airflow db init && \
#	airflow users create \
#		--username airflow \
#		--firstname Anon \
#		--lastname Anon \
#		--role Admin \
#		--email admin@example.com \ 
#		--password airflow

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

