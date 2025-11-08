function gssh
  # Check if an instance name was provided
  if test -z "$argv[1]"
    echo "Error: You must provide an instance name."
    return 1
  end

  # The first argument is the instance name, the rest are other flags.
  gcloud compute ssh "csmith_bigid_com@$argv[1]" $argv[2..-1] \
    --plain \
    --ssh-flag="-o StrictHostKeyChecking=no" \
    --ssh-flag="-o UserKnownHostsFile=/dev/null"
end
