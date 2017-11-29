#/bin/bash

# High Sierra root enabled with empty password bug.
# With the following commands, it disable the root completely.

for keys in authentication_authority KerberosKeys ShadowHashData; do
   sudo defaults delete /var/db/dslocal/nodes/Default/users/root.plist $keys &>/dev/null
done
sudo defaults write /var/db/dslocal/nodes/Default/users/root.plist shell "/usr/bin/false"
