FROM bartoszmaciaszek/php-fpm-nginx:latest

MAINTAINER Bartosz Maciaszek <bartosz.maciaszek@gmail.com>

EXPOSE 80

WORKDIR /app

ENV PHPCI_VERSION 1.7.1
ENV PHPCI_URL http://phpci.domain.tld
ENV PHPCI_DB_HOST 127.0.0.1
ENV PHPCI_DB_NAME phpci
ENV PHPCI_DB_USER phpci
ENV PHPCI_DB_PASSWORD phpci
ENV PHPCI_ADMIN_LOGIN admin
ENV PHPCI_ADMIN_PASSWORD admin
ENV PHPCI_ADMIN_MAIL admin@domain.tld

RUN composer create-project block8/phpci=${PHPCI_VERSION} /app --keep-vcs --no-dev
RUN composer install
RUN composer update robmorgan/phinx

COPY init.sh /init.sh
RUN chmod +x /init.sh

COPY vhost.conf /etc/nginx/sites-enabled/default.conf

CMD ["/init.sh"]
