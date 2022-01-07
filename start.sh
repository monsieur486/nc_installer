#!/bin/bash

# get the locale code as argument
set_language="$1"

# Comment for production mode
mode="dev"

#########################
#                       #
#      TRANSLATION      #
#                       #
#########################

# Default messages
i18n_application_name="[ Nextcloud Instaler ]"
i18n_must_be_root="End of sctipt.\nMust be run as root."
i18n_set_hostname="Define Hostname"
i18n_distribution_menu="Distribution choice"
i18n_distribution_set_debian_11_2="Debian 11.2"
i18n_distribution_set_debian_10_8="Debian 10.8"
i18n_distribution_set_debian_9_13="Debian 9.13"
i18n_distribution_set_debian_9_4="Debian 9.4"
i18n_distribution_set_ubuntu_20_04="Ubuntu 20.04"
i18n_installation_mode="Installation Mode"
i18n_distribution_select="Distribution selected"
i18n_hostname_select="Hostname selected"
i18n_choice_quit="Quit"
i18n_full_installation="Full installation"
i18n_press_enter_msg="Press Enter..."
i18n_full_installation_title="Full installation"
i18n_restoration_define_parameter="Define restore parameters"
i18n_restoration_import_parameter="Import restore parameters"

msg_fr(){
  i18n_application_name="[ Nextcloud Installation ]"
  i18n_must_be_root="Fin du sctipt.\nDoit être exécuté en tant que root."
  i18n_set_hostname="Définir Hostname"
  i18n_distribution_menu="Choix de la distribution"
  i18n_installation_mode="Choisir le mode d'installation"
  i18n_distribution_select="Distribution séléctionnée"
  i18n_hostname_select="Hostname selectioné"
  i18n_choice_quit="Quitter"
  i18n_full_installation="Instalation complète"
  i18n_press_enter_msg="Appuyez sur Enter..."
  i18n_full_installation_title="Instalation complète"
  i18n_restoration_define_parameter="Définir les paramètres de restauration"
  i18n_restoration_import_parameter="Importer les paramètres de restauration"
  i18n_ips_do_not_match="Les ips ne correspondent pas"
  i18n_ips_match="Les ips correspondent"
}

######################
#                    #
#     FUNCTIONS      #
#                    #
######################

check_hostname(){

  if [ $mode != "dev" ]; then
    ip_from_hostname=$(dig +short "$1")
    if [ ! "$ip_from_hostname" = "$2" ]
    then
      # shellcheck disable=SC2154
      echo -e "${frmt_clr_red}$i18n_ips_do_not_match${frmt_default}"
      echo -e "IP indiquée : ${frmt_clr_green}$2${frmt_default}"
      echo -e "IP pour $1 : ${frmt_clr_red}${frmt_set_blink}$ip_from_hostname${frmt_default}"
      echo ""
      press_a_key
      menu_set_hostname
    else
      echo -e "${frmt_clr_green}$i18n_ips_match${frmt_default}"
      echo -e "IP indiquée : ${frmt_clr_green}$2${frmt_default}"
      echo -e "IP pour $1 : ${frmt_clr_green}${frmt_set_blink}$ip_from_hostname${frmt_default}"
      echo ""
      press_a_key
    fi
  else
    echo -e "${frmt_clr_green}$i18n_ips_match${frmt_default}"
    echo -e "IP indiquée : ${frmt_clr_green}$2${frmt_default}"
    echo -e "IP pour $1 : ${frmt_clr_green}${frmt_set_blink}$2${frmt_default}"
    echo ""
    press_a_key
  fi
}

checkRoot(){
    if [ $mode != "dev" ]; then
      # shellcheck disable=SC2059
      [ "$(id -u)" = 0 ] || { echo -e "$i18n_must_be_root"; exit 1; }
    else
      rm -rf nc_config
      rm -rf nc_backup_db
      rm -rf nc_backup_ssl
      rm -rf nc_backup_host
      rm -rf nc_backup_scripts
    fi
}

create_app_directory(){
  mkdir -p "$nc_config"
  mkdir -p "$nc_backup_db"
  mkdir -p "$nc_backup_ssl"
  mkdir -p "$nc_backup_host"
  mkdir -p "$nc_backup_scripts"
}

