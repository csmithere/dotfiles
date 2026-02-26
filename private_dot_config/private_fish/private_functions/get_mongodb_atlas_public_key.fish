function get_mongodb_atlas_public_key -d "Get MongoDB Atlas public key (lazy-loaded from 1Password)"
    if not set -q MONGODB_ATLAS_PUBLIC_KEY
        set -gx MONGODB_ATLAS_PUBLIC_KEY (op read "op://Private/MongoDB Atlas/publicKey")
    end
    echo $MONGODB_ATLAS_PUBLIC_KEY
end
