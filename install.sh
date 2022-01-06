#!/bin/bash

#=======================================================

##########
# Config #
##########

#=======================================================

# Dmonaine name
domainname='cloud.familletouret.fr'

# Administrator's email
email='administrateur@familletouret.fr'

# Instalation directory
nc_home='/var/www/vhosts'

# Nextcloud database admin
db_user='nextclouduser'

# Nextcloud database admin password
db_admin_pw='mdp12345!'

# Nextcloud database name
db_name='nextclouddb'

# Nextcloud database host
db_host='localhost'

# Nextcloud admin user
nc_user='ncuser'

# Nextcloud admin user password
nc_pw='mdp12345!'

# Backup ssh port
bck_ssh_port=22

# Backup ssh user
bck_ssh_user='root'

# Backup ssh host
bck_ssh_host='91.121.174.190'

# Backup ssh directory
bck_directory='bck_cloud_ft'

# NC Installer directory
nc_install_directory=$PWD

#=======================================================

###############
# Translation #
###############

#=======================================================

getEng(){
    # installation of prerequisites
    i18n_installationOfPrerequisites="Installation of prerequisites"

    # Must be root to run script\n
    i18n_mustBeRoot="Must be root to run script\n"

    # Log out and execute script again
    i18n_logOutMsg="Log out and execute script again"

    # End of report
    i18n_endRepportMsg="End of report"

    # Recovery operation performed successfully
    i18n_recupOk="Recovery operation performed successfully"

    # Phone region
    i18n_phoneRegion="EN"
}

getFr(){
    # installation of prerequisites
    i18n_installationOfPrerequisites="Installation des prérequis"

    # Must be root to run script\n
    i18n_mustBeRoot="Doit être root pour exécuter ce script\n"

    # Log out and execute script again
    i18n_logOutMsg="Déconnectez-vous et reconnectez-vous à nouveau."

    # End of report
    i18n_endRepportMsg="Fin du report"

    # Recovery operation performed successfully
    i18n_recupOk="Opération de restauration effectuée avec succès"

    # Phone region
    i18n_phoneRegion="FR"
}

# Choice of translation

#getEng
getFr

#=======================================================

################
# Not modified #
################

#=======================================================

# Nextcloud version
nextcloudVersion='latest.tar.bz2'

# Php version
php_version='7.4'

# Data directory
nc_data="$nc_home/data"

# Backup Data directory
nc_backup_db=$nc_install_directory/nc_backup_db

# Backup ssl directory
nc_backup_ssl=$nc_install_directory/nc_backup_ssl

# Backup host directory
nc_backup_host=$nc_install_directory/nc_backup_host

# Backup scripts directory
nc_backup_scripts=$nc_install_directory/nc_backup_scripts

#=======================================================

#############
# Functions #
#############

#=======================================================

###################
# checkPrerequies #
###################

checkPrerequies(){
if [ -f "prerequis" ]; then
	installApp
else
    installPrerequis
fi
}

####################
# installPrerequis #
####################

