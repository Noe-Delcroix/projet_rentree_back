#!/bin/bash

# Nom du conteneur Docker
nomConteneur="projet-rentree-back"

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
