#!/bin/bash

# Autor:    JazZ
# Email:    aleber@team-ever.com
# Date:     2018-03-21

# Bash script for easy Trello integration in Zulip.
#
# This script needs some API KEY and Token (from Zulip and Trello)
# For more information, please visit https://zulipchat.com/integrations/doc/trello


# BOT_API_KEY
# 
# In Zulip, create a new bot for *incomming Webhook*. 
# It will generate an API KEY
BOT_API_KEY=""

# TRELLO_API_KEY
#
# Visit https://trello.com/1/appkey/generate to generate
# an APPLICATION_KEY
TRELLO_API_KEY=""

# TRELLO_TOKEN
#
# To generate a Trello read access Token, visit (needs to be logged into Trello)
# https://trello.com/1/authorize?key=<APPLICATION_KEY>&name=Issue+Manager&expiration=never&response_type=token&scope=read
#
# Take care to replace <APPLICATION_KEY> with the TRELLO_API_KEY
TRELLO_TOKEN=""

# ZULIP_HOST
#
# The hostname of your Zulip application
ZULIP_HOST=""


# Display Usage 
display_usage() {
    echo -e "Usage :\n`basename $0` [stream_name] [trello_board_name] [trello_board_short_id]"
}

# if user supplied for help
if [[ $@ == "--help" || $@ == "-h" ]]
then
    display_usage

    exit 0
fi

# if arguments error
if [[ $# != 3 ]]
then
    echo "Error : Arguments error"
    display_usage

    exit 1
fi

# Assign needed vars
STREAM_NAME=$1
BOARD_NAME=$2
SHORT_ID=$3
ZULIP_BOT_URL="https://$ZULIP_HOST/api/v1/external/trello?api_key=$BOT_API_KEY&stream=$STREAM_NAME"


# Start integration
echo "-------------------------------------------------"
echo "| Starting Zulip webhook integration for Trello |"
echo "-------------------------------------------------"
echo

# Get Trello idModel
echo "--- Getting Trello idModel for the $BOARD_NAME board ---"
echo "Waiting for Trello API response..."

ID_MODEL=$(curl --silent "https://api.trello.com/1/board/$SHORT_ID?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq -r ".id")

if [[ $? != 0 || -z $ID_MODEL ]]
then
    echo "Error : can't get the Trello board idModel for $BOARD_NAME"

    exit 1
fi

echo "Success ! idModel = $ID_MODEL"
echo

# POST request to Trello API 
echo "--- Creating the webhook ---"
echo "Waiting for Trello API response..."

WEBHOOK_RESPONSE=$(curl --silent "https://api.trello.com/1/tokens/$TRELLO_TOKEN/webhooks/?key=$TRELLO_API_KEY" \
-H 'Content-Type: application/json' -H 'Accept: application/json' \
--data-binary '{"description": "Webhook for Zulip integration (From Trello '"$BOARD_NAME"' to Zulip '"$STREAM_NAME"')", "callbackURL": "'"$ZULIP_BOT_URL"'", "idModel": "'"$ID_MODEL"'"}' \
--compressed)

if [[ $? != 0 ]]
then
    echo "Error : can't create the WebHook"
    
    exit 1
fi

# check if response is JSON
if jq -e . >/dev/null 2>&1 <<<"$WEBHOOK_RESPONSE"
then
    echo "Congrats ! The Webhook has been successfuly created."

    exit 0
else
    # display error from Trello API
    echo $WEBHOOK_RESPONSE

    exit 1
fi

# If you get till here, there was an unexpected error
exit 1
