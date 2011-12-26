ssh-ds is a small shell script that tunnels the AFP port of your disk station (and propably every other NAS with AFP and SSH services running) over ssh to your client computer.

So you can access your files and do Time Machine backups on a secured SSH connection via internet.

You can access the remote AFP server via port 12345 on your local machine. After running the script, the host should show up in Finder on Mac OS.

You run the script via cron to ensure that the connection still exists. If the tunnel is broken, it will be established again. To kill the tunnel you can use '-k' or '--kill' as command line parameters.

## TODO

- Add support for config files

## CHANGELOG

### 2011-12-27
- Added a help screen (-h or --help)

### 2011-12-26
- Fixed some small bugs with background processes regarding hangups of the script
- Added verbose mode (-v or --verbose)
- Implemented a cleaner way to kill the processes

### 2011-12-24
- Initial release

