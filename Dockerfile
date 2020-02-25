FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

WORKDIR /root

# Setting timezone
RUN echo "tzdata tzdata/Areas select Asia" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Asia select Jakarta" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt update && \
    apt upgrade -y && \
    apt install -y tzdata

# Installing dependencies
RUN apt install -y htop nano curl libaio1\
    libmecab2 libnuma1 perl psmisc net-tools uuid-runtime \
    gcc libpcre3-dev software-properties-common
    
# Installing webserver & php
RUN add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install -y git apache2 php7.4-common php7.4-xml php7.4-xmlrpc php7.4-curl \
    php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache \
    php7.4-soap php7.4-zip php7.4-intl libapache2-mod-php && \
    sed -i "s/.DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf && \
    a2enmod rewrite

# Installing phalcon
RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash && \
    apt update && \
    apt install php7.4-phalcon && \
    pecl install psr && \
    sed -i "s/.*;extension=bz2.*/;extension=bz2\nextension=psr.so\nextension=phalcon.so/" /etc/php/7.4/apache2/php.ini && \
    sed -i "s/.*;extension=bz2.*/;extension=bz2\nextension=psr.so\nextension=phalcon.so/" /etc/php/7.4/cli/php.ini && \
    sed -i "s/.DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf

# Installing odbc
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    bash -c "curl -s https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list" && \
    apt update && \
    ACCEPT_EULA=Y apt -y install msodbcsql17 mssql-tools && \
    apt -y install unixodbc-dev && \
    apt -y install gcc g++ make autoconf libc-dev pkg-config && \
    pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    sed -i "s/.*extension=phalcon.so.*/extension=phalcon.so\nextension=sqlsrv.so\nextension=pdo_sqlsrv.so/" /etc/php/7.4/apache2/php.ini

COPY script/ /tmp

# Configuring project
RUN cp /tmp/apache2.conf /etc/apache2/sites-available/000-default.conf && \
    cp /tmp/startup.sh /root/startup.sh

ENTRYPOINT ["/bin/bash", "-c", "/bin/bash /root/startup.sh; tail -f /dev/null"]
