#!/bin/bash

# Greeting's message
i18n_greeting="Welcome [Nexcloud install] principal menu"
i18n_choice_quit="quit"

i18n_menu_config_set="Set config"
i18n_menu_config_import="Import config"
i18n_menu_config_delete="Delete config"
i18n_press_a_key_msg="Press a key"


#=====================================================

translation_dir=$current_app_dir/translation

if [ -z "$set_language" ]
then
  echo ""
else
  if [ $set_language = "fr" ]; then
    source $translation_dir/msg_fr.sh
  fi
fi
