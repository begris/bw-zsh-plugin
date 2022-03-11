####
##
##  Bitwarden Zsh plugin - (c) 2022 begris
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##
####

## Aliases
alias bw-asList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)' | column -ts $'\t'"
alias bw-asCredentialList="jq --raw-output '[.[] | { name: .name, username: .login.username, id: .id, folder: .folder, org: .organizationId}]' | bw-asList"
alias bw-asPassword="jq --raw-output '.login.password | @sh'"
alias bw-asTsvList="jq --raw-output '. | [.[]| with_entries( .key |= ascii_upcase ) ] | (.[0] |keys_unsorted | @tsv), (.[]|.|map(.) |@tsv)'"
alias bw-asCredentials="jq --raw-output '[.[] | { name: .name, username: .login.username, url: .login.uris[0].uri, id: .id}]'"
alias bw-asUsernamePassword="jq --raw-output '.login.username, .login.password | @sh'"
function bw-getField() {echo $(jq --raw-output ".$1 | @sh")}
function bw-getCustomField() {echo $(jq --raw-output ".fields[]? | select(.name == \"$1\") | select(.value != null) | .value | @sh")}


alias bw-copy="gocred set --credential BW_CLIP $*"
alias bw-paste="gocred get -u --credential BW_CLIP"
alias bw-paste-user="gocred get -us=false --credential BW_CLIP"
alias bw-paste-password="gocred get --credential BW_CLIP"
# not yet implemented
#alias bw-clip-reset="gocred delete --credential BW_CLIP"

alias bw-orgId="bw list organizations | jq --raw-output '.[0].id'"

alias bwp="bw-search-personal $*"
alias bwo="bw-search-organization $*"
alias bws="bw-search $*"
alias bw-search-personal="__bw_search null $*"
alias bw-search-organization="__bw_search notnull $*"
alias bw-search="__bw_search '' $*"
alias bwl="bw-login $*"

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
        echo "Already unlocked."  >&2 ;
    elif [[ "$bwstatus" == "locked" || "$bwstatus" == "unauthenticated" ]]; then
        local _gocred=$(command -v gocred)
        if [[ ! -z "$_gocred" ]]; then
            export BW_SESSION=$($_gocred get --credential BW_SESSION)
        fi

        if [[ "$(bw status | jq -r .status)"  == "locked" ]]; then
            echo "Unlocking..."  >&2 ;
            export BW_SESSION=$(bw unlock --raw)
        elif [[ "$(bw status | jq -r .status)" == "unauthenticated" ]]; then
            if [[ -z "$1" ]]; then
                __bw_function_exists bw-user
                if [[ $? == 0 ]]; then
                    __BW_USER=$(bw-user);
                fi
            else
                __BW_USER=$1;
            fi
            echo "Login..."  >&2 ;
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
  local searchterm
  local json
  local logins login

  ARGS=$(getopt -o j -l "json" -n "$0" -- "$@")
  if [ $? != 0 ] ; then
    echo "Terminating..." >&2 ;
    exit 1 ;
  fi
  # Note the quotes around `$ARGS': they are essential!
  eval set -- "$ARGS"

  # echo "$ARGS"
  while true ; do
    case "$1" in
        -j|--json)
            json="true";
            shift;;
        --)
            shift ;
            break ;;    # processed all options, parameters following
        *)
            echo "Internal error!" ;
            exit 1 ;;
    esac
  done
  eval set -- "$@"
  searchterm="$@";

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
    if [[ -n $json ]]; then
      echo $login
    fi
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
