#!/bin/bash

set_language="$1"

#######################
#                     #
#     VARIABLES       #
#                     #
#######################
current_app_dir=$PWD

#########################
#                       #
#      TRANSLATION      #
#                       #
#########################

# Greeting's message
i18n_greeting="Welcome [Nexcloud install] principal menu"
i18n_choice_quit="Quit"
i18n_menu_config_set="Set config"
i18n_menu_config_import="Import config"
i18n_press_enter_msg="Press Enter..."
i18n_define_config_msg_title="Define configuration"
i18n_import_config_msg_title="Import configuration"

#########################
#                       #
#      FR Messages      #
#                       #
#########################

msg_fr(){
  i18n_greeting="[Nexcloud installation] menu principal"
  i18n_choice_quit="Quitter"
  i18n_menu_config_set="Définir la configuration"
  i18n_menu_config_import="Importer une configuration"
  i18n_press_enter_msg="Appuyez sur Enter..."
  i18n_define_config_msg_title="Definir la configuration"
  i18n_import_config_msg_title="Importer une configuration"
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

define_configuation(){
  clear
  echo "$i18n_define_config_msg_title"
  if [ -f "nc_config.sh" ]; then
    rm nc_config.sh
  fi
  touch nc_config.sh
  press_a_key
  main_loop
}

import_configuation(){
  clear
  echo "$i18n_import_config_msg_title"
  press_a_key
  main_loop
}

main_menu(){
  clear
  echo "$i18n_greeting"
  echo ""
  echo "* ( 1 ) - $i18n_menu_config_set"
  echo "* ( 2 ) - $i18n_menu_config_import"
  echo ""
  echo "* ( q ) - $i18n_choice_quit"
  echo ""
  echo -n "> "
  read -r choice

  if [ "$choice" = "q" ]||[ "$choice" = "Q" ]; then
  	exit 1
  fi

  if [ "$choice" = 1 ]; then
    define_configuation
  fi

  if [ "$choice" = 2 ]; then
    import_configuation
  fi

  main_loop
}

press_a_key(){
  echo -n "$i18n_press_enter_msg"
  read -r choice
}

main_loop(){
  if [ -f "nc_config.sh" ]; then
  	main_menu
  else
    main_menu
  fi
}

initialisation(){
  echo ""
}

#########################
#                       #
#      APPLICATION      #
#                       #
#########################
translate_msg
initialisation
main_loop
