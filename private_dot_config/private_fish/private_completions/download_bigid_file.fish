# Completions for download_bigid_file function
complete -c download_bigid_file -f -d "Download BigID release artifacts"

# Complete with available file types
complete -c download_bigid_file -f -a "compose" -d "Download docker-compose file"
complete -c download_bigid_file -f -a "images" -d "Download images"
complete -c download_bigid_file -f -a "images-scanner" -d "Download scanner images"
complete -c download_bigid_file -f -a "images-labeler" -d "Download labeler images"
