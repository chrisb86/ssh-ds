#!/bin/sh

## CONFIG

REMOTEUSER="user"
REMOTEHOST="remote.host.name"
LABEL="DiskStation" # The label for the service, that's registered with dns-sd


## NO NEED TO EDIT BELOW THIS LINE

REMOTELOGIN="$REMOTEUSER@$REMOTEHOST"

createTunnel() {
	# Register AFP as service via dns-sd
	dns-sd -R $LABEL _afpovertcp._tcp . 12345 > /dev/null &

	# Create tunnel to port 548 on remote host and make it avaliable at port 12345 at localhost
    # Also tunnel ssh for connection testing purposes
	ssh -gN \
	-L 12345:127.0.0.1:548 \
	-L 19922:127.0.0.1:22 \
	-C $REMOTELOGIN &

	if [[ $? -eq 0 ]]; then
        echo Tunnel to $REMOTEHOST created successfully
    else
        echo An error occurred creating a tunnel to $REMOTEHOST RC was $?
    fi
}

killTunnel() {
	killall -9 ssh # Kill all ssh processes. Dirty, but I didn't find a more elegant way yet.
	echo Successfully killed all ssh processes.
}

# Yippieeh, commandline parameters

while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
    case "$1" in
        -k|--kill)
            killTunnel
            exit 0
        ;;
        *)
 
        ;;
    esac
    shift       # Check next set of parameters.
done

## Run the 'ls' command remotely.  If it returns non-zero, create a new connection
ssh -p 19922 $REMOTEUSER@localhost ls > /dev/null
if [[ $? -ne 0 ]]; then
    echo Creating new tunnel connection
    createTunnel
fi
