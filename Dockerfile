#
# Shop vendors service Dockerfile
# Copyrights to Wajdi Jurry <github.com/wajdijurry>
#
FROM php:7.3-fpm

LABEL maintainer="Wajdi Jurry <github.com/wajdijurry>"

ARG DEBIAN_FRONTEND=noninteractive

# Update apt repos
RUN echo "Updating repos ..." && apt-get -y update > /dev/null
RUN apt-get install -yq apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# Return working directory to its default state
WORKDIR /src

# Copy project files to container
RUN echo "Copying project files ..."
ADD . ./

# Install required tools and dependencies
RUN chmod +x utilities/install-dependencies.sh && ./utilities/install-dependencies.sh

# Install required PHP extensions
RUN chmod +x utilities/install-php-extensions.sh && ./utilities/install-php-extensions.sh

# Download Symfony CLI
RUN echo "Installing Symfony CLI" && wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony && \
    addgroup --force-badname _www; \
    adduser --no-create-home --force-badname --disabled-login --disabled-password --system _www; \
    addgroup _www _www && \
    symfony check:requirements

# Install composer & dependencies
RUN echo "Installing Composer" && rm -rf vendor composer.lock && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer clearcache && \
    composer config -g github-oauth.github.com 3f6fd65b0d7958581f549b862ee49af9db1bcdf1 && \
    composer install

ENTRYPOINT ["/bin/bash", "utilities/docker-entrypoint.sh"]