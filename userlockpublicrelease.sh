#!/bin/bash

# Chemin vers le fichier de date d'expiration
expiration_date_file="fin_acces_date.txt"
# Chemin vers le fichier contenant le mot de passe
password_file="password.txt"
# Chemin vers le fichier contenant les messages Zenity
zenity_config_file="zenity_config.txt"
# Chemin vers le fichier contenant les messages d'avertissement
warning_config_file="warning_config.txt"

# Messages Zenity par défaut
default_expiration_message="Vous êtes dans la dernière période de 30 jours avant la date d'échéance.\n\nPensez à renouveler votre accès.\n\nContact : 06 22 09 86 53 / clech.michel@wanadoo.fr"
default_password_success_message="Mot de passe configuré avec succès"
default_warning_message="Attention ! Votre accès expire bientôt. Veuillez renouveler votre accès."

# Fonction pour obtenir la date et l'heure d'expiration avec Zenity
get_expiration_datetime() {
    # Sélection de la date
    selected_date=$(zenity --calendar --title="Choisir la date d'expiration" --text="Sélectionnez la date d'expiration de l'accès." --date-format="%Y-%m-%d" --window-icon="calendar" --width=300 --height=300)
	
		selected_time="00:00"
    echo "$selected_date $selected_time"
}


# Demander à l'utilisateur de choisir la date et l'heure d'expiration
expiration_datetime=$(get_expiration_datetime)

# Assurer que le script a les permissions pour écrire dans le fichier
echo "$expiration_datetime" | sudo tee "$expiration_date_file" > /dev/null

# Notification pour informer que la date a été enregistrée avec succès
zenity --info --title="Information" --text="Moment d'échéance : $expiration_datetime"


# Informer que la configuration est terminée et que le redémarrage aura lieu dans 1 minute
zenity --info --title="Info" --text="Configuration terminée. Redémarrage dans 1 minute."

# Redémarrer le système dans 1 minute
sudo shutdown -r +1

