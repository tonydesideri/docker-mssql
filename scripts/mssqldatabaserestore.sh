#! /usr/bin/env bash
while getopts ":c:d:f:h" flag
do
    case "${flag}" in
        c) CONTAINER_NAME=${OPTARG};;
        d) DATABASE_NAME=${OPTARG};;
        f) BACKUP_NAME=${OPTARG};;
        h) echo "Add description of the script functions here."
           echo
           echo "Syntax: scriptTemplate [-c|d]"
           echo "Usage: $0 -c [container name] -d [database name] -b [backup file name]"
           echo "options:"
           echo "-c     Pass the container name by parameter."
           echo "-d     Pass the name of the database by parameter."
           echo "-f     Pass the name of the backup file by parameter."
           echo
           exit 1;;
        \?) echo "Error: Invalid flag"
            exit 1;;
    esac
done

if [ -z $CONTAINER_NAME] && [ -z $DATABASE_NAME] && [ -z $BACKUP_NAME ]
then
  read -p 'Container Name: ' CONTAINER_NAME
  read -p 'Database Name: ' DATABASE_NAME
  read -p 'Backup Name: ' BACKUP_NAME
fi

# Check if the backup file can be found
DIR=$(readlink -f "$0")
DIRTPATH=$(dirname "$DIR")

if [ ! -f $DIRTPATH/../backups/$BACKUP_NAME ]
then
  echo "Backup file $BACKUP_NAME does not exist."
  exit 1
fi

# Set bash to exit if any command fails
set -e
set -o pipefail

FILE_NAME=$(basename $BACKUP_NAME)

echo "Copying backup file $BACKUP_NAME to container '$CONTAINER_NAME'. Note: the container should already be running!"

# Copy the file over to a special restore folder in the container, where the sqlcmd binary can access it
docker exec $CONTAINER_NAME mkdir -p /var/opt/mssql/restores
docker cp $DIRTPATH/../backups/$BACKUP_NAME "$CONTAINER_NAME:/var/opt/mssql/restores/$FILE_NAME"

echo "Restoring database '$DATABASE_NAME' in container '$CONTAINER_NAME'..."

# Restore the database with sqlcmd
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -Q "RESTORE DATABASE [$DATABASE_NAME] FROM DISK = N'/var/opt/mssql/restores/$FILE_NAME' WITH FILE = 1, NOUNLOAD, REPLACE, RECOVERY, STATS = 5"

echo ""
echo "Restored database '$DATABASE_NAME' in container '$CONTAINER_NAME' from file $BACKUP_NAME"
echo "Done!"