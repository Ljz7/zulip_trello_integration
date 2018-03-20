# Easy Trello integration for Zulip

Bash script for a simplest Trello integration in Zulip

Usage : 

1. Fill the needed informations in `zulip_trello_webhook.sh` :

    - The bot API KEY,
    - The Trello API KEY,
    - The Trello TOKEN,
    - The Zulip host

2. Make the script executable : 

    $ chmod +x zulip_trello_webhook.sh

3. Call the script : 

    $ ./zulip_trello_webhook.sh [stream_name] [trello_board_name] [trello_board_short_id]

----------------------------------------
Pull requests and improvements or tips are welcome.
