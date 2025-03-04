FROM php:7.4-fpm

# Install required packages and PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/src/php/ext/*/.libs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/src/php/ext/*/.libs

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql mbstring zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer --version

# Copy application code
COPY . /var/www

# Set working directory
WORKDIR /var/www

# Make the run-php-server.sh script executable
RUN chmod +x run-php-server.sh

# Clear Composer Cache
RUN composer clear-cache
# Install Laravel dependencies and generate application key
RUN composer install --no-interaction --optimize-autoloader && \
    php artisan key:generate

# Set permissions
COPY --chown=www-data:www-data . /var/www
RUN chmod -R 775 /var/www/storage
RUN chmod -R 775 /var/www/bootstrap/cache

RUN chown -R www-data:www-data /var/www/vendor
RUN chown -R www-data:www-data /var/www/
RUN chmod -R 755 /var/www/vendor

RUN php artisan key:generate && \
    echo "APP_KEY=$(php artisan key:generate --show)" > /var/www/.env
    # sed -i "s/^APP_KEY=.*/APP_KEY=$(php artisan key:generate --show)/" /var/www/.env

# Switch to non-root user
USER www-data

# Expose port 8000
EXPOSE 8000

CMD ["php-fpm"]

# ENTRYPOINT [ "bash", "run-php-server.sh" ]