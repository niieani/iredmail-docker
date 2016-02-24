#!/bin/bash

shopt -s expand_aliases

mkdir -p /var/spool/cron/crontabs
touch /var/spool/cron/crontabs/root

## we imitate the 'mysql' and 'service' commands to capture their output
## and execute it on first run of the container 

touch /commands
echo '#!/bin/bash' > /commands

__sourcing=true source /capture.sh
alias service='capture service'
alias mysql='capture mysql'

chmod +x /capture.sh
mkdir -p /tmp/bin
cp /capture.sh /tmp/bin/mysql

export PATH="/tmp/bin:$PATH"

source /iRedMail/iRedMail.sh

echo "Here are the prepared commands:"
cat /commands

rm -f /tmp/bin/mysql

# echo "sql defaults"
# cat /iRedMail/runtime/mysql_init.sql
# cat /iRedMail/.mysql-root-defaults-file