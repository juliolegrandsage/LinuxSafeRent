# Procédure d'installation du script de blocage de session
# Association Défis - 8 rue du Général LECLERC - 56600 Lanester
# Date de création: 5/12/2022

# Version: 0.1
# Date de mise à jour:

# Configuration système: Linux Mint

########################################################################################
########################################################################################
########################################################################################

Dans un premier temps, rendre le fichier script_install executable puis executez le
chmod +x script_install
sudo ./script_install

Les logs de l'intallation se trouve dans /tmp/lock_install.log

La commande:
sudo nano /etc/.lock_X11/.expire_date
permet de changer manuellement la date de blocage de session

Pour modifier les messages de rappel aux utilisateurs, modifier les tactes dans .expire_users_warning
> Possibilité aussi de modifier la fréquence d'apparition en modifiant :
    # Default Warning
    WARNING1=60
    WARNING2=30
    WARNING3=15
    WARNING4=8
    WARNING5=3
en début de fichier (valeur en jour)


Pour modifier la durée de blocage (1 an, 3 mois,...) modifier dans .active_session
NEXT_DATE_ACT=$(date --date 'next year' "+%d/%m/%Y")
ou 'next year' peut être remplacé par '3 month',...
