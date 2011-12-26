#!/bin/sh

## CONFIG

REMOTEUSER="user" # The ssh user name on remote server
REMOTEHOST="remote.host.name" # The ssh user password on remote server
LABEL="DiskStation" # The label for the service, that's registered with dns-sd


## NO NEED TO EDIT BELOW THIS LINE

VERSION="2011-12-27"

VERBOSE=false

REMOTELOGIN="$REMOTEUSER@$REMOTEHOST"

createTunnel() {
    # Create tunnel to port 548 on remote host and make it avaliable at port 12345 at localhost
    # Also tunnel ssh for connection testing purposes
    ssh -gNf \
    -L 12345:127.0.0.1:548 \
    -L 19922:127.0.0.1:22 \
    -C $REMOTELOGIN &

    if [[ $? -eq 0 ]]; then
        # Register AFP as service via dns-sd
        dns-sd -R $LABEL _afpovertcp._tcp . 12345 > /dev/null &
        
        if [ $VERBOSE = "true" ]; then echo Tunnel to $REMOTEHOST created successfully; fi
        exit 0
    else
        if [ $VERBOSE = "true" ]; then echo An error occurred creating a tunnel to $REMOTEHOST RC was $?; fi
        exit 1
    fi
}

killTunnel() {
    MYPID=`ps aux | egrep -w "$REMOTEHOST|dns-sd -R $LABEL" | grep -v egrep | awk '{print $2}'`
    for i in $MYPID; do kill $i; done
    echo All processes killed
}

help() {
    echo "ssh-ds  version $VERSION

ssh-ds is a small shell script that tunnels the AFP port of your disk station
(and propably every other NAS with AFP and SSH services running) over ssh to your client computer.

Put your settings in the config section in the script itself!

Options
 -v, --verbose               increase verbosity
 -k, --kill                  kill all ssh-ds processes
 -h, --help                  show this screen
"
exit 0
}

# Yippieeh, commandline parameters

while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
    case "$1" in
        -k|--kill)
            killTunnel
            exit 0
        ;;
        -v|--verbose)
            VERBOSE=true
        ;;
        -h|--help)
            help
        ;;
        *)
 
        ;;
    esac
    shift       # Check next set of parameters.
done

## Run the 'ls' command remotely.  If it returns non-zero, create a new connection
ssh -q -p 19922 $REMOTEUSER@localhost ls > /dev/null
if [[ $? -ne 0 ]]; then
    createTunnel
else
    if [ $VERBOSE = "true" ]; then echo Tunnel to $REMOTEHOST is active; fi
fi