# Terminal-Enforcement
Terminal-Enforcement Shell Script

A basic shell script I made to easily start and automate some of the basic security and
system hardening tools and applications I use. Its intended to be one of the first
commands the user would run after the system has booted and they have opened a terminal
and after the sudo apt update and sudo apt upgrade commands have been ran.

This script was crafted for use on a Kali Linux machine using a zsh terminal and that is also built on a debian
frame or at least debian based. I am sure it can be used or implemented with other Linux distro's though,
probably with some minor modifications or additions/subtractions to shell script but possibly could 
be run in a zsh terminal on different Linux distros out of the box with no modifications required. 


Tools to be automated:

auditd,
suricata,
AIDE,
nethogs,
iftop

!IMPORTANT!: these are required prerequisites for the script to successfully run & complete,
as this is NOT an installation script.







After cloning, downloading, or copying & pasting directly to a file:
--> Make it executable:
user@linux$ chmod +x sec-start.sh

Run it:
--> Auto-detect interface:
user@linux$ ./sec-start.sh

--> Or specify one explicitly:
user@linux$ ./sec-start.sh eth0
# or ./sec-start.sh wlan0
# or ./sec-start.sh tun0


Notes so you don’t get surprised:

AIDE init is a “do it once” operation (it can take a bit). After that, the script skips it.

If your Suricata service name differs, check with:

user@linux$ systemctl list-unit-files | grep -i suricata

