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


if [ "$env_value" = "blue" ]; then
    docker exec -it projet-rentree-front-blue chmod u+x ./change_back_port.sh
    docker exec -it projet-rentree-front-blue ./change_back_port.sh 8081
else
    docker exec -it projet-rentree-front-green chmod u+x ./change_back_port.sh
    docker exec -it projet-rentree-front-green ./change_back_port.sh 8080
fi


