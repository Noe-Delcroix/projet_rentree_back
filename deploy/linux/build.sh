#!/bin/bash

echo "set env"
./set_env.sh

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
nomConteneur="projet-rentree-back-$env_value"

# Vérifie si un conteneur avec le même nom existe déjà et le supprime le cas échéant
conteneurExistant=$(docker ps -a -q -f name=^/${nomConteneur}$)
if [ ! -z "$conteneurExistant" ]; then
    echo "Un conteneur avec le nom $nomConteneur existe déjà. Suppression du conteneur."
    docker rm -f $nomConteneur
fi

# Construit l'image Docker pour le projet Maven
docker build ../../. -t projet-rentree-back:"$env_value"
echo "Image Docker construite"

# Lance le conteneur Docker du projet Maven sur le réseau personnalisé, le build est lancé automatiquement
docker run --name $nomConteneur-"$env_value" --network mon-reseau -p 8080:8080 -d projet-rentree-back:"$env_value"
echo "Conteneur Docker lancé"

# Commande à exécuter dans le conteneur
commande="mvn clean install -DskipTests"

# Exécute la commande dans le conteneur Docker
echo "Exécution de la commande dans le conteneur Docker : $nomConteneur $env_value"
docker exec $nomConteneur $commande
