#!/bin/bash

# export APP_KEY value
export $(cat /var/www/.env | grep -v '#' | awk '/=/ {print $1}')

# Start PHP server
php artisan migrate --force
php artisan db:seed --force
php artisan cache:clear
php artisan config:clear
php artisan route:clear
# php artisan view:clear

php artisan serve --host=0.0.0.0 --port=8000