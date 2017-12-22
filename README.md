# Simple OpenVPN PKI

## Usage

```bash
cd $project_root
# First init pki for ca, servers & clients, and build ca
bash init.sh env
# Generate a server key
bash gen-server-key.sh env server manager_email
# Generate a user key
bash gen-client-key.sh env user user_email
```
