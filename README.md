# bw
_**Bitwarden Zsh plugin**_ - provides formatting options and easy acces to credentails stored in Bitwarden via the **Bitwarden CLI**.

## Requirements
The following addtional tools are required to use the _Bitwarden Zsh plugin_:

jq - 

fzf - https://github.com/junegunn/fzf/releases/latest/download 

gocred - https://github.com/begris/gocred/releases/latest/download 

## Commands

| command | description | parameters
| --- | --- | --- |
| bw-search | search credential and copy to secure store (`BW_CLIP`), if gocred is available. Displays the list of credentails found for further selection or copies if only one exact match was found. | argument as searchterm (bw list --search `searchterm`) |
| bw-search-organization | see `bw-search`, but only searches for organizational credentials | argument as searchterm (`bw list --organizationid notnull --search <searchterm>`) |
| bw-search-personal | see `bw-search`, but only searches for personal credentials | argument as searchterm (`bw list --organizationid null --search <searchterm>`) |
| bws | alias for `bw-search` |  |
| bwo | alias for `bw-search-organization` |  |
| bwp | alias for `bw-search-personal` |  |
| bw-login | performs a Bitwarden login. Checks the bitwarden status beforehand and performs an unlock or login accordingly, but only if necessary. Bitwarden username can be provided as argument. If not given tries to retrieve username from bw-user hook, which may be implemented in any kind. The session is exported as BW_SESSION environment variable, so available to other _CLI_ calls. If gocred is available the session key is also stored in the credential store and can be used by serval sessions (multiple terminal windows) on one system. | optional login name |
| bwl | alias for `bw-login` |  |
| bw-user | hook for Bitwarden username. Simplest possible implementation `function bw-user { echo "email@domain.tld" }` added to `.zshrc`. But anything should be possible, see examples for inspiration. |  |
| bw-copy | copies [opt. username] and password to `BW_CLIP` using gocred |  |
| bw-paste | paste username and password from `BW_CLIP` |  |
| bw-paste-user | paste username from `BW_CLIP` |  |
| bw-paste-password | paste password from `BW_CLIP` |  |
| bw-clip-reset | will delete `BW_CLIP`, but not yet implemented in gocred, thus not available in bw zsh plugin either. |  |
| bw-orgId | returns the id of the first orgaization |  |
| bw-orgMember | returns a list of the members of `bw-orgId` |  |
| bw-orgCollections | returns a list of the collections of `bw-orgId` |  |

## Formatting options

| command | description | example |
| --- | --- | --- |
| bw-asList | format json result as table, json keys are used as table header |  |
| bw-asCredentialList | extracts only the fields `.name, .login.username, .id, .folder, .organizationId` and display as table (see `bw-asList`) from all entries. |  |
| bw-asPassword | extracts the password of a json entry and outputs as argument for usage in shell |  |
| bw-asTsvList | like `bw-asList` but outputs a `tab` separated list for futher formatting  |  |
| bw-asCredentials | like `bw-asCredentialList` but with the fields `.name, .login.username, .login.uris[0].uri, .id` |  |
| bw-asUsernamePassword | like `bw-asPassword` but returns two arguments `username` `password` |  |

## examples

