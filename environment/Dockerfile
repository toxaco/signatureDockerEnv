FROM php:7.1-fpm
ENV SSH_KEY id_efc6468efd14481c3db849b88f41b51f
ARG host=172.18.0.1
ENV APP_NAME Signature
WORKDIR /var/www/html

# Install sys deps
RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list \
     && echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/99norecommends \
     && apt-get update && apt-get install -y \
        git \
        vim \
        libmcrypt-dev \
        libmemcached-dev \
        nginx-light \
        ssh-client \
        supervisor \
        wget \
        zip \
        zlib1g-dev \
	poppler-utils \
     && apt-get clean \
     && rm /var/lib/apt/lists/*.* 

# Some ssh key setup
# RUN mkdir -p ~/.ssh/ && chmod 700 ~/.ssh && echo "StrictHostKeyChecking No" > ~/.ssh/config

# Install Memcached for php 7
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

# Install php libraries
RUN docker-php-ext-enable opcache \
    && docker-php-ext-install \
        bcmath \
        mcrypt \
        mysqli \
        pcntl \
        pdo \
        pdo_mysql \
        zip \
	gd

RUN apt-get update -y \
  && apt-get install -y \
    libxml2-dev \
    php-soap \
  && apt-get clean -y \
  && docker-php-ext-install soap

# Setup php
RUN echo "date.timezone=UTC" >  /usr/local/etc/php/conf.d/timezone.ini
RUN echo "upload_max_filesize = 10M;" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 11M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Install APCu
RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

# Install composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- && cp composer.phar /usr/local/bin/composer

# Install xdebug
 RUN pecl install xdebug \
     && docker-php-ext-enable xdebug \
     && sed -i '1 a xdebug.remote_autostart=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.idekey=phpstorm' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_mode=req' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_handler=dbgp' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_connect_back=0 ' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_port=9000' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_host=10.254.254.254' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
     && sed -i '1 a xdebug.max_nesting_level=500' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Blackfire [11/2017]
# RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
#     && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
#     && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
#     && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
#     && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini
 

# Install node and npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN nodejs -v && npm -v
RUN y|npm i -g webpack && y|npm i -g typescript && y|npm i -g yarn 

# Configure sudoers for better dev experience ;-)
RUN echo "Defaults umask=0002" >> /etc/sudoers \
    && echo "Defaults umask_override" >> /etc/sudoers

VOLUME /var/www/html
VOLUME /var/lib/nginx
VOLUME /tmp
VOLUME /tmp/nginx
VOLUME /tmp/nginx/cache
VOLUME /tmp/nginx/fcgicache

# Remove apt cache to make the image smaller
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get purge -y --auto-remove

# These two commands are SUPER important!
EXPOSE 80
CMD ["/usr/bin/bash”]