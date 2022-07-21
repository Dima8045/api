FROM php:7.4-fpm as prod

RUN set -xe; \
  apt-get update && \
  apt-get upgrade -y && \
  pecl channel-update pecl.php.net && \
  apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip && rm -rf /var/lib/apt/lists/*

# Install the PHP extention
RUN docker-php-ext-install pdo_mysql exif pcntl bcmath gd

###########################################################################
# Install Php Redis Extension:
###########################################################################
RUN printf "\n" | pecl install -o -f redis \
	&& rm -rf /tmp/pear \
	&& docker-php-ext-enable redis

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data
# Set working directory
WORKDIR /var/www

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Expose port 9000 and start php-fpm server
CMD ["php-fpm"]

EXPOSE 9000

FROM prod as dev

RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug
