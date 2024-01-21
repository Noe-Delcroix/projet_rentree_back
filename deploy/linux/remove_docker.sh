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

nom_du_conteneur_inverse=""

if [ "$env_value" = "blue" ]; then
    nom_du_conteneur_inverse="projet_rentree_back_green"
else
    nom_du_conteneur_inverse="projet_rentree_back_blue"
fi

# Vérifier si le conteneur existe
if docker ps -a | grep -q "$nom_du_conteneur_inverse"; then
    # Supprimer le conteneur
    docker stop "$nom_du_conteneur_inverse"
    echo "Conteneur $nom_du_conteneur_inverse arrêté avec succès."
    docker rm "$nom_du_conteneur_inverse"
    echo "Conteneur $nom_du_conteneur_inverse supprimé avec succès."
else
    echo "Le conteneur $nom_du_conteneur_inverse n'existe pas."
fi

# Vérifier la valeur de env_value et supprimer l'image en conséquence
image_name=""
if [ "$env_value" == "blue" ]; then
    image_name="projet_rentree_back:green"  # Remplacez par le nom de l'image avec le tag "green" que vous souhaitez supprimer
elif [ "$env_value" == "green" ]; then
    image_name="projet_rentree_back:blue"  # Remplacez par le nom de l'image avec le tag "blue" que vous souhaitez supprimer
else
    echo "La valeur de env_value n'est ni 'blue' ni 'green'. Aucune image n'a été supprimée."
    exit 1
fi

# Supprimer l'image
docker rmi "$image_name"

echo "L'image $image_name a été supprimée avec succès."