installPrerequis() {
clear
echo "$i18n_installationOfPrerequisites"
cat >/etc/hostname<<EOF
$domainname
EOF

hostName="$(hostname)"

mkdir -p $nc_backup_db
mkdir -p $nc_backup_ssl
mkdir -p $nc_backup_host
mkdir -p $nc_backup_scripts

mkdir -p "$nc_home"
mkdir -p "$nc_data"


cat >/etc/apt/sources.list<<EOF
deb http://deb.debian.org/debian/ bullseye main
deb-src http://deb.debian.org/debian/ bullseye main

deb http://security.debian.org/debian-security bullseye-security main contrib
deb-src http://security.debian.org/debian-security bullseye-security main contrib

deb http://deb.debian.org/debian/ bullseye-updates main contrib
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib
EOF

cat >$nc_backup_scripts/backup_nextcloud.sh<<EOF
#!/bin/sh

if [ -f "$nc_backup_db/db_nextcloud.sql" ]; then
    rm $nc_backup_db/db_nextcloud.sql
fi
if [ -f "$nc_backup_host/nextcloud.conf" ]; then
    rm $nc_backup_host/nextcloud.conf
fi
sudo -u www-data php $nc_home/nextcloud/occ files:cleanup
sudo -u www-data php $nc_home/nextcloud/occ files:scan --all
sudo -u www-data php $nc_home/nextcloud/occ maintenance:mode --on

mysqldump -u $db_user -p$db_admin_pw $db_name > $nc_backup_db/db_nextcloud.sql

cp /etc/apache2/sites-available/nextcloud.conf $nc_backup_host/nextcloud.conf

rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_backup_db/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_db/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_home/nextcloud/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_nextcloud/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_data/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_data/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_backup_ssl/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_ssl/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_backup_scripts/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_scripts/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $nc_backup_host/ $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_host/

sudo -u www-data php $nc_home/nextcloud/occ maintenance:mode --off
EOF

cat >$nc_backup_scripts/recup_nextcloud.sh<<EOF
#!/bin/sh

if [ -f "$nc_backup_db/db_nextcloud.sql" ]; then
    rm $nc_backup_db/db_nextcloud.sql
fi
if [ -f "$nc_backup_host/nextcloud.conf" ]; then
    rm $nc_backup_host/nextcloud.conf
fi
if [ -f "/etc/apache2/sites-available/nextcloud.conf" ]; then
    rm /etc/apache2/sites-available/nextcloud.conf
fi

rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_db/ $nc_backup_db/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_nextcloud/ $nc_home/nextcloud/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_data/ $nc_data/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_ssl/ $nc_backup_ssl/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_scripts/ $nc_backup_scripts/
rsync -avzhe 'ssh -p $bck_ssh_port' --progress --delete $bck_ssh_user@$bck_ssh_host:$bck_directory/nc_backup_host/ /etc/apache2/sites-available/

chown -R www-data:www-data $nc_home/nextcloud
chown -R www-data:www-data $nc_data
chmod -R 755 $nc_home/nextcloud
chmod -R 755 $nc_data

mysql -e "DROP DATABASE IF EXISTS $db_name;"
mysql -e "CREATE DATABASE $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'$db_host';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "quit"

mysql -u $db_user -p$db_admin_pw $db_name < $nc_backup_db/db_nextcloud.sql

echo "raz" > $nc_data/nextcloud.log
chown www-data:www-data $nc_data/nextcloud.log

sudo -u www-data php $nc_home/nextcloud/occ files:scan --all --verbose
sudo -u www-data php $nc_home/nextcloud/occ files:cleanup

systemctl restart apache2
echo "$i18n_recupOk"
EOF

apt-get update -y

apt-get install rsync curl sudo screen -y

apt-get install apache2 libapache2-mod-php$php_version -y
apt-get install php php-cli php-gd php-json php-mysql php-curl -y
apt-get install php-intl php-imagick php-xml -y
apt-get install php-gmp php-ldap php-imap -y
apt-get install php-mbstring php-bz2 php-zip php-bcmath php-apcu -y
apt-get install php-imagick libmagickcore-dev ffmpeg libreoffice -y
apt-get install redis-server php-redis -y
systemctl reload apache2

apt-get install mariadb-server -y
mysql_secure_installation

a2enmod ssl rewrite headers env dir mime

cat >>/etc/php/$php_version/mods-available/opcache.ini<<EOF
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
EOF

cat >>/etc/php/$php_version/mods-available/apcu.ini<<EOF
apc.enable=1
apc.enable_cli=1
EOF

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/$php_version/apache2/php.ini

sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/g' /etc/ImageMagick-6/policy.xml

systemctl reload apache2

apt install snapd -y

ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub -p$bck_ssh_port $bck_ssh_user@$bck_ssh_host

touch prerequis
echo "$i18n_logOutMsg"
exit 0
}

##############
# installApp #
##############

