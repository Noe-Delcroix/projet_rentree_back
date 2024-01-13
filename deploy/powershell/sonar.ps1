# Crée un réseau Docker personnalisé
docker network create mon-reseau

$adminUsername = "admin"
$adminPassword = "admin"
$newPassword = "admin1"
$sonarqubeURL = "http://localhost:9000"
$headers = @{}
# Vérifie si un conteneur SonarQube est déjà lancé sur les mêmes ports
$sonarqubeIP=""
$existingContainer = docker ps --filter "publish=9000" --filter "publish=9092" -q
if (!$existingContainer) {
    Write-Host "Un conteneur SonarQube n'est pas déjà en cours d'exécution sur les mêmes ports."
    # Lance le conteneur SonarQube sur le réseau personnalisé
    docker run -d --name sonarqube --network mon-reseau -p 9000:9000 -p 9092:9092 sonarqube:latest

    # Récupère l'adresse IP attribuée au conteneur SonarQube
    $sonarqubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube
    Write-Host "ip du conteneur : $sonarqubeIP"

    # Vérifie si l'adresse IP a été récupérée correctement
    if (-not $sonarqubeIP) {
        Write-Host "Erreur : L'adresse IP du conteneur SonarQube n'a pas été récupérée."
        exit
    }

    # Configuration des paramètres
    Write-Host "URL de SonarQube : $sonarqubeURL"

    Write-Host "On va attendre ensemble 40 sec que SonarQube se lance"
    Start-Sleep -Seconds 40
    Write-Host "SonarQube est maintenant prêt !"

    # Authentification initiale
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${adminUsername}:${adminPassword}"))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
    }

    # Vérifie si l'URL de SonarQube est accessible
    try {
        Invoke-WebRequest -Uri $sonarqubeURL -UseBasicParsing
    } catch {
        Write-Host "Erreur : Impossible de se connecter à l'URL de SonarQube ($sonarqubeURL)."
        exit
    }

    # Changer le mot de passe de l'admin avec curl
    $curlCommand = 'curl'
    $curlArgs = '-u', 'admin:admin', '-X', 'POST', "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=$newPassword"

    Write-Host "Envoi de la requête de changement de mot de passe avec curl"

    try {
        Start-Process $curlCommand -ArgumentList $curlArgs -NoNewWindow -Wait
        Write-Host "Mot de passe changé avec succès."
    } catch {
        Write-Host "Erreur lors du changement de mot de passe avec curl."
        Write-Host "Détails de l'erreur : $_"
        exit
    }
}else{
    $sonarqubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube

}

# Mettre à jour les informations d'authentification avec le nouveau mot de passe
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${adminUsername}:${newPassword}"))
$headers["Authorization"] = "Basic $base64AuthInfo"

# Vérifie si l'URL de SonarQube est accessible avec le nouveau mot de passe
try {
    Invoke-WebRequest -Uri $sonarqubeURL -UseBasicParsing -Headers $headers
} catch {
    Write-Host "Erreur : Impossible de se connecter à l'URL de SonarQube ($sonarqubeURL) avec le nouveau mot de passe."
    exit
}
# Configuration des paramètres pour la requête de création de projet
$projectName = "back"  # Remplacez par le nom réel de votre projet
$projectKey = "back"          # Clé unique pour le projet
$projectVisibility = "public" # Peut être "public" ou "private"

# URL pour interroger les projets existants
$sonarqubeProjectsQueryURL = $sonarqubeURL + "/api/projects/search"

# ...

try {
    $projectsResponse = Invoke-RestMethod -Uri $sonarqubeProjectsQueryURL -Method Get -Headers $headers

    if ($null -eq $projectsResponse) {
        Write-Host "La réponse de l'appel à l'API est null. Vérifiez l'URL de l'API."
        exit
    }

    if ($null -ne $projectsResponse.components) {
        $projects = $projectsResponse.components | Where-Object { $_.key -eq $projectKey }

        if ($null -ne $projects) {
            Write-Host "Le projet '$projectName' existe déjà dans SonarQube."
        } else {
            # Le projet n'existe pas, procédez à la création
            # ...

        }
    } else {
        Write-Host "Aucun projet trouvé dans la réponse de l'appel à l'API."
    }
} catch {
    Write-Host "Erreur lors de la vérification des projets existants : $_"
    exit
}

function Generate-RandomString {
    $randomString = [System.IO.Path]::GetRandomFileName() + [System.IO.Path]::GetRandomFileName()
    return $randomString.Substring(0, 20).Replace(".", "")
}

# Paramètres pour la création du token
$tokenName = Generate-RandomString
Write-Host "Nom du token généré : $tokenName"

# Préparation du payload pour la requête
$tokenGenerationPayload = @{
    "name" = $tokenName
}

# Convertit le payload en chaîne de requête pour l'URL (format x-www-form-urlencoded)
$tokenGenerationQueryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
foreach ($key in $tokenGenerationPayload.Keys) {
    $tokenGenerationQueryString[$key] = $tokenGenerationPayload[$key]
}
$tokenGenerationString = $tokenGenerationQueryString.ToString()

# URL pour la génération du token
$sonarqubeTokenGenerationURL = $sonarqubeURL + "/api/user_tokens/generate"

# Envoi de la requête
try {
    $tokenResponse = Invoke-RestMethod -Uri $sonarqubeTokenGenerationURL -Method Post -Headers $headers -ContentType "application/x-www-form-urlencoded" -Body $tokenGenerationString
    Write-Host "Token généré avec succès : $($tokenResponse.token)"
} catch {
    Write-Host "Erreur lors de la génération du token : $_"
    exit
}

# Mise à jour de l'URL de SonarQube pour utiliser l'adresse IP du conteneur
$sonarqubeURL = "http://" + $sonarqubeIP +":9000"

# Affichage des informations pour le débogage
Write-Host "SonarQube URL: $sonarqubeURL"
Write-Host "Sonar Token: $($tokenResponse.token)"

# Commande pour exécuter l'analyse SonarQube à l'intérieur du conteneur Docker
$dockerCommand = "docker exec -e SONAR_HOST_URL=" + $sonarqubeURL +" -e SONAR_TOKEN=" + $tokenResponse.token + "  projet-rentree-back mvn clean verify sonar:sonar"
Write-Host "Exécution de la commande Docker pour l'analyse SonarQube"
Invoke-Expression $dockerCommand