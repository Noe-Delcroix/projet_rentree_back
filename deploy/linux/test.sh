#!/bin/bash

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

# Commande pour exécuter les tests Maven à l'intérieur du conteneur
commandeTest="mvn test"

# Exécuter les tests Maven dans le conteneur
echo "Exécution des tests Maven dans le conteneur Docker : $nomConteneur"
docker exec $nomConteneur $commandeTest

# Vérifier si les tests ont réussi
if [ $? -eq 0 ]; then
    echo "Les tests Maven ont réussi dans le conteneur."
else
    echo "Les tests Maven ont échoué dans le conteneur."
    exit $?
fi
