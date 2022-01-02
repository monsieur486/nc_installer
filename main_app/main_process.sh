#!/bin/sh

source $main_app_dir/no_config_file.sh

main_loop(){
  if [ -f "nc_config.sh" ]; then
  	no_config_file_menu
  else
    no_config_file_menu
  fi
}

main_loop



