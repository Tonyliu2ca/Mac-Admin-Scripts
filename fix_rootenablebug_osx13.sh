#/bin/bash

# High Sierra root enabled with empty password bug.
# With the following commands, it disable the root completely.

for keys in authentication_authority KerberosKeys ShadowHashData; do
   sudo defaults delete /var/db/dslocal/nodes/Default/users/root.plist $keys &>/dev/null
done

# Comments for the last command below.
# Even root is re-enabled in Directory Utility or other GUI way, the "shell" stay the false, to set it back to system default:
# sudo defaults write /var/db/dslocal/nodes/Default/users/root.plist shell "/bin/sh"
# or
# sudo dscl . append /users/root UserShell "/bin/sh"
#
sudo defaults write /var/db/dslocal/nodes/Default/users/root.plist shell "/usr/bin/false"
