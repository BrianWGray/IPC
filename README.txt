# ======================================================================================
# SharkRF IP Connector installation script by VE3OY
# Version *
# Delete all previous versions!
# ======================================================================================

This is intended to be installed onto a Raspberry Pi 3, (1GB of RAM and quad core CPU).

To begin the installation .....

Do a fresh image of Raspbian Buster onto your SDCard.
Boot and configure your RPi ... hostname, WiFi, etc, etc.

Next .....

On your RPi:
- sudo apt-get install git
- cd /home/pi/
- git clone https://github.com/BrianWGray/IPC.git
- at a command prompt, type the following commands:
	sudo su
	cd /home/pi/IPC
	chmod +x InstallIPConnector.sh
	./InstallIPConnectorV6.sh

# ======================================================================================
NOTES:
Pay close attention to upper/lowercase of the above commands!
It's CRITICAL!

Once the installation script runs, just follow any prompts.
Lots of information is shown, while the installation happens.

If you are running this installation on an existing Raspbian, then errors may happen.

No warranty or guarantee is made or implied.
Your mileage may vary!
Good luck, and enjoy!

Matt
ve3oy [at] ve3oy [dot] com
31DEC2018


(Original content copied from https://github.com/VE3OY/srf-ip-conn-srv and modified)