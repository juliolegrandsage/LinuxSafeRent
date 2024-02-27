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

# Fonction pour configurer les messages Zenity
configure_zenity_messages() {
    # Vérifier si le fichier de configuration Zenity existe
    if [ -e "$zenity_config_file" ]; then
        # Charger les messages Zenity à partir du fichier
        current_content=$(sudo cat "$zenity_config_file")
    else
        # Utiliser les messages Zenity par défaut
        current_content="$default_expiration_message"
    fi

    # Afficher une boîte de dialogue avec une zone de texte contenant le contenu actuel
    new_content=$(zenity --text-info --title="Édition des messages Zenity" --editable --width=400 --height=300 --text="$current_content")

    # Enregistrer le nouveau contenu dans le fichier
    echo "$new_content" | sudo tee "$zenity_config_file" > /dev/null
}

# Fonction pour configurer les messages d'avertissement
configure_warning_messages() {
    # Vérifier si le fichier de configuration des messages d'avertissement existe
    if [ -e "$warning_config_file" ]; then
        # Charger les messages d'avertissement à partir du fichier
        current_content=$(sudo cat "$warning_config_file")
    else
        # Utiliser les messages d'avertissement par défaut
        current_content="$default_warning_message"
    fi

    # Afficher une boîte de dialogue avec une zone de texte contenant le contenu actuel
    new_content=$(zenity --text-info --title="Édition des messages d'avertissement" --editable --width=400 --height=300 --text="$current_content")

    # Enregistrer le nouveau contenu dans le fichier
    echo "$new_content" | sudo tee "$warning_config_file" > /dev/null
}

# Demander à l'utilisateur de configurer les messages Zenity
configure_zenity_messages

# Demander à l'utilisateur de configurer les messages d'avertissement
configure_warning_messages

# Demander à l'utilisateur de choisir la date et l'heure d'expiration
expiration_datetime=$(get_expiration_datetime)

# Assurer que le script a les permissions pour écrire dans le fichier
echo "$expiration_datetime" | sudo tee "$expiration_date_file" > /dev/null

# Notification pour informer que la date a été enregistrée avec succès
zenity --info --title="Information" --text="Moment d'échéance : $expiration_datetime"

# Configurer le mot de passe
configure_password
zenity --info --title="Info" --text="Configuration terminée. Redemarrage dans 1 minute."

sudo shutdown -r +1

