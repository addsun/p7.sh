#!/bin/bash

NGINX_VERSION='1.9.9'
PHP_VERSION='7.0.2'
unset TMOUT
cd $OPENSHIFT_TMP_DIR
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
wget http://exim.mirror.fr/pcre/pcre-8.38.tar.gz
tar xzf pcre-8.38.tar.gz
tar xzf pcre-8.38.tar.gz
git clone https://github.com/FRiCKLE/ngx_cache_purge.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
cd ${OPENSHIFT_TMP_DIR}nginx-${NGINX_VERSION}
./configure --prefix=$OPENSHIFT_DATA_DIR --with-pcre=${OPENSHIFT_TMP_DIR}pcre-8.38 --with-pcre-jit --with-threads --with-http_realip_module --with-http_sub_module --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_geoip_module --with-http_secure_link_module --without-mail_pop3_module
--without-mail_imap_module --without-mail_smtp_module --add-module=${OPENSHIFT_TMP_DIR}ngx_http_substitutions_filter_module --add-module=${OPENSHIFT_TMP_DIR}ngx_cache_purge
make -j4 && make install
cd /tmp
rm -rf *
wget -O libmcrypt-2.5.8.tar.gz http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz?big_mirror=0
tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j && make install
cd libltdl
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --enable-ltdl-install
make -j4 && make install
cd ../..
wget -O mhash-0.9.9.9.tar.gz http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz?big_mirror=0
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget  --no-check-certificate -O re2c-0.13.7.5.tar.gz https://www.kooker.jp/re2c-0.13.7.5.tar.gz
tar xzf re2c-0.13.7.5.tar.gz
cd re2c-0.13.7.5
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget -O mcrypt-2.6.8.tar.gz http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz?big_mirror=0
tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
export LDFLAGS="-L${OPENSHIFT_DATA_DIR}usr/local/lib -L/usr/lib"
export CFLAGS="-I${OPENSHIFT_DATA_DIR}usr/local/include -I/usr/include"
export LD_LIBRARY_PATH="/usr/lib/:${OPENSHIFT_DATA_DIR}usr/local/lib"
export PATH="/bin:/usr/bin:/usr/sbin:${OPENSHIFT_DATA_DIR}usr/local/bin:${OPENSHIFT_DATA_DIR}bin:${OPENSHIFT_DATA_DIR}sbin"
touch malloc.h
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --with-libmcrypt-prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget -O php-${PHP_VERSION}.tar.gz http://us3.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
tar xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}
./configure --prefix=$OPENSHIFT_DATA_DIR --with-config-file-path=${OPENSHIFT_DATA_DIR}etc --with-layout=GNU --with-mcrypt=${OPENSHIFT_DATA_DIR}usr/local --with-pear --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-pdo --with-pdo-sqlite --with-sqlite3 --with-openssl --with-zlib-dir --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-bz2 --with-libxml-dir --with-curl --with-gd --with-xsl --with-xmlrpc --with-mhash --with-gettext --with-readline --with-kerberos --with-pcre-regex --enable-json --enable-bcmath --enable-cli --enable-calendar --enable-dba --enable-wddx --enable-inline-optimization --enable-simplexml --enable-filter --enable-ftp --enable-tokenizer --enable-dom --enable-exif --enable-mbregex --enable-fpm --enable-mbstring --enable-gd-native-ttf --enable-xml --enable-xmlwriter --enable-xmlreader --enable-pcntl --enable-sockets --enable-zip --enable-soap --enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-intl --enable-maintainer-zts --enable-opcache --disable-debug --disable-fileinfo --disable-phar --disable-ipv6 --disable-rpath
make -j4 && make install
cp ${OPENSHIFT_TMP_DIR}php-${PHP_VERSION}/php.ini-development ${OPENSHIFT_DATA_DIR}etc/php.ini
cp ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf.default ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf
cp ${OPENSHIFT_DATA_DIR}etc/php-fpm.d/www.conf.default ${OPENSHIFT_DATA_DIR}etc/php-fpm.d/www.conf
echo "<?php phpinfo(); ?>" >> ${OPENSHIFT_DATA_DIR}html/info.php
cd /tmp
wget https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.zip
unzip NON_BLOCKING_IO_php7.zip
cd pecl-memcache-NON_BLOCKING_IO_php7
phpize
./configure --with-php-config=${OPENSHIFT_DATA_DIR}/bin/php-config --enable-memcache
make -j4 && make install
cd /tmp
wget -c https://github.com/phpredis/phpredis/archive/php7.zip
unzip php7.zip
cd phpredis-php7
phpize
./configure --with-php-config=${OPENSHIFT_DATA_DIR}/bin/php-config --enable-redis
make -j4 && make install
sed -i "s/default_type  application\/octet-stream;/default_type  application\/octet-stream;\n    port_in_redirect off;\n    server_tokens off;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/listen       80;/listen       ${OPENSHIFT_DIY_IP}:8080;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/            index  index.html index.htm;/           index  index.html index.php index.htm;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/nginx\/\$nginx_version;/nginx;/g" ${OPENSHIFT_DATA_DIR}conf/fastcgi.conf
sed -i "s/# deny access to .htaccess files, if Apache's document root/location ~ \\\.php\$ {\n            root           html;\n            fastcgi_pass   ${OPENSHIFT_DIY_IP}:9000;\n            fastcgi_index  index.php;\n            fastcgi_param   SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;\n            fastcgi_param   SCRIPT_NAME        \$fastcgi_script_name;\n            include        fastcgi_params;\n        }\n\n        # deny access to .htaccess files, if Apache's document root/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/user = nobody/;user = nobody/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.d/www.conf
sed -i "s/group = nobody/;group = nobody/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.d/www.conf
sed -i "s/listen = 127.0.0.1:9000/listen = ${OPENSHIFT_DIY_IP}:9000/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.d/www.conf
sed -i "s/short_open_tag = Off/short_open_tag = On/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_file_uploads = 20/max_file_uploads = 30/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 30M/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_input_time = 60/max_input_time = 300/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/default_socket_timeout = 60/default_socket_timeout = 300/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_execution_time = 30/max_execution_time = 180/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/disable_functions = /disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen /g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/; End:/; End:\n\nzend_extension=opcache.so\nextension=memcache.so\nextension=redis.so/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/nohup /#nohup /g" ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/start
sed -i "s/&/&\nnohup $OPENSHIFT_DATA_DIR/sbin/nginx > $OPENSHIFT_LOG_DIR/server.log 2>&1 &\nnohup $OPENSHIFT_DATA_DIR/sbin/php-fpm &/g" ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/start
echo "nohup $OPENSHIFT_DATA_DIR/sbin/nginx > $OPENSHIFT_LOG_DIR/server.log 2>&1 &" >> ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/start
echo "nohup $OPENSHIFT_DATA_DIR/sbin/php-fpm &" >> ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/start
echo "killall nginx" >> ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/stop
echo "killall php-fpm" >> ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/stop
cd /tmp
rm -rf *
cd ${OPENSHIFT_REPO_DIR}.openshift/cron/minutely
rm -rf restart.sh
wget --no-check-certificate https://www.kooker.jp/restart.sh
chmod 755 restart.sh 
touch nohup.out
chmod 755 nohup.out
rm -rf delete_log.sh
wget --no-check-certificate https://www.kooker.jp/delete_log.sh
chmod 755 delete_log.sh
cd ${OPENSHIFT_DATA_DIR}html
rm -rf index.html
echo "<!DOCTYPE html><html><head><meta charset=\"utf-8\" /><title>Openshift Nginx + PHP 环境安装成功！</title><style>    body {width: 35em;margin: 0 auto;font-family: Tahoma, Verdana, Arial, sans-serif;}</style></head><body><h1>Openshift Nginx + PHP 环境安装成功！</h1><p>这是使用 Hi kooker Proxy 提供的脚本安装 Nginx-${NGINX_VERSION} + PHP${PHP_VERSION} </p><p>cd /tmp<br />wget --no-check-certificate https://www.kooker.jp/p7.sh<br />chmod 755 p7.sh<br />./p7.sh<br /></p><p><a href=\"https://www.kooker.jp/p7.sh\">脚本下载</a> | <a href=\"yhtz.php\">雅黑探针</a> | <a href=\"info.php\">phpinfo</a></p><p><em><a href=\"https://blog.kooker.jp/\">Hi kooker</a></em></p></body></html>" >> ${OPENSHIFT_DATA_DIR}html/index.html
wget http://dl.kn007.net/directlink/yhtz.php
gear stop
gear start
