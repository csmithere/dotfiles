# Completions for list_dockerhub_repos function
complete -c list_dockerhub_repos -f -d "List DockerHub repositories for a namespace"

# Provide some common namespace examples
complete -c list_dockerhub_repos -f -a "bitnami" -d "Bitnami namespace"
complete -c list_dockerhub_repos -f -a "library" -d "Official Docker images"
