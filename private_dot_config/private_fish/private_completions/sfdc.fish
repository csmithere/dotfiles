# Disable file completions by default
complete -c sfdc -f

# Subcommands (only when no subcommand given yet)
complete -c sfdc -n __fish_use_subcommand -a pov -d "Proof of Value opportunities"
complete -c sfdc -n __fish_use_subcommand -a pov-stale -d "POVs with no SE update in 7 days"
complete -c sfdc -n __fish_use_subcommand -a demo -d "Consensus / Demo opportunities"
complete -c sfdc -n __fish_use_subcommand -a demo-stale -d "Demos with no SE update in 7 days"
complete -c sfdc -n __fish_use_subcommand -a qual -d "Qualification opportunities"
complete -c sfdc -n __fish_use_subcommand -a qual-stale -d "Qualifications with no SE update in 7 days"
complete -c sfdc -n __fish_use_subcommand -a disco -d "Discovery opportunities"
complete -c sfdc -n __fish_use_subcommand -a disco-stale -d "Discoveries with no SE update in 7 days"
complete -c sfdc -n __fish_use_subcommand -a search -d "Search opportunities by name"
complete -c sfdc -n __fish_use_subcommand -a geo -d "List available geographies"

# --stage, --se, and --geo flags (available globally)
complete -c sfdc -l stage -x -d "Filter by stage (0=Qual,1=Disco,2=Demo,3=POV)"
complete -c sfdc -l se -x -d "Filter by SE Lead name"
complete -c sfdc -l geo -x -d "Filter by geography (default: North America, 'all' for all)"