distribution_debian_11_2(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="$i18n_distribution_set_debian_11_2"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

distribution_debian_10_8(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="$i18n_distribution_set_debian_10_8"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

distribution_debian_9_13(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="$i18n_distribution_set_debian_9_13"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

distribution_debian_9_4(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="$i18n_distribution_set_debian_9_4"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

distribution_ubuntu_20_04(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="$i18n_distribution_set_ubuntu_20_04"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

full_installation(){
  clear
  echo "$i18n_full_installation_title"
  press_a_key
  main_loop
}

initialisation(){
  translate_msg
  set_variable
  set_color
  checkRoot
  create_app_directory
  menu_set_hostname
}

item_menu_title(){
  echo -e "${frmt_clr_green}$i18n_application_name ${frmt_clr_yellow}$1${frmt_default}"
}

item_menu_choice(){
  echo -e " ( ${frmt_clr_yellow}${1}${frmt_default} ) - ${2}"
}

item_menu_subchoice(){
  echo -e " ( ${frmt_clr_cyan}${1}${frmt_default} ) - ${2}"
}

item_menu_quit(){
  echo -e " ( ${frmt_clr_red}q${frmt_default} ) - $i18n_choice_quit"
}

main_loop(){
  if [ -f "$nc_config/distribution.sh" ]; then
  	menu_instalation_mode
  else
    menu_distribution
  fi
}

menu_distribution(){
  clear
  item_menu_title "$i18n_distribution_menu"
  echo ""
  echo -e " $i18n_hostname_select : ${frmt_clr_cyan}$nc_hostname${frmt_default}"
  echo ""
  item_menu_choice 1 "$i18n_distribution_set_debian_11_2"
  item_menu_choice 2 "$i18n_distribution_set_debian_10_8"
  item_menu_choice 3 "$i18n_distribution_set_debian_9_13"
  item_menu_choice 4 "$i18n_distribution_set_debian_9_4"
  item_menu_choice 5 "$i18n_distribution_set_ubuntu_20_04"
  echo ""
  item_menu_subchoice h "$i18n_set_hostname"
  echo ""
  item_menu_quit
  echo ""
  echo -n "> "
  read -r choice

  if [ "$choice" = "q" ]||[ "$choice" = "Q" ]; then
    exit 1
  fi

  if [ "$choice" = "h" ]||[ "$choice" = "H" ]; then
    menu_set_hostname
  fi

  if [ "$choice" = 1 ]; then
    distribution_debian_11_2
  fi

  if [ "$choice" = 2 ]; then
    distribution_debian_10_8
  fi

  if [ "$choice" = 3 ]; then
    distribution_debian_9_13
  fi

  if [ "$choice" = 4 ]; then
    distribution_debian_9_4
  fi

  if [ "$choice" = 5 ]; then
    distribution_ubuntu_20_04
  fi

  menu_distribution
}

menu_instalation_mode(){
  source "$nc_config/distribution.sh"
  clear
  item_menu_title "$i18n_installation_mode"
  echo ""
  echo -e " $i18n_hostname_select : ${frmt_clr_cyan}$nc_hostname${frmt_default}"
  echo -e " $i18n_distribution_select : ${frmt_clr_cyan}$nc_distribution${frmt_default}"
  echo ""
  item_menu_choice 1 "$i18n_full_installation"
  item_menu_choice 2 "$i18n_restoration_define_parameter"
  item_menu_choice 3 "$i18n_restoration_import_parameter"
  echo ""
  item_menu_subchoice d "$i18n_distribution_menu"
  echo ""
  item_menu_quit
  echo ""
  echo -n "> "
  read -r choice

  if [ "$choice" = "q" ]||[ "$choice" = "Q" ]; then
    exit 1
  fi

  if [ "$choice" = "d" ]||[ "$choice" = "D" ]; then
    menu_distribution
  fi

  if [ "$choice" = 1 ]; then
    full_installation
  fi

  if [ "$choice" = 2 ]; then
    restoration_define_parameter
  fi

  if [ "$choice" = 3 ]; then
    restoration_import_parameter
  fi

  menu_instalation_mode
}

menu_set_hostname(){
    clear
    item_menu_title "$i18n_set_hostname"
    echo ""
    echo -n "> "
    read -r nc_hostname
    echo -n "IP > "
    read -r nc_ip

    check_hostname "$nc_hostname" "$nc_ip"
  }

press_a_key(){
  echo -n "$i18n_press_enter_msg"
  read -r choice
}

search_key(){
  # shellcheck disable=SC2002
  result=$(cat "$nc_nextcloud/config/config.php" | grep "$1")
  # shellcheck disable=SC2001
  result=$(sed "s/    '$1' => '//g" <<<"$result")
  # shellcheck disable=SC2001
  result=$(sed "s/',//g" <<<"$result")
  echo "$result"
}

restoration_define_parameter(){
  clear
  echo "$i18n_restoration_define_parameter"
  press_a_key
  main_loop
}

restoration_import_parameter(){
  clear
  echo "$i18n_restoration_import_parameter"
  press_a_key
  main_loop
}

set_color(){
  # Default Text
  frmt_default="\e[0m"

  # Set
  frmt_set_blink="\e[5m"
  frmt_set_bold="\e[1m"
  frmt_set_dim="\e[2m"
  frmt_set_underlined="\e[4m"
  frmt_set_reverse="\e[7m"
  frmt_set_hidden="\e[8m"

  # Reset
  frmt_rst_blink="\e[25m"
  frmt_rst_bold="\e[21m"
  frmt_rst_dim="\e[22m"
  frmt_rst_underlined="\e[24m"
  frmt_rst_reverse="\e[27m"
  frmt_rst_hidden="\e[28m"

  # Regular color
  frmt_clr_default="\e[39m"

  frmt_clr_black="\e[30m"
  frmt_clr_red="\e[31m"
  frmt_clr_green="\e[32m"
  frmt_clr_yellow="\e[33m"
  frmt_clr_blue="\e[34m"
  frmt_clr_magenta="\e[35m"
  frmt_clr_cyan="\e[36m"
  frmt_clr_light_gray="\e[37m"
  frmt_clr_dark_gray="\e[90m"
  frmt_clr_light_red="\e[91m"
  frmt_clr_light_green="\e[92m"
  frmt_clr_light_yellow="\e[93m"
  frmt_clr_light_blue="\e[94m"
  frmt_clr_light_magenta="\e[95m"
  frmt_clr_light_cyan="\e[96m"
  frmt_clr_white="\e[97m"

  # Background
  frmt_bkg_default="\e[49m"

  frmt_bkg_black="\e[40m"
  frmt_bkg_red="\e[41m"
  frmt_bkg_green="\e[42m"
  frmt_bkg_yellow="\e[43m"
  frmt_bkg_blue="\e[44m"
  frmt_bkg_magenta="\e[45m"
  frmt_bkg_cyan="\e[46m"
  frmt_bkg_light_gray="\e[47m"
  frmt_bkg_dark_gray="\e[100m"
  frmt_bkg_light_red="\e[101m"
  frmt_bkg_light_green="\e[102m"
  frmt_bkg_light_yellow="\e[103m"
  frmt_bkg_light_blue="\e[104m"
  frmt_bkg_light_magenta="\e[105m"
  frmt_bkg_light_cyan="\e[106m"
  frmt_bkg_white="\e[107m"
}

set_variable(){
  # Installation directory
  nc_install_directory=$PWD

  # Nextcloud version
  nextcloudVersion='latest.tar.bz2'

  # Php version
  php_version='7.4'

  # Nextcloud installer config directory
  nc_config=$nc_install_directory/nc_config

  # Backup Data directory
  nc_backup_db=$nc_install_directory/nc_backup_db

  # Backup ssl directory
  nc_backup_ssl=$nc_install_directory/nc_backup_ssl

  # Backup host directory
  nc_backup_host=$nc_install_directory/nc_backup_host

  # Backup scripts directory
  nc_backup_scripts=$nc_install_directory/nc_backup_scripts

  nc_home='/var/www/vhosts'

  # Nextcloud directory
  nc_nextcloud="$nc_home/nextcloud"

  # Data directory
  nc_data="$nc_home/data"

  nc_distribution=''
}

translate_msg(){
  if [ -z "$set_language" ]
  then
    true
  else
    if [ "$set_language" = "fr" ]; then
      msg_fr
    fi
  fi
}

#########################
#                       #
#      APPLICATION      #
#                       #
#########################
initialisation
main_loop
