## Tips
Run this on your laptop to get all your mac addresses

    ifconfig | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'