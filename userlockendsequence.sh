#!/bin/bash

# Mot de passe en dur (remplacez "votre_mot_de_passe" par votre mot de passe réel)
new_password="mJoVy30#"
# Heure d'expiration fixée à 12:00
expiration_time="12:00"
# Chemin vers le fichier de date d'expiration
expiration_date_file="/var/lib/fin_acces_date.txt"

# Messages Zenity par défaut
zenity_config_file="/var/lib/zenity_config.txt"
message1="La location de cet ordinateur arrive à son terme (sous un mois) et nous vous invitons à reprendre contact avec GOUPIL pour renouveler votre adhésion ou ramener le matériel si vous ne souhaitez pas l'acheter.\n\nMail : goupil.ere@gmail.com\n\nTel : 06 22 09 86 53"

message2="La location de cet ordinateur arrive à son terme (sous deux semaines) et ne sera plus utilisable.\n\Nous vous invitons à reprendre contact avec GOUPIL pour renouveler votre adhésion ou ramener le matériel si vous ne souhaitez pas l'acheter.\n\Mail : goupil.ere@gmail.com\n\Tel : 06 22 09 86 53"
message3="La location de cet ordinateur arrive à son terme (sous 7 jours) et ne sera plus utilisable.\n\Nous vous invitons à reprendre contact avec GOUPIL pour renouveler votre adhésion ou ramener le matériel si vous ne souhaitez pas l'acheter.\n\Mail : goupil.ere@gmail.com\n\Tel : 06 22 09 86 53"

# Fonction pour obtenir la date d'expiration avec l'heure fixée
get_expiration_datetime() {
    # Obtenez la date d'expiration avec l'heure fixée à 12:00
    today=$(date +%Y-%m-%d)
    expiration_datetime="$today $expiration_time"
    echo "$expiration_datetime"
}

# bool pour l'état de blocage
is_locked=false

# Variable pour suivre l'état du redémarrage
restarting=false

# Fonction pour vérifier si un utilisateur est connecté
is_user_logged_in() {
    who | grep -q "$(whoami)"
}

# Fonction pour afficher le message Zenity correspondant à la date donnée
display_zenity_message() {
    local message="$1"
    zenity --info --title="Information" --text="$message"
}

# Demander à l'utilisateur de choisir la date et l'heure d'expiration
expiration_datetime=$(get_expiration_datetime)

# Assurer que le script a les permissions pour écrire dans le fichier
echo "$expiration_datetime" | sudo tee "$expiration_date_file" > /dev/null

# Notification pour informer que la date a été enregistrée avec succès
zenity --info --title="Information" --text="Moment d'échéance : $expiration_datetime"

# Configurer le mot de passe
echo -e "$new_password\n$new_password" | sudo passwd $(whoami)  # Changer le mot de passe

# Afficher un message pour indiquer que le script est lancé
zenity --info --title="Info" --text="LinuxSafeRent est lancé"

# Boucle pour vérifier le temps restant chaque minute
while true; do
    current_timestamp=$(date +"%s")
    expiration_datetime=$(get_expiration_datetime)
    expiration_timestamp=$(date -d "$expiration_datetime" +"%s")

    # Si le temps restant est inférieur ou égal à zéro et le verrouillage n'a pas été effectué, exécuter le script de modification de mot de passe et redémarrage
    if [ $current_timestamp -ge $expiration_timestamp ] && [ "$is_locked" = false ] && [ "$restarting" = false ]; then
    	zenity --info --title --text="La location de cet ordinateur est arrivée à son terme.\n\ Pour obtenir un nouveau mot de passe utilisateur, nous vous invitons à reprendre contact avec GOUPIL\n\Mail : goupil.ere@gmail.com\n\Tel : 06 22 09 86 5"
        echo -e "$new_password\n$new_password" | sudo passwd $(whoami)  # Changer le mot de passe
        pkill -u $(whoami)  # Déconnexion de l'utilisateur actuel
        restarting=true  # Indiquer que le redémarrage est en cours
        zenity --info --title="Information" --text="Info finale "
        if [ -n "$DISPLAY" ]; then
            # Pour les environnements graphiques
            cinnamon-screensaver-command --lock || gnome-screensaver-command --lock || dm-tool lock
        else
            # Pour les environnements non graphiques
            echo "Impossible de verrouiller l'écran dans cet environnement."
        fi
    fi

    # Réinitialiser la variable is_locked et restarting à false si l'utilisateur est connecté
    if is_user_logged_in; then
        is_locked=false
        restarting=false
        # restore_default_wallpaper  # Restaurer le fond d'écran par défaut
    fi

    # Afficher les messages Zenity correspondants aux dates configurées
    current_date=$(date +%Y-%m-%d)
    if [ "$current_date" = "2024-03-04 12:00:00" ]; then
        display_zenity_message "$message1"
    elif [ "$current_date" = "2024-03-06 12:00:00" ]; then
        display_zenity_message "$message2"
    elif [ "$current_date" = "2024-03-07 12:00:00"]; then
        display_zenity_message "$message3"
    fi

    sleep 60  # Attendre 60 secondes avant de vérifier à nouveau
done

