# notes

maildir:

/var/vmail
/etc/ssl

ldap admin pass for postmaster@example.com: this-password-changeme

// command: mysqld --log-bin=OFF

// # Postfix.

MYSQL_GRANT_HOST=mysqlserver

might need to change service_control()

dovecot needs to have access to postfix dir

can change SSL path to letsencrypt


----------


mysql:

    volumes:
      - ./persistent/mysql:/var/lib/mysql
      - ./persistent/logs:/var/log
      - ./persistent/run:/run

