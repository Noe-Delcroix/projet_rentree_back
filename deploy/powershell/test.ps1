# Nom du conteneur Docker
$nomConteneur = "projet-rentree-back"

# Commande pour exécuter les tests Maven à l'intérieur du conteneur
$commandeTest = "mvn test"

# Exécuter les tests Maven dans le conteneur
Write-Host "Exécution des tests Maven dans le conteneur Docker : $nomConteneur"
$dockerCommand = "docker exec $nomConteneur $commandeTest"
Invoke-Expression $dockerCommand

# Vérifier si les tests ont réussi
if ($LASTEXITCODE -eq 0) {
    Write-Host "Les tests Maven ont réussi dans le conteneur."
} else {
    Write-Host "Les tests Maven ont échoué dans le conteneur."
    exit $LASTEXITCODE
}
