#!/bin/bash

# Nom du conteneur Docker
nomConteneur="projet-rentree-back"

# Vérifie si un conteneur avec le même nom existe déjà et le supprime le cas échéant
conteneurExistant=$(docker ps -a -q -f name=^/${nomConteneur}$)
if [ ! -z "$conteneurExistant" ]; then
    echo "Un conteneur avec le nom $nomConteneur existe déjà. Suppression du conteneur."
    docker rm -f $nomConteneur
fi

# Construit l'image Docker pour le projet Maven
docker build ../../. -t projet-rentree-back
echo "Image Docker construite"

# Lance le conteneur Docker du projet Maven sur le réseau personnalisé, le build est lancé automatiquement
docker run --name $nomConteneur --network mon-reseau -p 8080:8080 -d projet-rentree-back
echo "Conteneur Docker lancé"

# Commande à exécuter dans le conteneur
commande="mvn clean install -DskipTests"

# Exécute la commande dans le conteneur Docker
echo "Exécution de la commande dans le conteneur Docker : $nomConteneur"
docker exec $nomConteneur $commande
