function get_mongodb_atlas_private_key -d "Get MongoDB Atlas private key (lazy-loaded from 1Password)"
    if not set -q MONGODB_ATLAS_PRIVATE_KEY
        set -gx MONGODB_ATLAS_PRIVATE_KEY (op read "op://Private/MongoDB Atlas/privateKey")
    end
    echo $MONGODB_ATLAS_PRIVATE_KEY
end
