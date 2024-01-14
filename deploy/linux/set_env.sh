#!/bin/bash

# Obtenir le nom du répertoire parent de ../../
parent_directory=$(basename $(dirname $(realpath ../../)))

echo "Le répertoire parent du projet est $parent_directory"
# Modifier la valeur de la variable env dans le fichier ../env.env
env_file="../env.env"

if [ -f "$env_file" ]; then
    # Vérifier si le fichier existe
    # Utiliser sed pour modifier la valeur de la variable env
    if [[ "$parent_directory" == *_b ]]; then
        sed -i "s/^env=.*/env=blue/" "$env_file"
        echo "La valeur de la variable 'env' dans $env_file a été mise à jour avec 'blue'."
    else
        sed -i "s/^env=.*/env=green/" "$env_file"
        echo "La valeur de la variable 'env' dans $env_file a été mise à jour avec 'green'."
    fi
else
    echo "Le fichier $env_file n'existe pas dans le répertoire parent."
fi
