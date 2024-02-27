#!/bin/bash

# Chemin du fichier contenant le mot de passe
password_file="/var/lib/password.txt"

# Lire le mot de passe depuis le fichier
password=$(cat "$password_file")

# Chemin vers le fichier de date d'expiration
expiration_date_file="/var/lib/fin_acces_date.txt"

# bool pour l'état de blocage
is_locked=false

# Variable pour suivre l'état du redémarrage
restarting=false

# Chemin vers le fichier de configuration Zenity
zenity_config_file="/var/lib/zenity_config.txt"

# Chemin vers le fichier de configuration de l'application de démarrage
autostart_file="$HOME/.config/autostart/userlockendsequence.desktop"

# Messages Zenity par défaut
default_expiration_message="Vous êtes dans la dernière période de 30 jours avant la date d'échéance.\n\nPensez à renouveler votre accès.\n\nContact : 06 22 09 86 53 / clech.michel@wanadoo.fr"
default_password_success_message="Mot de passe configuré avec succès"

# Fonction pour vérifier si un utilisateur est connecté
is_user_logged_in() {
    who | grep -q "$(whoami)"
}



# Fonction pour afficher une notification un mois avant la date d'échéance
notify_one_month_before() {
    current_timestamp=$(date +"%s")
    expiration_datetime=$(cat "$expiration_date_file")
    expiration_timestamp=$(date -d "$expiration_datetime" +"%s")
    one_month_before=$(date -d "$expiration_datetime -1 month" +"%s")

    # Si on est dans la dernière période de 30 jours avant échéance
    if [ $current_timestamp -ge $one_month_before ] && [ $current_timestamp -lt $expiration_timestamp ]; then
        # Si c'est un lundi à 16 heures
        if [ "$(date +"%u %H" -d "$expiration_datetime -1 month")" = "1 16" ]; then
            zenity --info --title="Information" --text="$(cat "$zenity_config_file")"
        fi
    fi
}

# Fonction pour supprimer l'application de démarrage si la location est arrivée à échéance
remove_autostart_if_expired() {
    current_timestamp=$(date +"%s")
    expiration_datetime=$(cat "$expiration_date_file")
    expiration_timestamp=$(date -d "$expiration_datetime" +"%s")

    # Si le temps restant est inférieur ou égal à zéro et l'application de démarrage existe, la supprimer
    if [ $current_timestamp -ge $expiration_timestamp ] && [ -e "$autostart_file" ]; then
        rm "$autostart_file"
    fi
}

# Boucle pour vérifier le temps restant chaque minute
while true; do
    current_timestamp=$(date +"%s")
    expiration_datetime=$(cat "$expiration_date_file")
    expiration_timestamp=$(date -d "$expiration_datetime" +"%s")

    # Si le temps restant est inférieur ou égal à zéro et le verrouillage n'a pas été effectué, exécuter le script de modification de mot de passe et redémarrage
    if [ $current_timestamp -ge $expiration_timestamp ] && [ "$is_locked" = false ] && [ "$restarting" = false ]; then

        change_lockscreen_wallpaper
        # Exécuter le script de modification de mot de passe et redémarrage

        echo -e "$password\n$password" | sudo passwd $(whoami)
        is_locked=true  # Mettre à jour le statut du verrouillage
        restarting=true  # Indiquer que le redémarrage est en cours
        zenity --info --title="Information" --text="$(cat "$zenity_config_file")"
       	gsettings set org.gnome.desktop.background picture-uri "file:///echepil.jpg"
        sudo shutdown -r +1
    fi

    # Réinitialiser la variable is_locked et restarting à false si l'utilisateur est connecté
    if is_user_logged_in; then
        is_locked=false
        restarting=false
        restore_default_wallpaper  # Restaurer le fond d'écran par défaut
    fi

    # Afficher une notification un mois avant la date d'échéance
    notify_one_month_before

    # Supprimer l'application de démarrage si la location est arrivée à échéance
    remove_autostart_if_expired

    sleep 60  # Attendre 60 secondes avant de vérifier à nouveau
done

