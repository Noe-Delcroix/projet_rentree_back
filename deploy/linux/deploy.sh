#!/bin/bash

# Nom du conteneur Docker
nomConteneur="projet-rentree-back"

# Commande à exécuter dans le conteneur
commande="/usr/src/app/run.sh"

# Exécute la commande dans le conteneur Docker
echo "Exécution de la commande dans le conteneur Docker : $nomConteneur"
docker exec $nomConteneur $commande

# Vérifie le code de retour de la commande
if [ $? -eq 0 ]; then
    echo "La commande a été exécutée avec succès dans le conteneur."
else
    echo "La commande a échoué dans le conteneur."
    exit $?
fi
