#!/bin/bash

# get the locale code as argument
set_language="$1"

#######################
#                     #
#     VARIABLES       #
#                     #
#######################

# Installation directory
nc_install_directory=$PWD

# Nextcloud version
#nextcloudVersion='latest.tar.bz2'

# Php version
#php_version='7.4'

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

nc_distribution=""

#########################
#                       #
#      TRANSLATION      #
#                       #
#########################

# Greeting's message
i18n_distribution_menu="Distribution choice"
i18n_distribution_set_debian11="Debian 11"
i18n_greeting="[Nextcloud Instaler]"
i18n_set_hostname="Define Hostname"
i18n_installation_mode="Installation Mode"
i18n_distribution_select="Distribution selected"
i18n_host_select="Host selected"
i18n_choice_quit="Quit"
i18n_full_installation="Full installation"
i18n_press_enter_msg="Press Enter..."
i18n_full_installation_title="Full installation"
i18n_restoration_define_parameter="Define restore parameters"
i18n_restoration_import_parameter="Import restore parameters"

#########################
#                       #
#      FR Messages      #
#                       #
#########################

msg_fr(){
  i18n_distribution_menu="Choix de la distribution"
  i18n_distribution_set_debian11="Debian 11"
  i18n_greeting="[Nextcloud Installation]"
  i18n_set_hostname="Définir Hostname"
  i18n_distribution_select="Distribution séléctionnée"
  i18n_host_select="Host selectioné"
  i18n_choice_quit="Quitter"
  i18n_full_installation="Instalation complète"
  i18n_press_enter_msg="Appuyez sur Enter..."
  i18n_full_installation_title="Instalation complète"
  i18n_restoration_define_parameter="Définir les paramètres de restauration"
  i18n_restoration_import_parameter="Importer les parameters de restauration"
}

######################
#                    #
#     FUNCTIONS      #
#                    #
######################

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
press_a_key(){
  echo -n "$i18n_press_enter_msg"
  read -r choice
}

full_installation(){
  clear
  echo "$i18n_full_installation_title"
  press_a_key
  main_loop
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

set_hostname(){
  clear
  echo "$i18n_greeting $i18n_set_hostname"
  echo ""
  echo -n "> "
  read -r nc_hostname
}

distribution_debian11(){
  cat >"$nc_config/distribution.sh"<<EOF
#!/bin/bash

nc_distribution="debian 11"
nc_hostname="$nc_hostname"
EOF
  main_loop
}

main_menu(){
  source "$nc_config/distribution.sh"
  clear
  echo "$i18n_greeting $i18n_installation_mode"
  echo ""
  echo " $i18n_host_select : $nc_hostname"
  echo " $i18n_distribution_select : $nc_distribution"
  echo ""
  echo " ( 1 ) - $i18n_full_installation"
  echo " ( 2 ) - $i18n_restoration_define_parameter"
  echo " ( 3 ) - $i18n_restoration_import_parameter"
  echo ""
  echo ""
  echo " ( d ) - $i18n_distribution_menu"
  echo ""
  echo " ( q ) - $i18n_choice_quit"
  echo ""
  echo -n "> "
  read -r choice

  if [ "$choice" = "q" ]||[ "$choice" = "Q" ]; then
  	exit 1
  fi

  if [ "$choice" = "d" ]||[ "$choice" = "D" ]; then
  	distribution_menu
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

  main_loop
}

distribution_menu(){
  clear
  echo "$i18n_greeting $i18n_distribution_menu"
  echo ""
  echo " $i18n_host_select : $nc_hostname"
  echo ""
  echo " ( 1 ) - $i18n_distribution_set_debian11"
  echo ""
  echo ""
  echo " ( h ) - $i18n_set_hostname"
  echo ""
  echo " ( q ) - $i18n_choice_quit"
  echo ""
  echo -n "> "
  read -r choice

  if [ "$choice" = "q" ]||[ "$choice" = "Q" ]; then
  	exit 1
  fi

  if [ "$choice" = "h" ]||[ "$choice" = "H" ]; then
    set_hostname
  fi

  if [ "$choice" = 1 ]; then
    distribution_debian11
  fi

  distribution_menu
}

main_loop(){
  if [ -f "$nc_config/distribution.sh" ]; then
  	main_menu
  else
    distribution_menu
  fi
}

initialisation(){
  mkdir -p "$nc_config"
  mkdir -p "$nc_backup_db"
  mkdir -p "$nc_backup_ssl"
  mkdir -p "$nc_backup_host"
  mkdir -p "$nc_backup_scripts"
  set_hostname
}

#########################
#                       #
#      APPLICATION      #
#                       #
#########################
translate_msg
initialisation
main_loop
