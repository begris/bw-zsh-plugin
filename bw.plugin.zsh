
# Functions
function bw-search() { bw list items --search "$1" | bw-asPassword }

# Aliases
alias bw-asList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)' | column -ts $'\t'"
alias bw-asCredentialList="jq --raw-output '[.[] | { name: .name, username: .login.username, id: .id, folder: .folder, org: .organizationId}] | bw-asList"
alias bw-asPassword="jq --raw-output '.[0].login.username"
alias bw-list-personal="bw list items --organizationid null | bw-asCredentialList"
alias bw-orgId="bw list organizations | jq --raw-output '.[0].id'"
alias bw-orgMember="ORG=$(bw list organizations | jq --raw-output '.[0].id'); bw list --organizationid $ORG org-members | bw-asList"
alias bw-orgCollections="bw list org-collections --organizationid $(bw-orgId) | bw-asList"

