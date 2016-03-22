This guide assumes you've just provisioned a VPS or your own server and are running Ubuntu and that you have root access.

### Update packages
SSH into your newly provisioned server as root (ie: `ssh root@123.123.123.123`): and run the following commands to ensure you have the latest packages.

```
apt-get update
apt-get upgrade -y
```

### Setup swap space
By default I setup a 2 GB swap file - It's necessary on systems with 512mb RAM.

Paste these commands to get an active 2GB swapfile.
```
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

Verify it was successful by running:

```
swapon -s
```

You should see something like the following:
```
Filename				Type		Size	Used	Priority
/swapfile                               file		2097148	0	-1
```

To ensure that the swapfile is mounted at boot. Run the following command to append a line to `/etc/fstab`:

```
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
```

And you're done. If you ran into problems, refer to the [DigitalOcean tutorial on setting up a swapfile](https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04).
