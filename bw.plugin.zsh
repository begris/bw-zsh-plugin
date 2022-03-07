###

# gocred set --credential CLIP \
# $(bw-select $(bw list items --organizationid notnull) \
# | bw-asUsernamePassword); gocred get -u --credential CLIP

# bw-copy $(bw-select $(bw list items) | bw-asUsernamePassword)

## Aliases
alias bw-asList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)' | column -ts $'\t'"
alias bw-asCredentialList="jq --raw-output '[.[] | { name: .name, username: .login.username, id: .id, folder: .folder, org: .organizationId}]' | bw-asList"
alias bw-asPassword="jq --raw-output '.login.password | @sh'"
alias bw-asTsvList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)'"
alias bw-asCredentials="jq --raw-output '[.[] | { name: .name, username: .login.username, url: .login.uris[0].uri, id: .id}]'"
alias bw-asUsernamePassword="jq --raw-output '.login.username, .login.password | @sh'"

alias bw-copy="gocred set --credential CLIP $*"
alias bw-paste="gocred get -u --credential CLIP"
alias bw-paste-user="gocred get -us=false --credential CLIP"
alias bw-paste-password="gocred get --credential CLIP"
# not yet implemented
#alias bw-clip-reset="gocred delete --credential CLIP"

alias bw-orgId="bw list organizations | jq --raw-output '.[0].id'"

alias bwp="bw-search-personal $*"
alias bwo="bw-search-organization $*"
alias bws="bw-search $*"
alias bw-search-personal="__bw_search null $*"
alias bw-search-organization="__bw_search notnull $*"
alias bw-search="__bw_search '' $*"
#alias bwl="bw-login"

function bw-orgMember() { bwl; bw list --organizationid $(bw-orgId) org-members | bw-asList }
function bw-orgCollections() { bwl; bw list org-collections --organizationid $(bw-orgId) | bw-asList }

__bw_function_exists() {
  declare -f -F $1 > /dev/null
  return $?
}

# bw username hook - place in your .zshrc or initialize in any other way
# should return the email address used to login to your bitwarden instance.
# You a free to implement more complex solutions to gather your username.
# See README for examples.
# function bw-user { echo "email@domain.tld" }

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
                if [[ $(__bw_function_exists bw-user) == 0 ]]; then
                    __BW_USER=$(bw-user);
                fi
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

function __bw_search() {
  local org=$1
  shift;
  local searchterm=$*
  local logins login

  bwl

  # Search for passwords using the search term
  if [[ -n "$searchterm" ]]; then
    if [[ -n "$org" ]]; then
      logins=$(bw list items --organizationid $org --search $searchterm)
    else
      logins=$(bw list items --search $searchterm)
    fi    
  else
    if [[ -n "$org" ]]; then
      logins=$(bw list items --organizationid $org)
    else
      logins=$(bw list items)
    fi
  fi

  login=$(bw-select "$logins")

  if [[ -n $login ]]; then
    bw-copy $(bw-asUsernamePassword <<< $login)
  fi
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
