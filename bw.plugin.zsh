###

# gocred set --credential CLIP \
# $(bw-select $(bw list items --organizationid notnull) \
# | bw-asUsernamePassword); gocred get -u --credential CLIP

# bw-copy $(bw-select $(bw list items) | bw-asUsernamePassword)

## Aliases
alias bw-asList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)' | column -ts $'\t'"
alias bw-asCredentialList="jq --raw-output '[.[] | { name: .name, username: .login.username, id: .id, folder: .folder, org: .organizationId}]' | bw-asList"
alias bw-asPassword="jq --raw-output '.login.password | @sh'"
alias bw-asUsernamePassword="jq --raw-output '.login.username, .login.password | @sh'"
# still needed?
alias bw-list-personal="bw list items --organizationid null | bw-asCredentialList"
alias bw-orgId="bw list organizations | jq --raw-output '.[0].id'"

alias bw-copy="gocred set --credential CLIP $*"
alias bw-paste="gocred get -u --credential CLIP"
alias bw-paste-user="gocred get -us=false --credential CLIP"
alias bw-paste-password="gocred get --credential CLIP"

# still needed?
alias bw-filter-private="echo '>-organizationid:*'"
alias bw-filter-organization=">organizationid:*"

alias bw-asTsvList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)'"
alias bw-asCredentials="jq --raw-output '[.[] | { name: .name, username: .login.username, url: .login.uris[0].uri, id: .id}]'"

alias bwp="bw-search-personal $*"
alias bwo="bw-search-organization $*"
alias bws="bw-search $*"
# alias bwl="bw-login"

# search functions
#function bw-search() { bw list items --search "$1" | bw-asPassword }

function bw-orgMember() { bwl; bw list --organizationid $(bw-orgId) org-members | bw-asList }
function bw-orgCollections() { bwl; bw list org-collections --organizationid $(bw-orgId) | bw-asList }

# perform a bitwarden login or unlock
function bw-login() {
    local __BW_USER
    local bwstatus=$(bw status | jq -r .status)
    if [[ "$bwstatus" == "unlocked" ]]; then
        echo "Already unlocked.";
    elif [[ "$bwstatus" == "locked" || "$bwstatus" == "unauthenticated" ]]; then
        local _gocred=$(command -v gocred)
        if [[ ! -z "$_gocred" ]]; then
            export BW_SESSION=$($_gocred get --credential BW_SESSION)
        fi

        if [[ "$(bw status | jq -r .status)"  == "locked" ]]; then
            echo "Unlocking..."
            export BW_SESSION=$(bw unlock --raw)
        elif [[ "$(bw status | jq -r .status)" == "unauthenticated" ]]; then
            if [[ -z "$1" ]]; then
                __BW_USER=$(bw-user);
            else
                __BW_USER=$1;
            fi
            echo "Login..."
            export BW_SESSION=$(bw login $__BW_USER --raw)
        fi

        if [[ -n "$BW_SESSION" && ! -z "$_gocred" ]]; then
            $_gocred set --credential BW_SESSION $BW_SESSION
        fi
    fi
}

function bw-search-personal() { 
  local searchterm=$1
  local logins login

  bwl

  # Search for passwords using the search term
  if [[ -n "$searchterm" ]]; then
    logins=$(bw list items --organizationid null --search $searchterm)
  else
    logins=$(bw list items --organizationid null)
  fi

  login=$(bw-select "$logins")

  if [[ -n $login ]]; then
    bw-copy $(bw-asUsernamePassword <<< $login)
  fi
}

function bw-search-organization { 
  local searchterm=$1
  local logins login

  bwl

  # Search for passwords using the search term
  if [[ -n "$searchterm" ]]; then
    logins=$(bw list items --organizationid notnull --search $searchterm)
  else
    logins=$(bw list items --organizationid notnull)
  fi

  login=$(bw-select "$logins")

  if [[ -n $login ]]; then
    bw-copy $(bw-asUsernamePassword <<< $login)
  fi
}


# functions

function bw-install-fzf() {
  local installdir=$1
  if [[ -z "$installdir" ]]; then
    installdir=/usr/local/bin
  fi
  local _os=$(uname -o)
  local _machine=$(uname -m)
  if [[ "$_os" =~ "Cygwin" ]]; then
    _os="windows"
    _machine="amd64"
  fi
  local _latest=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/junegunn/fzf/releases/latest | grep -oE "[^/]+$")
  curl -L "https://github.com/junegunn/fzf/releases/latest/download/fzf-$_latest-${_os}_$_machine.zip" -o /tmp/fzf.zip && \
  unzip -ud /usr/local/bin /tmp/fzf.zip fzf.exe && rm /tmp/fzf.zip
}

function bw-select() {
  local logins=$@
  local login id

  id=$(bw-asCredentials <<< $logins \
    | bw-asTsvList \
    | column -ts $'\t' \
    | fzf --reverse --nth=1,2,3 --header-lines=1 --delimiter=" " --select-1 --exit-0 \
    | grep -Eo '[^ ]+$'
  )

  if [[ -n $id ]]; then
    login="$(jq ".[] | select(.id == \"$id\")" <<< $logins)"
    echo $login
    exit 0
  fi
  exit 1
}

function bw-search() {
  local searchterm=$1
  local logins login id

  bwl

  # Search for passwords using the search term
  if [[ -n "$searchterm" ]]; then
    logins=$(bw list items --search $searchterm)
  else
    logins=$(bw list items)
  fi

  login=$(bw-select "$logins")
  
  if [[ -n $login ]]; then
    bw-copy $(bw-asUsernamePassword <<< $login)
  fi
}
