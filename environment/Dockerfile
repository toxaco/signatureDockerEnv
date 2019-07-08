FROM php:7.3-fpm-stretch
ENV SSH_KEY id_efc6468efd14481c3db849b88f41b51f
ARG host=172.18.0.1
ENV APP_NAME Signature
WORKDIR /var/www/html

# Install sys deps
RUN echo "deb http://deb.debian.org/debian stretch main multiverse non-free"  > /etc/apt/sources.list && \
echo "deb http://security.debian.org/debian-security stretch/updates main non-free" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian stretch-updates main non-free " >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian stretch-backports main non-free" >> /etc/apt/sources.list && \
echo "deb http://http.us.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list


# Install node and npm
RUN apt-get update && apt-get install -my wget gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN npm i -g webpack && npm i -g typescript && npm i -g yarn

# Install specific version of Node (8.11.3)
ENV NVM_DIR /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
ENV NODE_VERSION v8.11.3
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

# PDFTK
RUN mkdir /usr/share/man/man1
COPY pdftk/pdftk-all.jar /pdftk.jar
COPY pdftk/pdftk.sh /usr/bin/pdftk
RUN chmod +x /usr/bin/pdftk

# Install dependencies
RUN apt-get update && apt-get install -y \
        ttf-mscorefonts-installer \
        git \
        vim \
        htop \
        libmcrypt-dev \
        libxml2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        nginx-light \
        ssh-client \
        supervisor \
        wget \
        zip \
        zlib1g-dev \
        libzip-dev \
        libicu-dev \
        g++ \
        poppler-utils \
        openjdk-8-jdk \
        libgd3 \
        libgd-dev

# Install + Configure PHP libraries
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure intl
RUN pecl install mailparse
RUN docker-php-ext-enable opcache mailparse
RUN docker-php-ext-install -j$(nproc) \
        bcmath \
        mysqli \
        pcntl \
        pdo \
        pdo_mysql \
        zip \
        gd \
        soap \
        intl
RUN yes '' | pecl install -f mcrypt
RUN echo "extension=mcrypt.so" > /usr/local/etc/php/conf.d/mcrypt.ini
RUN apt-get clean -y

# Setup PHP ini configs
RUN echo "date.timezone=Europe/London" > /usr/local/etc/php/conf.d/signature.ini && \
echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/signature.ini && \
echo "opcache.max_accelerated_files=32531" >> /usr/local/etc/php/conf.d/signature.ini && \
echo "opcache.memory_consumption=512" >> /usr/local/etc/php/conf.d/signature.ini && \
echo "upload_max_filesize = 10M" >>  /usr/local/etc/php/conf.d/signature.ini && \
echo "post_max_size = 11M" >> /usr/local/etc/php/conf.d/signature.ini && \
echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/signature.ini

# Install APCu
RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN chmod +x /usr/local/bin/composer
RUN composer global require hirak/prestissimo

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
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get purge -y --auto-remove

# These two commands are SUPER important!
EXPOSE 80
CMD ["/usr/bin/bash”]
