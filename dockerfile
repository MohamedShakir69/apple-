# Base image
FROM php:8.1-apache

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy Drupal files into the container
COPY . /var/www/html

# Set the document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache modules
RUN a2enmod rewrite


# Drush
# Set the Drush version.
ENV DRUSH_VERSION 8.3.2
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


# Set up environment variables for MySQL connection
ENV MYSQL_HOST=localhost \
    MYSQL_DATABASE=drupal \
    MYSQL_USER=drupal \
    MYSQL_PASSWORD=drupal

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

