#!/bin/bash

# Définir la date de fin à une minute à partir de maintenant
end_date=$(date -d "+1 minute" +"%Y-%m-%d %H:%M:%S")

echo "Date actuelle : $(date +"%Y-%m-%d %H:%M:%S")"
echo "Fin de votre accès : $end_date"

# Enregistrez la date de fin dans un fichier
echo "$end_date" > ~/fin_acces_date.txt

# Notification pour informer que la date a été enregistrée
zenity --info --title="Information" --text="Date enregistrée avec succès !"

# Boucle pour afficher les notifications du temps restant chaque 10 secondes
while true; do
    current_date=$(date +"%Y-%m-%d %H:%M:%S")
    remaining_seconds=$(( $(date -d "$end_date" +%s) - $(date -d "$current_date" +%s) ))

    # Si le temps restant est inférieur ou égal à zéro, effectuer les actions finales
    if [ $remaining_seconds -le 0 ]; then
        # Changez le mot de passe de l'utilisateur avec le nouveau mot de passe "Gandalf"
        echo -e "Gandalf\nGandalf" | sudo passwd $(whoami)

        # Déconnectez l'utilisateur pour le renvoyer à l'écran de connexion
        sudo pkill -u $(whoami)

        break
    fi

    remaining_minutes=$(( $remaining_seconds / 60 ))
    remaining_seconds=$(( $remaining_seconds % 60 ))

    notify-send "Temps restant" "Il reste $remaining_minutes minutes et $remaining_seconds secondes d'accès."

    sleep 10  # Attendre 10 secondes avant de vérifier à nouveau
done

echo "Accès expiré."
