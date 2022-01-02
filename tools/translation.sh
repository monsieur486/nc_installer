#!/bin/sh

translation_dir=$current_app_dir/translation

if [ $set_language = "fr" ]; then
	source $translation_dir/msg_fr.sh
else
  source $translation_dir/msg_defaut.sh
fi
