#!/bin/bash

export DB_USERNAME=myuser
#echo $DB_USERNAME
export DB_PASSWORD=mypassword
#echo $DB_PASSWORD
export DB_HOST=127.0.0.1
#echo $DB_HOST
export DB_PORT=5433
#echo $DB_PORT
export DB_NAME=mydatabase
#echo $DB_NAME

python3.8 app.py