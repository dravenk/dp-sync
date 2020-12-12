#!/bin/sh

### Set the permissions of the sh script and run
# chmod a+x sync-db.sh
# ./sync-db.sh
###

# Setup SSH credentials
SSH_USER=root
SSH_SERVER=1.1.1.1

# Setup Container name
REMOTE_CONTAINER=remote-container
LOCAL_CONTAINER=local-container

# Main content
NOW=$(date +"%Y%m%d-%H%M")
REMOTE_FILE="remote-$REMOTE_CONTAINER-$NOW.gz"
LOCAL_FILE="local-$LOCAL_CONTAINER-$NOW.gz"

echo "Dumping $REMOTE_CONTAINER database to $REMOTE_FILE"
eval "ssh $SSH_USER@$SSH_SERVER 'docker exec $REMOTE_CONTAINER drush sql-dump --gzip' > $REMOTE_FILE"

echo "Dumping $LOCAL_CONTAINER database to $LOCAL_FILE"
eval "docker exec $LOCAL_CONTAINER drush sql-dump --gzip > $LOCAL_FILE"

echo "Copy $LOCAL_FILE into $LOCAL_CONTAINER"
eval "docker cp $REMOTE_FILE $LOCAL_CONTAINER:/tmp/"

echo "Drop all $LOCAL_CONTAINER tables. Importing $REMOTE_FILE into $LOCAL_CONTAINER"
eval "docker exec -i $LOCAL_CONTAINER sh -c 'cd /var/www/html;drush sql-drop -vy; gunzip -c /tmp/$REMOTE_FILE | drush sqlc; drush cr'"

echo "Done!"
