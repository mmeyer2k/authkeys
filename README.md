# AuthKeys
An authorized_keys management TUI written entirely in bash.

## Features
- Prevent typos that could cause your server to become inaccessible.
- Add and remove keys safely without fear of typos that could cause the server to become inaccessible.
- Added keys are validated with `ssh-keygen`

## Install
```bash
curl https://raw.githubusercontent.com/mmeyer2k/authkeys/main/authkeys.sh > /usr/bin/authkeys
chmod +x /usr/bin/authkeys

```

## Usage
```bash
authkeys
```
