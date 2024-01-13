# Utilisation de l'image Docker officielle d'Ubuntu
FROM ubuntu:latest

# Installez les packages nécessaires (comme OpenJDK, Maven et dos2unix)
RUN apt-get update && apt-get install -y openjdk-17-jdk maven dos2unix

# Create app directory
WORKDIR /usr/src/app

# Copiez le fichier pom.xml (et éventuellement d'autres fichiers de configuration Maven)
COPY pom.xml ./
COPY run.sh ./

# Copiez tout le contenu du projet Maven dans le conteneur
COPY . .

RUN chmod +x /usr/src/app/run.sh

RUN dos2unix /usr/src/app/run.sh

EXPOSE 8080
# Commande par défaut pour exécuter l'application (remplacée par une commande qui ne fait rien)
CMD tail -f /dev/null