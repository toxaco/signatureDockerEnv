FROM php:7.1-fpm
ENV SSH_KEY id_efc6468efd14481c3db849b88f41b51f
ARG host=172.18.0.1
ENV APP_NAME Signature
WORKDIR /var/www/html
COPY . /var/www/html

# Install sys deps
RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list \
     && echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/99norecommends \
     && apt-get update && apt-get install -y \
        git \
        libmcrypt-dev \
        libmemcached-dev \
        nginx-light \
        ssh-client \
        supervisor \
        wget \
        zip \
        zlib1g-dev \
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

# Setup php
RUN echo "date.timezone=UTC" >  /usr/local/etc/php/conf.d/timezone.ini
RUN echo "upload_max_filesize = 10M;" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 11M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Install APCu
RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

# Install composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- && cp composer.phar /usr/local/bin/composer

# Install node and npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN nodejs -v && npm -v

# Install vendors
#RUN chown -R www-data: /var/www/html #make sure this is fine # run a chmod too
#RUN wget -O ~/.ssh/id_rsa http://${host}:8000/id_efc6468efd14481c3db849b88f41b51f
#RUN chmod 0600 ~/.ssh/id_rsa
#RUN composer install -n
#RUN rm ~/.ssh/id_rsa
#RUN chown -R www-data:www-data /var/www/html

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
    && sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configure sudoers for better dev experience ;-)
RUN echo "Defaults umask=0002" >> /etc/sudoers \
    && echo "Defaults umask_override" >> /etc/sudoers


COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["/usr/bin/supervisord"]

VOLUME /var/www/html/var/tmp
VOLUME /var/lib/nginx
VOLUME /tmp
