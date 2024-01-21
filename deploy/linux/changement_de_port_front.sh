#!/bin/bash

# Chemin vers le fichier env.env
env_file="../env.env"

back_env_value=""
# Vérifier si le fichier existe
if [ -f "$env_file" ]; then
    # Utiliser grep pour rechercher la ligne contenant la variable env
    env_line=$(grep '^env=' "$env_file")

    # Vérifier si la ligne a été trouvée
    if [ -n "$env_line" ]; then
        # Utiliser cut pour extraire la valeur de la variable env
        back_env_value=$(echo "$env_line" | cut -d'=' -f2)
        echo "La valeur de 'env' est : $back_env_value"
    else
        echo "La variable 'env' n'a pas été trouvée dans $env_file."
    fi
else
    echo "Le fichier $env_file n'existe pas."
fi

# Nom recherché
search_name="projet_rentree_front"

# Exécuter "docker ps" pour lister les conteneurs en cours d'exécution
# Utiliser "grep" pour filtrer les résultats par le nom du conteneur
# Utiliser "awk" pour extraire le dernier mot du nom du conteneur
front_env_value=$(docker ps --format "{{.Names}}" | grep "$search_name" | awk -F '-' '{print $NF}')

if [ -z "$front_env_value" ]; then
    echo "Pas de conteneur front."
else
    echo "Le dernier mot du nom du conteneur est : $front_env_value"

    if [ "$front_env_value" = "projet_rentree_front_blue" ]; then
        if [ "$back_env_value" = "blue" ]; then
            docker exec projet_rentree_front_blue chmod u+x ./change_back_port.sh
            docker exec projet_rentree_front_blue ./change_back_port.sh 8081
        else
            docker exec projet_rentree_front_blue chmod u+x ./change_back_port.sh
            docker exec projet_rentree_front_blue ./change_back_port.sh 8080
        fi
    else
        if [ "$back_env_value" = "green" ]; then
            docker exec projet_rentree_front_green chmod u+x ./change_back_port.sh
            docker exec projet_rentree_front_green ./change_back_port.sh 8081
        else
            docker exec projet_rentree_front_green chmod u+x ./change_back_port.sh
            docker exec projet_rentree_front_green ./change_back_port.sh 8080
        fi
    fi
fi

