#!/bin/bash 
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e
export AWS_DEFAULT_REGION=eu-central-1
echo "AWS_DEFAULT_REGION=eu-central-1" >> /etc/environment

AUTH_PROVIDER_HOST="${auth_provider_host}"
EJABBERD_DB_NAME="${ejabberd_db_name}"
EJABBERD_DB_HOST="$(aws secretsmanager get-secret-value --secret-id ${rds_credentials_secret_name} | jq --raw-output '.SecretString' | jq -r .host)"
EJABBERD_DB_USERNAME="$(aws secretsmanager get-secret-value --secret-id ${rds_credentials_secret_name} | jq --raw-output '.SecretString' | jq -r .username)"
EJABBERD_DB_PASSWORD="$(aws secretsmanager get-secret-value --secret-id ${rds_credentials_secret_name} | jq --raw-output '.SecretString' | jq -r .password)"
EJABBERD_DB_PORT="$(aws secretsmanager get-secret-value --secret-id ${rds_credentials_secret_name} | jq --raw-output '.SecretString' | jq -r .port)"

mv /etc/ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml.bak
mv /etc/ejabberd/ejabberd.tpl.yml /etc/ejabberd/ejabberd.yml

sed -i "s/###EJABBERD_DB_HOST###/$EJABBERD_DB_HOST/g" /etc/ejabberd/ejabberd.yml
sed -i "s/###EJABBERD_DB_NAME###/$EJABBERD_DB_NAME/g" /etc/ejabberd/ejabberd.yml
sed -i "s/###EJABBERD_DB_USERNAME###/$EJABBERD_DB_USERNAME/g" /etc/ejabberd/ejabberd.yml
sed -i "s/###EJABBERD_DB_PASSWORD###/$EJABBERD_DB_PASSWORD/g" /etc/ejabberd/ejabberd.yml
sed -i "s/###EJABBERD_DB_PORT###/$EJABBERD_DB_PORT/g" /etc/ejabberd/ejabberd.yml
sed -i "s|###AUTH_PROVIDER_HOST###|$AUTH_PROVIDER_HOST|g" /etc/ejabberd/ejabberd.yml
sed -i "s/auth_method: sql/auth_method: http/g" /etc/ejabberd/ejabberd.yml
sed -i "s/##UNCOMENT##//g" /etc/ejabberd/ejabberd.yml

wait-for-it -h $EJABBERD_DB_HOST -p $EJABBERD_DB_PORT --timeout=120

DBEXISTS=$(mysql --host=$EJABBERD_DB_HOST --port=$EJABBERD_DB_PORT --user=$EJABBERD_DB_USERNAME --password=$EJABBERD_DB_PASSWORD -e "SHOW DATABASES LIKE '"$EJABBERD_DB_NAME"';" | grep "$EJABBERD_DB_NAME" > /dev/null; echo "$?")
if [ $DBEXISTS -ne 0 ]; then
    echo "Database $EJABBERD_DB_NAME does not exist. creating."
    mysql --host=$EJABBERD_DB_HOST --port=$EJABBERD_DB_PORT --user=$EJABBERD_DB_USERNAME --password=$EJABBERD_DB_PASSWORD -e "create database $EJABBERD_DB_NAME";
fi

TABLE=users
SQL_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "$TABLE")
if [[ $(mysql --host=$EJABBERD_DB_HOST --port=$EJABBERD_DB_PORT --user=$EJABBERD_DB_USERNAME --password=$EJABBERD_DB_PASSWORD -e "$SQL_EXISTS" $EJABBERD_DB_NAME) ]]
then
    echo "Table $TABLE exists skipping sql import..."
else
    echo "Table $TABLE exists skipping sql import..."
    mysql --host=$EJABBERD_DB_HOST --port=$EJABBERD_DB_PORT --user=$EJABBERD_DB_USERNAME --password=$EJABBERD_DB_PASSWORD $EJABBERD_DB_NAME < /usr/share/ejabberd/sql/mysql.new.sql; 
fi

service ejabberd stop
service ejabberd start
wait-for-it -h app.rs -p 5280 --timeout=120
wait-for-it -h app.rs -p 5443 --timeout=120
wait-for-it -h app.rs -p 5222 --timeout=120

ejabberdctl request-certificate all
ejabberdctl register admin app.rs ${ejabberd_admin_password}
