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

# Nom du conteneur SonarQube
nom_du_conteneur="sonarqube"

# Vérifier si le conteneur existe
if docker ps -a --filter "name=$nom_du_conteneur" | grep -q "$nom_du_conteneur"; then
    # Vérifier si le conteneur est arrêté
    if docker ps --filter "name=$nom_du_conteneur" | grep -q "$nom_du_conteneur"; then
        echo "Le conteneur $nom_du_conteneur est déjà en cours d'exécution."
    else
        # Démarrer le conteneur
        docker start "$nom_du_conteneur"
        echo "Conteneur $nom_du_conteneur démarré avec succès."
    fi
else
    echo "Le conteneur $nom_du_conteneur n'existe pas."
fi

# Vérifie si un conteneur SonarQube est déjà lancé sur les mêmes ports
existingContainer=$(docker ps --filter "publish=9000" --filter "publish=9092" -q)
if [ -z "$existingContainer" ]; then
    echo "Un conteneur SonarQube n'est pas déjà en cours d'exécution sur les mêmes ports."
    docker run -d --name sonarqube --network mon-reseau -p 9000:9000 -p 9092:9092 sonarqube:latest
    sonarqubeIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube)
    echo "ip du conteneur : $sonarqubeIP"
    if [ -z "$sonarqubeIP" ]; then
        echo "Erreur : L'adresse IP du conteneur SonarQube n'a pas été récupérée."
        exit 1
    fi
    echo "URL de SonarQube : $sonarqubeURL"
    echo "On va attendre ensemble 40 sec que SonarQube se lance"
    sleep 40
    echo "SonarQube est maintenant prêt !"
else
    sonarqubeIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube)
fi

# Informations d'authentification
adminUsername="admin"
adminPassword="admin"
newPassword="admin1"

# URL de SonarQube
sonarqubeURL="http://localhost:9000"

# Essayer de se connecter avec le nouveau mot de passe
echo "Tentative de connexion à SonarQube avec le nouveau mot de passe..."
testConnectionResponse=$(curl -s -o /dev/null -w "%{http_code}" -u "${adminUsername}:${newPassword}" "${sonarqubeURL}/api/authentication/validate")

# Vérifier la réponse de la tentative de connexion
if [ "$testConnectionResponse" -eq "200" ]; then
    echo "Connexion réussie avec le nouveau mot de passe. Pas besoin de changer le mot de passe."
else
    echo "Echec de la connexion avec le nouveau mot de passe. Changement de mot de passe en cours..."

    # Changement de mot de passe
    changePasswordResponse=$(curl -s -o /dev/null -w "%{http_code}" -u "${adminUsername}:${adminPassword}" -X POST "${sonarqubeURL}/api/users/change_password?login=${adminUsername}&previousPassword=${adminPassword}&password=${newPassword}")

    # Vérification de la réponse de la requête de changement de mot de passe
    if [ "$changePasswordResponse" -eq "200" ]; then
        echo "Mot de passe changé avec succès."
    else
        echo "Erreur lors du changement de mot de passe. Réponse HTTP: $changePasswordResponse"
        exit 1
    fi
fi


# Mise à jour des informations d'authentification avec le nouveau mot de passe
base64AuthInfo=$(echo -n "${adminUsername}:${newPassword}" | base64)

# Vérifie si l'URL de SonarQube est accessible avec le nouveau mot de passe
if ! curl -s -f -u "${adminUsername}:${newPassword}" $sonarqubeURL; then
    echo "Erreur : Impossible de se connecter à l'URL de SonarQube ($sonarqubeURL) avec le nouveau mot de passe."
    exit 1
fi

# Configuration des paramètres pour la requête de création de projet
projectName="back"
projectKey="back"
projectVisibility="public"

# URL pour interroger les projets existants
sonarqubeProjectsQueryURL="$sonarqubeURL/api/projects/search"

# Requête pour vérifier si le projet existe
projectsResponse=$(curl -s -u "${adminUsername}:${newPassword}" "$sonarqubeProjectsQueryURL?projects=$projectKey")

# Extraire la présence du projet à partir de la réponse
projectExists=$(echo $projectsResponse | grep -o "\"key\":\"$projectKey\"")

if [ -z "$projectExists" ]; then
    echo "Le projet '$projectName' n'existe pas. Création du projet en cours."

    # URL pour la création de projet
    sonarqubeCreateProjectURL="$sonarqubeURL/api/projects/create"

    # Données pour la création de projet
    projectCreateData="name=$projectName&project=$projectKey&visibility=$projectVisibility"

    # Envoi de la requête POST pour créer le projet et capture du code de statut HTTP
    createProjectResponse=$(curl -s -o /dev/null -w "%{http_code}" -u "${adminUsername}:${newPassword}" -X POST -d "$projectCreateData" "$sonarqubeCreateProjectURL")

    # Vérification du code de statut HTTP
    if [ "$createProjectResponse" -eq 200 ]; then
        echo "Projet '$projectName' créé avec succès dans SonarQube."
    else
        echo "Erreur lors de la création du projet '$projectName'. Code de statut HTTP: $createProjectResponse"
        exit 1
    fi


    if [ "$createProjectResponse" -eq "200" ]; then
        echo "Projet '$projectName' créé avec succès dans SonarQube."
    else
        echo "Erreur lors de la création du projet '$projectName'. Réponse HTTP: $createProjectResponse"
        exit 1
    fi
else
    echo "Le projet '$projectName' existe déjà dans SonarQube."
fi
# Génération d'un nom de token aléatoire
generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1
}

tokenName=$(generate_random_string)
echo "Nom du token généré : $tokenName"

# Préparation du payload pour la requête
tokenGenerationQueryString="name=$tokenName"

# URL pour la génération du token
sonarqubeTokenGenerationURL="$sonarqubeURL/api/user_tokens/generate"

# Envoi de la requête
tokenResponse=$(curl -s -u "${adminUsername}:${newPassword}" -X POST -d "$tokenGenerationQueryString" -H "Content-Type: application/x-www-form-urlencoded" $sonarqubeTokenGenerationURL)
if [ -z "$tokenResponse
" ]; then
echo "Erreur lors de la génération du token"
exit 1
fi
echo "Token généré avec succès"

sonarToken=$(echo "$tokenResponse" | grep -oP '(?<="token":")[^"]*')

sonarqubeURL="http://$sonarqubeIP:9000"

echo "SonarQube URL: $sonarqubeURL"
echo "Sonar Token: $sonarToken"

nomConteneur="projet_rentree_back_$env_value"

dockerCommand="docker exec -e SONAR_HOST_URL=$sonarqubeURL -e SONAR_TOKEN=$sonarToken $nomConteneur mvn clean verify sonar:sonar"
echo "Exécution de la commande Docker pour l'analyse SonarQube"
eval $dockerCommand

