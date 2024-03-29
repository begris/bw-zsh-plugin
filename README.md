# bw
_**Bitwarden Zsh plugin**_ - provides formatting options and easy acces to credentails stored in Bitwarden via the **Bitwarden CLI**.
The plugin tries to retrieve a valid session before each action, therefore an explicit login is not nescessary beforehand.

## Requirements
The following addtional tools are required to use the _Bitwarden Zsh plugin_:

Bitwarden cli - https://bitwarden.com/download/

jq - https://github.com/stedolan/jq/releases/latest/download - tested version 1.6

fzf - https://github.com/junegunn/fzf/releases/latest/download - tested version 0.29.0

gocred - https://github.com/begris/gocred/releases/latest/download  - tested version 1.0.0

The Bitwarden Zsh plugin provides install functions for each tool, but you should consider using the package manager 
of your operating system if possible.
On _Cygwin_ installations there might be an issue with the provided fzf version. If it is to old you can use
the `bw-install-fzf` function, which will download and install the latest version from the Github repository.

As gocred is currently not provided by any package manager, you can install it using `bw-install-gocred`.

## Commands

| command                | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | parameters                                                          |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| bw-search              | search credential and copy to secure store (`BW_CLIP`), if gocred is available. Displays the list of credentails found for further selection or copies if only one exact match was found.                                                                                                                                                                                                                                                                                                                                                           | argument as searchterm (bw list --search `searchterm`)<br/>opt. -j \| --json for json output of selected entry       |
| bw-search-organization | see `bw-search`, but only searches for organizational credentials                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | argument as searchterm (`bw list --organizationid notnull --search <searchterm>`) |
| bw-search-personal     | see `bw-search`, but only searches for personal credentials                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | argument as searchterm (`bw list --organizationid null --search <searchterm>`) |
| bws                    | alias for `bw-search`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                     |
| bwo                    | alias for `bw-search-organization`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |                                                                     |
| bwp                    | alias for `bw-search-personal`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |                                                                     |
| bw-login               | performs a Bitwarden login. Checks the bitwarden status beforehand and performs an unlock or login accordingly, but only if necessary. Bitwarden username can be provided as argument. If not given tries to retrieve username from bw-user hook, which may be implemented in any way. The session is exported as BW_SESSION environment variable, so it is available to other _CLI_ calls. If gocred is available the session key is also stored in the credential store and can be used by serveral sessions (multiple terminal windows) on one system. | optional login name                                                 |
| bwl                    | alias for `bw-login`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |                                                                     |
| bw-user                | hook for Bitwarden username. Simplest possible implementation `function bw-user { echo "email@domain.tld" }` added to `.zshrc`. But anything should be possible, see examples for inspiration.                                                                                                                                                                                                                                                                                                                                                      |                                                                     |
| bw-copy                | copies [opt. username] and password to `BW_CLIP` using gocred                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |                                                                     |
| bw-paste               | paste username and password from `BW_CLIP`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                     |
| bw-paste-user          | paste username from `BW_CLIP`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |                                                                     |
| bw-paste-password      | paste password from `BW_CLIP`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |                                                                     |
| bw-clip-reset          | _*not yet implemented*_ will delete `BW_CLIP`                                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                     |
| bw-clipboard-user      | _*not yet implemented*_ copies the username to the standard clipbord and removes it after the specified timeout `BW_CLIPBOARD_TIMEOUT`. Default timeout is 15 seconds.                                                                                                                                                                                                                                                                                                                                                                              |                                                                     |
| bw-clipboard-pw        | _*not yet implemented*_ copies the password to the standard clipbord and removes it after the specified timeout `BW_CLIPBOARD_TIMEOUT`. Default timeout is 15 seconds.                                                                                                                                                                                                                                                                                                                                                                              |                                                                     |
| bw-clipboard-clear     | _*not yet implemented*_ clears the clipboard                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |                                                                     |
| bw-clipboard-timeout   | _*not yet implemented*_ copies the input stream to the clipboard and clears the clipboard after the specified timeout `BW_CLIPBOARD_TIMEOUT`. Default timeout is 15 seconds.                                                                                                                                                                                                                                                                                                                                                                                                                              |                                                                     |
| bw-orgId               | returns the id of the first orgaization                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |                                                                     |
| bw-orgMember           | returns a list of the members of `bw-orgId`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |                                                                     |
| bw-orgCollections      | returns a list of the collections of `bw-orgId`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |                                                                     |
| bw-getField            | returns a standard field from the selected entry (jsonpath without leading `.`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | argument for jsonpath                                               |
| bw-getCustomField      | returns a custom field value from the selected entry                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | field name as argument                                              |
| bw-install-cli         | installs Bitwarden CLI                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | optional installdir                                                 |
| bw-install-fzf         | installs fzf                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | optional installdir                                                 |
| bw-install-gocred      | installs gocred                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | optional installdir                                                 |
| bw-install-jq          | installs jq                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | optional installdir                                                 |



## Formatting options
> :warning: These formatting options are build to be used with the "plain" Bitwarden cli - these do _not_ work in conjunction with the aliases provided by the _Bitwarden Zsh plugin_. 

| command               | description                                                                                                                               | example         |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| bw-asList             | format json result as table, json keys are used as table header                                                                           |                 |
| bw-asCredentialList   | extracts only the fields `.name, .login.username, .id, .folder, .organizationId` and display as table (see `bw-asList`) from all entries. |                 |
| bw-asPassword         | extracts the password of a json entry and outputs as argument for usage in shell                                                          |                 |
| bw-asTsvList          | like `bw-asList` but outputs a `tab` separated list for futher formatting                                                                 |                 |
| bw-asCredentials      | like `bw-asCredentialList` but with the fields `.name, .login.username, .login.uris[0].uri, .id`                                          |                 |
| bw-asUsernamePassword | like `bw-asPassword` but returns two arguments `username` `password`                                                                      |                 |
| bw-unescape           | removes the quotes of an entry                                                                                                            | `bw-paste-user \| bw-unescape` |
| bw-clean-string-value           | replaces json strings with empty strings. In some cases strings are not correctly encoded by the Bitwarden CLI and prevent parsing by jq or other tools.                                                                                                            | `bws hostname \| bw-clean-string-value uri password` |

## examples

### formatting examples
#### `bw-asCredentialList`
```shell
❯ bw list items --search test --organizationid null | bw-asCredentialList
NAME   USERNAME       ID                                    FOLDER  ORG
test   user           a0789a74-b8f1-445c-9ea7-ae5b00d7cce0
test2  user2          901b6362-25d5-45d7-9acf-ae5b00d85e83
test3  user@site.com  31f117da-ac04-4c99-812e-ae5b00d87393
```

#### `bw-asCredentials` && `bw-asList`
```shell
❯ bw list items --search test --organizationid null | bw-asCredentials | bw-asList
NAME   USERNAME       URL  ID
test   user                a0789a74-b8f1-445c-9ea7-ae5b00d7cce0
test2  user2               901b6362-25d5-45d7-9acf-ae5b00d85e83
test3  user@site.com       31f117da-ac04-4c99-812e-ae5b00d87393
test4  user                229bc07d-835e-4e42-a59b-ae5b00df50f2
```

#### `bw-asCredentials` && `bw-asTsvList`
```shell
❯ bw list items --search test --organizationid null | bw-asCredentials | bw-asTsvList
NAME    USERNAME        URL     ID
test    user            a0789a74-b8f1-445c-9ea7-ae5b00d7cce0
test2   user2           901b6362-25d5-45d7-9acf-ae5b00d85e83
test3   user@site.com           31f117da-ac04-4c99-812e-ae5b00d87393
test4   user            229bc07d-835e-4e42-a59b-ae5b00df50f2
```

#### `bw-asPassword` && `bw-unescape`
```shell
❯ bw get item 'test4' | bw-asPassword
'secret'
❯ bw get item 'test4' | bw-asPassword | bw-unescape
secret
```

### selection of a custom field
1. Search for items matching `host1` - open entry selection if more than result
2. get the value of the custom field `Hostname` - returns nothing if field does not exist
3. pastes to user name of the selected item
```shell
echo "Do magic on host $(bws --json host1 | bw-getCustomField Hostname) with user $(bw-paste-user)"
```

### check if an item was actually selected
1. Search for items matching `host1` - open entry selection if more than result
2. check if an item was selected (return code `0`) or if the selection was aborted (return code `1`)
3. get the value of the custom field `Hostname` - returns nothing if field does not exist
4. perform action with Hostname field, e.g. connecting via ssh
```shell
json=$(bws --json host1); if [[ $? == 0 ]]; then h=`echo $json | bw-getCustomField Hostname`; echo echo "connect to $h"; else echo "ohh no - more lemmings"; fi
```

### bw-user hook
The hook should be implemented in your `.zshrc` or any other resource file loaded before using the plugin commands itself.

#### use shell variable
```shell
export USER_EMAIL="email@domain.tld"

function bw-user() {
	echo $USER_EMAIL
}
```

#### use email address from git configuration
```shell
function bw-user() {
	git config --global user.email
}
```

#### get user from AD session
```shell
# get user principal from current windows session
upn() {
    if [[ -z "$UPN" ]]; then
        cUPN=$(powershell 'Get-ADUser -Identity $env:USERNAME -Properties *| select-object -first 1 | foreach { $_.UserPrincipalName } | Write-Host -NoNewline');
        export UPN=$cUPN;
    fi
    echo $UPN
}

function bw-user() {
    upn
}
```
