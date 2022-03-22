#!/bin/bash

DATE=`date +"%Y-%m-%d_%Hh%Mm%Ss"`
YEAR=`date +"%Y"`
MONTH=`date +"%m"`
DAY=`date +"%d"`

###
### Default values
###

DB_BACKUP_BASE_PATH="/var/local/mongo_backups"
MONGO_HOST='localhost'
MONGO_PORT='27017'
DATABASE_NAMES='ALL'

MONGO_USER=''
MONGO_PASSWD=''


##################################################################

function show_usage() {
  echo "mongo_backup.sh -h=<host> --path=<base path without last backslash> --db=<comma separated list of dbs"
  echo -e "\t-h|--host default=${MONGO_HOST}"
  echo -e "\t-p|--port default=${MONGO_PORT}"
  echo -e "\t--path default=${DB_BACKUP_BASE_PATH}"
  echo -e "\t--db default=${DATABASE_NAMES}"
  echo -e "\t-u|--user default=${MONGO_USER}"
  echo -e "\t--password default=${MONGO_PASSWD}"
  echo -e "\t--help show this help info"
}

for i in "$@"; do
  case $i in
    -u=*|--user=*)
      MONGO_user="${i#*=}"
      shift # past argument=value
      ;;
    --password=*)
      MONGO_PASSWD="${i#*=}"
      shift # past argument=value
      ;;
    -h=*|--host=*)
      MONGO_HOST="${i#*=}"
      shift # past argument=value
      ;;
    -p=*|--port=*)
      MONGO_PORT="${i#*=}"
      shift # past argument=value
      ;;
    --path=*)
      DB_BACKUP_BASE_PATH="${i#*=}"
      shift # past argument=value
      ;;
    --db=*)
      DATABASE_NAMES="${i#*=}"
      shift # past argument with no value
      ;;
    --help)
      show_usage
      exit 1
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done


DB_BACKUP_PATH="${DB_BACKUP_BASE_PATH}/${YEAR}/${MONTH}/${DAY}"


######################################################################

if [ ! -d ${DB_BACKUP_PATH} ]; then
 mkdir -p ${DB_BACKUP_PATH}
fi

AUTH_PARAM=" --username ${MONGO_USER} --password ${MONGO_PASSWD} "

if [ ${DATABASE_NAMES} = "ALL" ]; then
 echo "Backing up all mongodb in one file"
 mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} ${AUTH_PARAM} --gzip --archive=${DB_BACKUP_PATH}/${MONGO_HOST}_all_${DATE}.mongodump.bson.gz
else
 echo "Running backup in diferent files"
 echo "Backing up admin.system"
 mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} ${AUTH_PARAM} --db admin --gzip --archive=${DB_BACKUP_PATH}/${MONGO_HOST}_admin_${DATE}.mongodump.bson.gz --dumpDbUsersAndRoles
 for DB_NAME in ${DATABASE_NAMES}
 do
  echo "Backing up ${DB_NAME}"
  mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} --authenticationDatabase=admin --db ${DB_NAME} ${AUTH_PARAM} --gzip --archive=${DB_BACKUP_PATH}/${MONGO_HOST}_${DB_NAME}_${DATE}.mongodump.bson.gz --dumpDbUsersAndRoles
 done
fi
