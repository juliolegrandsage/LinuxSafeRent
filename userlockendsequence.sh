#!/bin/bash

# Mot de passe en dur (remplacez "votre_mot_de_passe" par votre mot de passe réel)
new_password="fraise"
# Chemin vers le fichier de date d'expiration
expiration_date_file="fin_acces_date.txt"

# bool pour l'état de blocage
is_locked=false

# Variable pour suivre l'état du redémarrage
restarting=false

# Chemin vers le fichier de configuration Zenity
zenity_config_file="zenity_config.txt"

# Messages Zenity par défaut
default_expiration_message="Vous êtes dans la dernière période de 30 jours avant la date d'échéance.\n\nPensez à renouveler votre accès.\n\nContact : 06 22 09 86 53 / clech.michel@wanadoo.fr"
default_password_success_message="Mot de passe configuré avec succès"

# Fonction pour vérifier si un utilisateur est connecté
is_user_logged_in() {
    who | grep -q "$(whoami)"
}

notify_one_month_before() {
    current_timestamp=$(date +"%s")
    expiration_datetime=$(cat "$expiration_date_file")
    expiration_timestamp=$(date -d "$expiration_datetime" +"%s")
    three_weeks_before=$(date -d "$expiration_datetime -1 month -3 weeks" +"%s")

    # Si on est dans le dernier mois avant échéance et qu'il reste plus de trois semaines
    if [ $current_timestamp -ge $three_weeks_before ] && [ $current_timestamp -lt $expiration_timestamp ]; then
        # Déterminer le nombre de secondes restantes (ici, par exemple, on utilise 10 secondes pour simuler des tests rapides)
        remaining_seconds=$(($expiration_timestamp - $current_timestamp))

        # Si le reste de la division par 3 est égal à 0 (c'est-à-dire toutes les trois secondes)
        if [ $(($remaining_seconds % 3)) -eq 0 ]; then
            # Afficher un message Zenity différent en fonction des secondes restantes
            case $(($remaining_seconds / 3)) in
                3)  # Trois secondes restantes
                    zenity --info --title="Information" --text="Message pour les trois secondes restantes"
                    ;;
                2)  # Deux secondes restantes
                    zenity --info --title="Information" --text="Message pour les deux secondes restantes"
                    ;;
                1)  # Une seconde restante
                    zenity --info --title="Information" --text="Message pour la dernière seconde"
                    ;;
            esac
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
        
    sleep 5
    zenity --info --title="Information" --text="Message pour les trois semaines restantes"
    
    sleep 5
    zenity --info --title="Information" --text="Second message"
    
    sleep 5
    zenity --info --title="Information" --text="Troisième message"

    # Si le temps restant est inférieur ou égal à zéro et le verrouillage n'a pas été effectué, exécuter le script de modification de mot de passe et redémarrage
    if [ $current_timestamp -ge $expiration_timestamp ] && [ "$is_locked" = false ] && [ "$restarting" = false ]; then
        is_locked=true  # Mettre à jour le statut du verrouillage
        echo -e "fraise\nfraise" | sudo passwd $(whoami)  # Changer le mot de passe

        restarting=true  # Indiquer que le redémarrage est en cours
        zenity --info --title="Information" --text="$(cat "$zenity_config_file")"

        if [ -n "$DISPLAY" ]; then

            # Pour les environnements graphiques
            pkill -u $(whoami)  # Déconnexion de l'utilisateur actuel
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

    # Afficher une notification un mois avant la date d'échéance
    notify_one_month_before

    # Supprimer l'application de démarrage si la location est arrivée à échéance
    remove_autostart_if_expired

    sleep 60  # Attendre 60 secondes avant de vérifier à nouveau
done
