#!/bin/bash

mode=dev

superfunction(){
  if [ $mode = "prod" ];
  then
    echo "Traitement Prod pour $1"
  else
    echo "Traitement Dev pour $1"
  fi
}

megafunction(){
  # shellcheck disable=SC2068
  for variable in ${suite[@]}
  do
      superfunction "$variable"
  done
}



suite=(7 9)
megafunction

mode="prod"
suite=(1 2 3 )
megafunction

fonction_01(){
  echo "01"
}

fonction_02(){
  echo "02"
}

fonction_03(){
  echo "03"
}

fonction_04(){
  echo "04"
}

afaire=(fonction_01 fonction_01 fonction_03 fonction_04 fonction_02 fonction_01)

maxifunction(){
  # shellcheck disable=SC2068
  for action in ${afaire[@]}
  do
   ${action}
  done
}
maxifunction
