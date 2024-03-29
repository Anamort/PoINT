# PoINT
This repository includes neccessary files for the project.

###Explanation
- <code>upstart.sh</code> script does all the neccessary installation for the project. It first installs <code>tcpreplay</code> by extracting an existing package.<br/>
After that it installs <code>ifstat</code> which is a monitoring tool that shows incoming and outgoing traffic of available ethernet interfaces.<br/>
Last thing this script does is installing required packages for <code>NetClassify</code> and compiling it's source code. Thanks to NetClassify, we're able to capture network traffic over an ethernet interface. 

- <code>rewrite.sh</code> script replays previously saved traffic over specific ethernet interface to a given destination. <code>rewrite_config.conf</code> file is the place all the configurations are made for this script. A valid node name should be set in configuration file such as <code>node0</code>. An example is given below for this configuration file:
 
```
DEST_ALIAS=node1
ETH_ALIAS=eth0
FILE_NAME=Vimeo_1.pcap
TCPREPLAY_LOOP=0
TCPREPLAY_SPEED=100
```

####Behind the scenes
**Q:** So what does <code>rewrite.sh</code> script do actually?<br/>
**A:** After reading destination and source options from the configuration file, the script tries to detect their MAC and IP addresses automatically.<br/> The previously saved pcap file includes some destination, source MAC and IP addresses which may not be valid for some experiments. To replace them apropriately with the detected addresses according to current needs, <code>tcprewrite</code> can be used. That's what the script does mainly. MAC and IP addresses of packets in the pcap file are replaced respectively with the current source and destination addresses by running below commands:

```
tcprewrite --enet-dmac=$destinationMacAddress --enet-smac=$sourceMacAddress --infile=$FILE_NAME --outfile=$INT_OUT_FILE_NAME

tcpprep --auto=bridge --pcap=$FILE_NAME --cachefile=$INT_CACHE_FILE_NAME

tcprewrite --endpoints=$sourceIPAddress:$destinationIPAddress --cachefile=$INT_CACHE_FILE_NAME --infile=$INT_OUT_FILE_NAME --outfile=$INT_FINAL_OUT_FILE_NAME --skipbroadcast

```
And finally after all the replacements are done, <code>tcpreplay</code> command does the broadcast as follows:

```
tcpreplay --loop=$TCPREPLAY_LOOP --intf1=$ETH_ALIAS --mbps=$TCPREPLAY_SPEED yturewrite_output_intermediate_2.pcap
```

###Usage
Current setup is built on top of <code>Ubuntu 14</code> operating system and tested in it. In order to run this setup <code>upstart.sh</code> script first be run. It is important to give required permissions by running <code>chmod +x upstart.sh</code> command first and then running the script with <code>sudo ./upstart.sh</code> command.

Once all the requirements are satisfied, <code>rewrite.sh</code> script can be run same manner as above. An example output of <code>rewrite</code> script is as follows:


```
said@node0:~$ sudo ./rewrite.sh
...
Detected source MAC:00:04:23:c5:dc:30
Detected source IP:10.1.1.2
Detected destinationMacAddress:00:04:23:c7:a8:17
Detected destinationIPAddress:10.1.3.3
```
If <code>-v</code> option is specified to <code>rewrite</code> command, it will print detailed explanation, what it is currently up to.
