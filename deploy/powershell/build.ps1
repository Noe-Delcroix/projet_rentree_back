# Construit l'image Docker pour le projet Maven
& docker build ../../. -t projet-rentree-back

Write-Host "Image Docker construite"

# Nom du conteneur Docker
$nomConteneur = "projet-rentree-back"

# Lance le conteneur Docker du projet Maven sur le réseau personnalisé, le build est lancé automatiquement
& docker run --name $nomConteneur --network mon-reseau -p 8080:8080 -d projet-rentree-back

Write-Host "Conteneur Docker lancé"

# Commande à exécuter dans le conteneur
$commande = "mvn clean install -DskipTests"

# Exécute la commande dans le conteneur Docker
Write-Host "Exécution de la commande dans le conteneur Docker : $nomConteneur"
$dockerCommand = "docker exec $nomConteneur $commande"
& Invoke-Expression $dockerCommand
