RUNNING UPDATE AND UPGRADE
This one's easy, we'll just call:

apt-get update && apt-get upgrade -y
where:

&& allows you to queue commands one after the other,
-y automatically selects the "yes" option when the user would be prompted to initiate an installation.



--------------------
exemplo:

PACKAGES="python-picamera graphicsmagick python-pip"
apt-get install $PACKAGES -y

-------------------------

/boot/config.txt - modificar gpu-mem para 16

# If a line containing "gpu_mem" exists
if grep -Fq "gpu_mem" $CONFIG
then
	# Replace the line
	echo "Modifying gpu_mem"
	sed -i "/gpu_mem/c\gpu_mem=16" $CONFIG
else
	# Create the definition
	echo "gpu_mem not defined. Creating definition"
	echo "gpu_mem=16" >> $CONFIG
fi
