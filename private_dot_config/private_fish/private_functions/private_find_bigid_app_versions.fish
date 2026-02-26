function find_bigid_app_versions -d "Find compatible BigID external app versions"
    # Parse arguments
    set -l release_version ""
    set -l from_tfvars ""
    set -l show_all false

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --from-tfvars
                set i (math $i + 1)
                set from_tfvars $argv[$i]
            case --all -a
                set show_all true
            case -h --help
                echo "Usage: find_bigid_app_versions <RELEASE_NUMBER> [--all]"
                echo "       find_bigid_app_versions --from-tfvars <FILE> [--all]"
                echo ""
                echo "Options:"
                echo "  --all, -a           Show all tags including commit-hash suffixed versions"
                echo "  --from-tfvars FILE  Parse release number from terraform.tfvars file"
                echo "  -h, --help          Show this help message"
                echo ""
                echo "Example: find_bigid_app_versions 237"
                echo "         find_bigid_app_versions 237 --all"
                return 0
            case '*'
                set release_version $argv[$i]
        end
        set i (math $i + 1)
    end

    # Extract release number from tfvars if specified
    set -l active_tags
    set -l current_values
    if test -n "$from_tfvars"
        if not test -f "$from_tfvars"
            echo "Error: File not found: $from_tfvars" >&2
            return 1
        end
        # Extract chart_version or image_tag from tfvars
        set release_version (grep -E '(chart_version|image_tag)\s*=' "$from_tfvars" | head -1 | sed -E 's/.*"([0-9]{3}).*/\1/')

        # Parse which image tags are active (uncommented) in the tfvars file
        set active_tags (grep -E '^\s*(databricks_discovery_image_tag|ontap_discovery_image_tag|doc_classifiers_generator_image_tag|retention_image_tag|remediation_image_tag|databricks_image_tag|snowflake_masking_image_tag|classifier_helper_image_tag)\s*=' "$from_tfvars" | sed -E 's/^[[:space:]]*([a-z_]+)[[:space:]]*=.*/\1/')

        # Parse current values from tfvars file
        for tag in $active_tags
            set -l current_val (grep -E "^\s*$tag\s*=" "$from_tfvars" | sed -E 's/.*"([^"]+)".*/\1/')
            set -a current_values "$tag:$current_val"
        end
    end

    # Validate release version
    if test -z "$release_version"
        echo "Usage: find_bigid_app_versions <RELEASE_NUMBER>" >&2
        echo "       find_bigid_app_versions --from-tfvars <FILE>" >&2
        echo "Example: find_bigid_app_versions 237" >&2
        return 1
    end

    # Extract just the release number (e.g., "237" from "237.26.0")
    set release_version (echo $release_version | sed -E 's/^.*([0-9]{3}).*/\1/')

    # External app configuration
    # Image names match actual Docker Hub repositories (verified from Terraform modules)
    # Multi-container apps use primary container name
    # Format: var_name:image_name:fallback_default
    set -l apps \
        "databricks_discovery_image_tag:bigid-databricks-discovery:1.0.7.202" \
        "ontap_discovery_image_tag:bigid-ontap-discovery:" \
        "doc_classifiers_generator_image_tag:bigid-doc-classifiers-generator:230.1.0" \
        "retention_image_tag:data-retention-web-gateway:3.4.3.200" \
        "remediation_image_tag:bigid-remediation-ui-bff:227.5" \
        "databricks_image_tag:bigid-databricks:227.1" \
        "snowflake_masking_image_tag:bigid-snowflake-masking:231.3" \
        "classifier_helper_image_tag:bigid-classifier-helper:3.0.3"

    # Repositories to check
    set -l repositories "bigexchange" "bigid"

    # Authenticate with Docker Hub
    echo "Authenticating with DockerHub API..." >&2
    set -l api_token (__dockerhub_auth)
    or return 1

    echo "Searching for apps compatible with BigID release $release_version..." >&2
    if test (count $active_tags) -gt 0
        echo "(Checking only "(count $active_tags)" active image tag(s) from tfvars file)" >&2
    end
    echo "" >&2

    # Results array
    set -l results

    # Process each app
    for app_config in $apps
        set -l parts (string split ':' $app_config)
        set -l var_name $parts[1]
        set -l image_name $parts[2]
        set -l fallback_default $parts[3]

        # Skip if active_tags is set and this var is not in it
        if test (count $active_tags) -gt 0
            if not contains $var_name $active_tags
                continue
            end
        end

        # Get current value from tfvars file if available, otherwise use fallback
        set -l current_default $fallback_default
        for current_val_entry in $current_values
            set -l val_parts (string split ':' $current_val_entry)
            if test "$val_parts[1]" = "$var_name"
                set current_default $val_parts[2]
                break
            end
        end

        set -l found_repository ""
        set -l recommended_tag ""
        set -l fallback false

        # Try each repository
        for repo in $repositories
            set -l api_url "https://hub.docker.com/v2/repositories/$repo/$image_name/tags/?page_size=100"

            # Query Docker Hub
            set -l response (curl -s -H "Authorization: JWT $api_token" "$api_url")

            # Check if we got results
            if echo $response | jq -e '.results | length > 0' >/dev/null 2>&1
                set found_repository $repo

                # Extract all tags with timestamps
                set -l all_tags (echo $response | jq -r '.results[] | "\(.name)|\(.last_updated)"')

                # Find version-matched tags
                set -l matched_tags
                for tag_info in $all_tags
                    set -l tag_name (echo $tag_info | cut -d'|' -f1)

                    # Skip commit-hash suffixed tags and branch tags unless --all is specified
                    if test "$show_all" = "false"
                        # Skip tags with pattern: version-commithash (e.g., 237.5-4d73383f)
                        if string match -qr -- '-[0-9a-f]{8}$' $tag_name
                            continue
                        end
                        # Skip branch name tags (master, main, develop, etc.)
                        set -l lower_tag (string lower $tag_name)
                        if contains $lower_tag master main develop dev staging production prod
                            continue
                        end
                    end

                    # Extract version number from tag (227.5 -> 227, 1.0.7.202 -> 202, etc.)
                    set -l tag_version ""
                    # Try pattern 1: NNN.x -> NNN
                    if string match -qr '^([0-9]{3})\.' $tag_name
                        set tag_version (string replace -r '^([0-9]{3})\..*' '$1' $tag_name)
                    # Try pattern 2: x.x.x.NNN -> NNN
                    else if string match -qr '^[0-9]+\.[0-9]+\.[0-9]+\.([0-9]{3})' $tag_name
                        set tag_version (string replace -r '^[0-9]+\.[0-9]+\.[0-9]+\.([0-9]{3}).*' '$1' $tag_name)
                    end

                    if test "$tag_version" = "$release_version"
                        set -a matched_tags $tag_name
                    end
                end

                # Determine recommended tag
                if test (count $matched_tags) -gt 0
                    # Use latest version-matched tag
                    set recommended_tag (printf '%s\n' $matched_tags | sort -V | tail -1)
                    echo "✓ $repo/$image_name: Found "(count $matched_tags)" version-matched tag(s), using: $recommended_tag" >&2
                else
                    # Fallback to most recent tag (skip commit-hash tags and branch tags unless --all)
                    if test "$show_all" = "false"
                        # Find first tag that's not a commit hash or branch name
                        for tag_info in $all_tags
                            set -l candidate_tag (echo $tag_info | cut -d'|' -f1)
                            # Skip commit-hash tags
                            if string match -qr -- '-[0-9a-f]{8}$' $candidate_tag
                                continue
                            end
                            # Skip branch name tags
                            set -l lower_candidate (string lower $candidate_tag)
                            if contains $lower_candidate master main develop dev staging production prod
                                continue
                            end
                            # This tag passes all filters
                            set recommended_tag $candidate_tag
                            break
                        end
                        # If no suitable tag found, use the first one anyway
                        if test -z "$recommended_tag"
                            set recommended_tag (echo $all_tags | head -1 | cut -d'|' -f1)
                        end
                    else
                        set recommended_tag (echo $all_tags | head -1 | cut -d'|' -f1)
                    end
                    set fallback true
                    echo "⚠ $repo/$image_name: No version match, using most recent: $recommended_tag" >&2
                end

                break
            end
        end

        # Store result
        if test -n "$recommended_tag"
            set -a results "$var_name:$found_repository:$current_default:$recommended_tag:$fallback"
        else
            echo "❌ $image_name: Not found in any repository" >&2
            set -a results "$var_name:::$current_default::"
        end
    end

    # Output results
    echo "" >&2
    echo "================================================================================" >&2
    echo "Compatible External App Versions for BigID $release_version" >&2
    echo "================================================================================" >&2
    echo "" >&2
    echo "## Terraform Variables (terraform.tfvars)" >&2
    echo "" >&2

    for result in $results
        set -l parts (string split ':' $result)
        set -l var_name $parts[1]
        set -l repository $parts[2]
        set -l current $parts[3]
        set -l recommended $parts[4]
        set -l is_fallback $parts[5]

        if test -n "$recommended"
            set -l comment ""
            if test "$is_fallback" = "true"
                set comment "  # No version match - using most recent"
            else if test -n "$current" -a "$current" != "$recommended"
                set comment "  # Previous: $current"
            else if test -z "$current"
                set comment "  # New"
            end
            printf "%-45s = \"%-20s\"%s\n" $var_name $recommended $comment
        else
            set -l comment "  # Image not found in registry"
            if test -n "$current"
                set comment "$comment, keeping current: $current"
            end
            printf "# %-43s = ???%s\n" $var_name $comment
        end
    end

    echo "" >&2
    echo "## Summary" >&2
    echo "" >&2
    printf "%-45s %-12s %-15s %-20s %s\n" "Variable" "Repository" "Current" "Recommended" "Status" >&2
    echo "--------------------------------------------------------------------------------------------------------------" >&2

    for result in $results
        set -l parts (string split ':' $result)
        set -l var_name $parts[1]
        set -l repository $parts[2]
        set -l current $parts[3]
        set -l recommended $parts[4]
        set -l is_fallback $parts[5]

        test -z "$repository"; and set repository "N/A"
        test -z "$current"; and set current "None"
        test -z "$recommended"; and set recommended "Not found"

        set -l tag_status
        if test "$recommended" != "Not found"
            if test "$is_fallback" = "true"
                set tag_status "⚠️  FALLBACK"
            else if test "$current" = "None"
                set tag_status "NEW"
            else if test "$current" != "$recommended"
                set tag_status "UPDATE"
            else
                set tag_status "OK"
            end
        else
            set tag_status "❌ MISSING"
        end

        printf "%-45s %-12s %-15s %-20s %s\n" $var_name $repository $current $recommended $tag_status >&2
    end

    echo "" >&2
    echo "Status Legend:" >&2
    echo "  OK        - Current version matches recommended" >&2
    echo "  UPDATE    - New version-matched tag available" >&2
    echo "  NEW       - No current default, new tag found" >&2
    echo "  FALLBACK  - No version match, using most recent tag" >&2
    echo "  MISSING   - Image not found in registry" >&2
end