installApp(){
clear
echo "Install app"

mysql -e "CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "CREATE USER '$db_user'@'$db_host' IDENTIFIED BY '$db_admin_pw';"
mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'$db_host';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "quit"

cat >$nc_install_directory/report.txt<<EOF
Rapport d'installation Nextcloud
================================
host=$domainname
email=$email

Database informations
=====================
db_host=$db_host
db_name=$db_name
db_user=$db_user
db_pwd=$db_admin_pw

Admin Nextcloud
===============
user=$nc_pw
pwd=$nc_pw

Backup informations
===================
bck_ssh_port=$bck_ssh_port
bck_ssh_user=$bck_ssh_user
bck_ssh_host=$bck_ssh_host
bck_directory=$bck_directory

# $i18n_endRepportMsg
EOF
chmod 400 $nc_install_directory/report.txt

wget "https://download.nextcloud.com/server/releases/$nextcloudVersion"

tar xjfv "$nextcloudVersion"
mv nextcloud "$nc_home/"
chown -R www-data:www-data $nc_home/nextcloud
chown -R www-data:www-data $nc_data
chmod -R 755 $nc_home/nextcloud
chmod -R 755 $nc_data

cd "$nc_home/nextcloud/" || { printf 'No nextcloud dir\n'; exit 1; }

sudo -u www-data php $nc_home/nextcloud/occ  maintenance:install \
    --database 'mysql' --database-name "$db_name" --database-user "$db_user" \
    --database-pass "$db_admin_pw" --admin-user "$nc_user" --admin-pass "$nc_pw" --data-dir "$nc_data"

sudo -u www-data php $nc_home/nextcloud/occ config:system:set trusted_domains 0 --value=$domainname
sudo -u www-data php $nc_home/nextcloud/occ config:system:set default_phone_region --value='FR'

# Enable all previews
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enable_previews --value=true --type=boolean
sudo -u www-data php $nc_home/nextcloud/occ config:system:set preview_libreoffice_path --value='/usr/bin/libreoffice'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 0 --value='OC\\Preview\\PNG'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 1 --value='OC\\Preview\\JPEG'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 2 --value='OC\\Preview\\GIF'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 3 --value='OC\\Preview\\BMP'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 4 --value='OC\\Preview\\XBitmap'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 5 --value='OC\\Preview\\MarkDown'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 6 --value='OC\\Preview\\MP3'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 7 --value='OC\\Preview\\TXT'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 8 --value='OC\\Preview\\Illustrator'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 9 --value='OC\\Preview\\Movie'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 10 --value='OC\\Preview\\MSOffice2003'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 11 --value='OC\\Preview\\MSOffice2007'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 12 --value='OC\\Preview\\MSOfficeDoc'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 13 --value='OC\\Preview\\OpenDocument'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 14 --value='OC\\Preview\\PDF'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 15 --value='OC\\Preview\\Photoshop'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 16 --value='OC\\Preview\\Postscript'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 17 --value='OC\\Preview\\StarOffice'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 18 --value='OC\\Preview\\SVG'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 19 --value='OC\\Preview\\TIFF'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set enabledPreviewProviders 20 --value='OC\\Preview\\Font'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set preview_max_x --value='2048'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set preview_max_y --value='2048'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set jpeg_quality --value='60'

## Setting local cache to use Redis.
sudo -u www-data php $nc_home/nextcloud/occ config:system:set memcache.local --value='\\OC\\Memcache\\Redis'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set memcache.locking --value='\\OC\\Memcache\\Redis'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set filelocking.enabled --value='true' --type=boolean
sudo -u www-data php $nc_home/nextcloud/occ config:system:set redis host --value='localhost'
sudo -u www-data php $nc_home/nextcloud/occ config:system:set redis port --value='6379' --type=integer
sudo -u www-data php $nc_home/nextcloud/occ preview:generate-all -vvv

cron_path=/var/spool/cron/crontabs/root
echo "*/5  *  *  *  * php -f $nc_home/nextcloud/cron.php >/dev/null 2>&1" >> $cron_path
echo "*/10  *  *  *  * php -f $nc_home/nextcloud/occ preview:pre-generate >/dev/null 2>&1" >> $cron_path

snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

cat >>/etc/apache2/conf-available/well-known.conf<<EOF
Alias /.well-known/acme-challenge/ "/var/lib/letsencrypt/.well-known/acme-challenge/"
<Directory "/var/lib/letsencrypt/">
    AllowOverride None
    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
    Require method GET POST OPTIONS
</Directory>
EOF

ln -s /etc/apache2/conf-available/well-known.conf /etc/apache2/conf-enabled/
systemctl restart apache2

certbot --apache --agree-tos --redirect --staple-ocsp --email $email -d $domainname

if [ -f "$nc_backup_ssl/fullchain.pem" ]; then
    rm $nc_backup_ssl/fullchain.pem
fi
if [ -f "$nc_backup_ssl/privkey.pem" ]; then
    rm $nc_backup_ssl/privkey.pem
fi

if [ -f "/etc/letsencrypt/live/$domainname/fullchain.pem" ]; then
    cp /etc/letsencrypt/live/$domainname/fullchain.pem $nc_backup_ssl/
fi
if [ -f "/etc/letsencrypt/live/$domainname/privkey.pem" ]; then
    cp /etc/letsencrypt/live/$domainname/privkey.pem $nc_backup_ssl/
fi

cat >/etc/apache2/sites-available/nextcloud.conf<<EOF
<VirtualHost *:80>
    ServerName $domainname

    # auto redirect HTTP to HTTPS
    Redirect permanent / https://$domainname/
</VirtualHost>

<VirtualHost *:443>
    ServerName $domainname
    ServerAdmin $email
    DocumentRoot $nc_home/nextcloud

    Protocols h2 http/1.1

    SSLEngine On
    SSLCertificateFile $nc_backup_ssl/fullchain.pem
    SSLCertificateKeyFile $nc_backup_ssl/privkey.pem

    # HSTS
    <IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
    </IfModule>

    <Directory $nc_home/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All

        <IfModule mod_dav.c>
            Dav off
        </IfModule>

        SetEnv HOME $nc_home/nextcloud
        SetEnv HTTP_HOME $nc_home/nextcloud
    </Directory>
</VirtualHost>
EOF

chown -R www-data:www-data $nc_home/nextcloud
chown -R www-data:www-data $nc_data
chmod -R 755 $nc_home/nextcloud
chmod -R 755 $nc_data

a2dissite 000-default
a2dissite 000-default-le-ssl
a2ensite nextcloud.conf
systemctl restart apache2

cat >~/.aliases_nc<<EOF
alias occ='sudo -u www-data php $nc_home/nextcloud/occ' # occ command shortcut
alias Ncec='nano $nc_home/nextcloud/config/config.php' # edit config.php
alias Ncme='occ maintenance:mode --on' # enable maintenance mode
alias Ncmd='occ maintenance:mode --off' # disable maintenance mode
alias Ncsa='occ files:scan --all --verbose' # scan all files
alias Nccu='occ files:cleanup' # clean Up
alias Ncvd='cd $nc_data' # data directory
alias Nccl='echo "raz" > $nc_data/nextcloud.log' && chown www-data:www-data $nc_data/nextcloud.log # clear log
alias NCbackup='bash $nc_backup_scripts/backup_nextcloud.sh' # Export full app
alias NCrecup='bash $nc_backup_scripts/recup_nextcloud.sh' # Restore full app
EOF

cat >>~/.bashrc<<EOF
source .aliases_nc
EOF

source ~/.bashrc

apt-get update -y && apt-get upgrade -y && apt-get autoremove -y

}

#=======================================================

############
# Main App #
############

#=======================================================

[ "$(id -u)" = 0 ] || { printf "$i18n_mustBeRoot"; exit 1; }

checkPrerequies
