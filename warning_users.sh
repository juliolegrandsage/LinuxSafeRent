#!/bin/bash

current_date=$(date +"%Y-%m-%d")
end_date=$(date -d "$current_date + 1 year" +"%Y-%m-%d")

echo "$current_date"
notify-send "T'as de beaux yeux" "Tu sais ?"
notify-send "Début de votre accès : $current_date" 
notify-send "Fin de votre accès : $end_date"
echo $end_date
