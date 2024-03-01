#!/bin/bash

# Chemin vers le fichier de date d'expiration
expiration_date_file="/var/lib/fin_acces_date.txt"
# Chemin vers le fichier contenant le mot de passe
password_file="/var/lib/password.txt"
# Chemin vers le fichier contenant les messages Zenity
zenity_config_file="/var/lib/zenity_config.txt"
# Chemin vers le fichier contenant les messages d'avertissement
warning_config_file="/var/lib/warning_config.txt"

# Messages Zenity par défaut
default_expiration_message="Vous êtes dans la dernière période de 30 jours avant la date d'échéance.\n\nPensez à renouveler votre accès.\n\nContact : 06 22 09 86 53 / clech.michel@wanadoo.fr"
default_password_success_message="Mot de passe configuré avec succès"
default_warning_message="Attention ! Votre accès expire bientôt. Veuillez renouveler votre accès."

# Fonction pour obtenir la date et l'heure d'expiration avec Zenity
get_expiration_datetime() {
    # Sélection de la date
    selected_date=$(zenity --calendar --title="Choisir la date d'expiration" --text="Sélectionnez la date d'expiration de l'accès." --date-format="%Y-%m-%d" --window-icon="calendar" --width=300 --height=300)

    # Sélection de l'heure
    selected_time=$(zenity --entry --title="Choisir l'heure d'expiration" --text="Saisissez l'heure d'expiration (format 24 heures, par exemple, 14:30)" --entry-text "12:00")

    echo "$selected_date $selected_time"
}

# Fonction pour configurer le mot de passe avec Zenity
configure_password() {
    # Saisie du nouveau mot de passe
    new_password=$(zenity --password --title="Configuration du mot de passe" --text="Entrez le nouveau mot de passe")

    # Vérification du nouveau mot de passe
    verify_password=$(zenity --password --title="Configuration du mot de passe" --text="Veuillez confirmer le nouveau mot de passe")

    # Comparaison des mots de passe
    if [ "$new_password" != "$verify_password" ]; then
        zenity --error --title="Erreur" --text="Les mots de passe ne correspondent pas. Veuillez réessayer."
        configure_password  # Appel récursif en cas de non-correspondance
    else
        echo "$new_password" | sudo tee "$password_file" > /dev/null
        zenity --info --title="Information" --text="$default_password_success_message"
    fi
}

# Fonction pour configurer les dates des messages Zenity
configure_zenity_dates() {
    # Saisie des dates
    date_one=$(zenity --calendar --title="Configurer la première date Zenity" --text="Sélectionnez la première date pour l'apparition de la notification Zenity." --date-format="%Y-%m-%d" --window-icon="calendar" --width=300 --height=300)
    date_two=$(zenity --calendar --title="Configurer la deuxième date Zenity" --text="Sélectionnez la deuxième date pour l'apparition de la notification Zenity." --date-format="%Y-%m-%d" --window-icon="calendar" --width=300 --height=300)
    date_three=$(zenity --calendar --title="Configurer la troisième date Zenity" --text="Sélectionnez la troisième date pour l'apparition de la notification Zenity." --date-format="%Y-%m-%d" --window-icon="calendar" --width=300 --height=300)

    # Écriture des dates dans les fichiers
    echo "$date_one" | sudo tee "$zenity_config_file" > /dev/null
    echo "$date_two" | sudo tee -a "$zenity_config_file" > /dev/null
    echo "$date_three" | sudo tee -a "$zenity_config_file" > /dev/null
}

# Demander à l'utilisateur de choisir la date et l'heure d'expiration
expiration_datetime=$(get_expiration_datetime)

# Assurer que le script a les permissions pour écrire dans le fichier
echo "$expiration_datetime" | sudo tee "$expiration_date_file" > /dev/null

# Notification pour informer que la date a été enregistrée avec succès
zenity --info --title="Information" --text="Moment d'échéance : $expiration_datetime"

# Configurer le mot de passe
configure_password

# Configurer les dates des messages Zenity
configure_zenity_dates

# Afficher un message pour indiquer que le script est lancé
zenity --info --title="Info" --text="LinuxSafeRent est lancé"

