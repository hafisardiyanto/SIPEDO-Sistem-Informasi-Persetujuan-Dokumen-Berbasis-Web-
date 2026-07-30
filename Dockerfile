FROM docker.io/library/php:8.2-fpm

# Install dependencies yang dibutuhkan sistem operasi Linux container
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libpq-dev \
    libonig-dev \
    libzip-dev

# Bersihkan cache instaler apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Memasang modul mesin bahasa PHP khusus PostgreSQL & sistem web
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Instalasi komposer global
COPY --from=docker.io/library/composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Tarik seluruh berkas direktori laravel lokal ke dalam kontainer
COPY . .

# Set hak akses agar web server bisa membaca arsip Storage/Log
RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache
