#!/bin/bash

# Chemin vers le fichier env.env
env_file="../env.env"

env_value=""
# Vérifier si le fichier existe
if [ -f "$env_file" ]; then
    # Utiliser grep pour rechercher la ligne contenant la variable env
    env_line=$(grep '^env=' "$env_file")

    # Vérifier si la ligne a été trouvée
    if [ -n "$env_line" ]; then
        # Utiliser cut pour extraire la valeur de la variable env
        env_value=$(echo "$env_line" | cut -d'=' -f2)
        echo "La valeur de 'env' est : $env_value"
    else
        echo "La variable 'env' n'a pas été trouvée dans $env_file."
    fi
else
    echo "Le fichier $env_file n'existe pas."
fi


# Nom du conteneur Docker
nomConteneur="projet_rentree_back_$env_value"

# Commande à exécuter dans le conteneur
commande="/usr/src/app/run.sh"

# Exécute la commande dans le conteneur Docker
echo "Exécution de la commande dans le conteneur Docker : $nomConteneur"
docker exec "$nomConteneur" $commande

# Vérifie le code de retour de la commande
if [ $? -eq 0 ]; then
    echo "La commande a été exécutée avec succès dans le conteneur."
else
    echo "La commande a échoué dans le conteneur."
    exit $?
fi
chmod u+x ./remove_docker.sh
chmod u+x ./changement_de_port_front.sh
./remove_docker.sh
./changement_de_port_front.sh
