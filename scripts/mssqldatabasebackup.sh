#! /usr/bin/env bash
while getopts ":c:d:h" flag
do
    case "${flag}" in
        c) CONTAINER_NAME=${OPTARG};;
        d) DATABASE_NAME=${OPTARG};;
        h) echo "Add description of the script functions here."
           echo
           echo "Syntax: scriptTemplate [-c|d]"
           echo "Usage: $0 -c [container name] -d [database name]"
           echo "options:"
           echo "-c     Pass the container name by parameter."
           echo "-d     Pass the name of the database by parameter."
           echo
           exit 1;;
        \?) echo "Error: Invalid flag"
            exit 1;;
    esac
done

if [ -z $CONTAINER_NAME ] && [ -z $DATABASE_NAME ]
then
  read -p 'Container Name: ' CONTAINER_NAME
  read -p 'Database Name: ' DATABASE_NAME
fi

# Set bash to exit if any further command fails
set -e
set -o pipefail

# Create a file name for the backup based on the current date and time
# Example: 2019-01-27_13:42:00.master.bak
FILE_NAME=$(date +%Y-%m-%d_%H:%M:%S.$DATABASE_NAME.bak)

echo "Backing up database '$DATABASE_NAME' from container '$CONTAINER_NAME'..."

# Create a database backup with sqlcmd
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -b -V16 -S localhost -U SA -Q "BACKUP DATABASE [$DATABASE_NAME] TO DISK = N'/var/opt/mssql/backups/$FILE_NAME' with NOFORMAT, NOINIT, NAME = '$DATABASE_NAME-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

echo ""
echo "Exporting file from container..."

# Make sure the backups folder exists on the host file system
DIR=$(readlink -f "$0")
DIRTPATH=$(dirname "$DIR")

mkdir -p "$DIRTPATH/../backups"

# Copy the created file out of the container to the host filesystem
docker cp $CONTAINER_NAME:/var/opt/mssql/backups/$FILE_NAME $DIRTPATH/../backups/$FILE_NAME

echo "Backed up database '$DATABASE_NAME' to $DIRTPATH/../backups/$FILE_NAME"
echo "Done!"