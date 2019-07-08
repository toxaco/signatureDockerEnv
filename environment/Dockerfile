FROM toxaco/signaturedockerenv:latest
ENV SSH_KEY id_efc6468efd14481c3db849b88f41b51f
ARG host=172.18.0.1
ENV APP_NAME Signature
WORKDIR /var/www/html

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
