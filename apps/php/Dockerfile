FROM php:7.2-apache
ARG MY_ENV
ENV APP_ENV $MY_ENV
WORKDIR /var/www/html
COPY index.php .
COPY config.$APP_ENV ./config
EXPOSE 80
USER nobody
