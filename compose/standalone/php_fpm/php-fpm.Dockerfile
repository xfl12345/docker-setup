FROM php:7.4-fpm-bullseye
# RUN apt update && apt install -y \
# 		libfreetype-dev \
# 		libjpeg62-turbo-dev \
# 		libpng-dev \
# 	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
# 	&& docker-php-ext-install -j$(nproc) gd
RUN apt update
RUN apt upgrade -y
RUN apt install -y apt-utils
RUN apt install -y unixodbc-dev libcurl4-openssl-dev libsqlite3-dev libbz2-dev libxml2-dev libzip-dev
# ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
# ADD ./install-php-extensions /usr/local/bin/
RUN chmod 755 /usr/local/bin/install-php-extensions
# RUN install-php-extensions cmath bz2 calendar exif ftp gettext mysqli zip
RUN install-php-extensions bcmath bz2 calendar dba enchant exif ffi ftp gd gettext gmp imap intl ldap mysqli
RUN install-php-extensions oci8 odbc opcache pcntl pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pgsql pspell 
RUN install-php-extensions shmop snmp soap sockets sysvmsg sysvsem sysvshm tidy xsl zip
# # Fix ODBC installation. For more https://github.com/docker-library/php/issues/103
# RUN ln -s /usr/include /usr/local/incl
# RUN docker-php-ext-configure odbc --with-unixODBC=shared,/usr
# RUN docker-php-ext-install bz2 calendar ctype curl dba dl_test dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell random readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlwriter xsl zend_test zip

# Installed module in default 
# Core ctype curl date dom fileinfo filter hash iconv json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar posix random readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter zlib

# RUN docker-php-ext-install bz2 calendar dba dl_test enchant exif ffi ftp gd gettext gmp imap intl ldap mysqli oci8 odbc opcache pcntl  pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pgsql pspell shmop snmp soap sockets sysvmsg sysvsem sysvshm tidy xsl zend_test zip
