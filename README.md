
# MTC2D_Php-todo

This repository holds the code for migrating a simple PHP web-app (built with Laravel 5.2) to the cloud via containerization. It demonstrates how to package a Laravel application using Docker and deploy it easily.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Docker Usage](#docker-usage)
- [Configuration](#configuration)
- [Common Issues](#common-issues)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [License](#license)

## Overview

This Laravel-based task management app allows you to create, view, and delete tasks. The application is containerized using Docker ([`Dockerfile`](Dockerfile)), running PHP-FPM along with a startup script ([`run-php-server.sh`](run-php-server.sh)) that performs database migrations, seeding, and launches Laravel’s built-in server.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your host machine.
- A MySQL container or accessible MySQL instance (your `.env` file expects the database at `DB_HOST=172.18.0.2`).
- Git (to clone the repository)

## Installation

Clone the repository:

```sh
git clone https://github.com/Kosenuel/MTC2D_Php-todo.git
cd MTC2D_Php-todo
```

Install PHP dependencies via Composer (optional – they are installed during the Docker build):

```sh
composer install #(Optional)
```

## Docker Usage

### Build the Docker Image

From the project root, build the image:

```sh
docker build -t php-todo:0.0.1 .
```

### Run the Container

Make sure the database credentials in your .env file are correct. Then, run the container (using your preferred network configuration):

```bash
docker run --network tooling_app_network --rm --name php-todo --env-file .env -p 8090:8000 -i php-todo:0.0.1
```

Access the application from your host machine via:

```
http://localhost:8090
```

### This is how It Works

- The Dockerfile installs required PHP extensions, Composer, and sets up the Laravel app.
- The container runs an entrypoint script (`run-php-server.sh`) which:
  - Exports ENV variables from the .env file.
  - Runs migrations and seeds the database.
  - Clears caches and then starts the Laravel development server on port 8000.

## Configuration

Review and adjust the following files as needed:

- **.env** – Contains settings for development (APP_DEBUG, DB credentials, etc.).
- **Dockerfile** – See file here for container build configurations.
- **run-php-server.sh** – See file here for startup operations.

## Common Issues

- **HTTP 500 Errors:**  
  Check laravel.log for error messages. Ensure storage directories have correct write permissions.
- **Database Connection Issues:**  
  Confirm that the database service is accessible from your container and that the credentials in .env are correct.
- **Caching Problems:**  
  Clear your app cache with `php artisan cache:clear` (the entrypoint script does this automatically).

## Testing

The project includes unit tests located in the `tests/` directory. To run tests locally, ensure you have PHPUnit installed and run:

```sh
./vendor/bin/phpunit
```

## Project Structure

```bash
├── app/                   # Application source code (models, controllers, etc.)
├── bootstrap/             # Laravel bootstrap and cache files
├── config/                # Application configuration files
├── database/              # Migrations, seeds, and factories
├── public/                # Publicly accessible files (index.php, assets)
├── resources/             # Views and language files
├── storage/               # Logs, caches, and uploaded files
├── tests/                 # Unit and feature tests
├── .env                   # Environment configuration file
├── artisan                # Laravel CLI tool
├── composer.json          # Composer dependency definitions ([composer.json](composer.json))
├── Dockerfile             # Container build configuration ([Dockerfile](Dockerfile))
├── run-php-server.sh      # Entrypoint script for container startup ([run-php-server.sh](run-php-server.sh))
└── README.md              # This file
```

## License

This project is licensed under the MIT License.

