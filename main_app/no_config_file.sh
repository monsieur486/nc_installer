#!/bin/bash

no_config_file_menu(){
  clear
  echo "$i18n_greeting"
  echo ""
  echo "* ( 1 ) $i18n_menu_config_set"
  echo "* ( 2 ) $i18n_menu_config_import"
  echo "* ( 3 ) $i18n_menu_config_delete"
  echo ""
  echo "* ( q ) - $i18n_choice_quit"
  echo ""
  echo -n "> "
  read choice

  if [ $choice = "q" ]||[ $choice = "Q" ]; then
  	exit 1
  fi

    if [ $choice = 1 ]; then
    	exit 1
    fi

  main_loop

}
