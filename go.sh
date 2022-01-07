#!/bin/bash

cat >"toto.txt"<<EOF
#!/bin/bash

nc_distribution="debian 11"
nc_hostname="\$nc_hostname"
EOF
