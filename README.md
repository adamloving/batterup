# What is Batter Up?

This is a ruby script to scan a wifi network for new devices, and play a theme song when somebody re-appears after 
being gone. You have to manually map mac addresses to people (people may have multiple devices). You can do this
by running the script, and correlating new addresses with people walking in to work.

## Setup

1. Create a known_addrs.json file (see sample)
2. Put mp3 files in music/{username}.mp3

## Running it

    $ ./scan.rb [history file] [ip prefix] [number of ips]

    $ ./scan.rb office.json '10.1.10.' 50

See scan-home.sh and scan-office.sh for examples

## Tips
Run this on your laptop to get all your mac addresses

    ifconfig | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
