#!/bin/bash

DEBUG=false
INT_OUT_FILE_NAME="yturewrite_output_intermediate.pcap"
INT_CACHE_FILE_NAME="yturewrite_output_intermediate_cache.cache"
INT_FINAL_OUT_FILE_NAME="yturewrite_output_intermediate_2.pcap"

for i in "$@"
do
case $i in
	-h*|--help*)
    printf "Usage: Please edit rewrite_config.conf for options."
	;;
	-v*|--verbose*)
	DEBUG=true
	shift #past argument=value
	;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source rewrite_config.conf

if [ -z "$DEST_ALIAS" ]; then
    echo "Missing destination IP."
    exit 0
fi

if [ -z "$ETH_ALIAS" ]; then
    echo "Missing ethernet alias."
    exit 0
fi

if [ -z "$FILE_NAME" ]; then
    echo "Missing pcap file name."
    exit 0
fi

sourceMacAddress=$(cat /sys/class/net/$ETH_ALIAS/address)
sourceIPAddress=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | head -1)

ping $DEST_ALIAS -c 1

destinationMacAddress=$(arp -a | sed -n -e /^$DEST_ALIAS/p  | grep -o -E -m -1 '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | head -1)
destinationIPAddress=$(arp -a | sed -n -e /^$DEST_ALIAS/p | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)



echo "Detected source MAC:$sourceMacAddress"
echo "Detected source IP:$sourceIPAddress"
echo "Detected destinationMacAddress:$destinationMacAddress"
echo "Detected destinationIPAddress:$destinationIPAddress"

if $DEBUG ;
then
    echo "Running tcprewrite to convert MAC addresses.."
fi

tcprewrite --enet-dmac=$destinationMacAddress --enet-smac=$sourceMacAddress --infile=$FILE_NAME --outfile=$INT_OUT_FILE_NAME

if $DEBUG ;
then
    echo 'Running tcpprep..'
fi
tcpprep --auto=bridge --pcap=$FILE_NAME --cachefile=$INT_CACHE_FILE_NAME

if $DEBUG ;
then
    echo 'Running tcprewrite to convert IP addresses..'
fi

tcprewrite --endpoints=$sourceIPAddress:$destinationIPAddress --cachefile=$INT_CACHE_FILE_NAME --infile=$INT_OUT_FILE_NAME --outfile=$INT_FINAL_OUT_FILE_NAME --skipbroadcast

if $DEBUG ;
then
    echo 'Removing unncessesary files'
fi

rm $INT_OUT_FILE_NAME
rm $INT_CACHE_FILE_NAME

if $DEBUG ;
then
    echo 'Running tcpreplay to broadcast..'
fi
tcpreplay --loop=$TCPREPLAY_LOOP --intf1=$ETH_ALIAS --mbps=$TCPREPLAY_SPEED yturewrite_output_intermediate_2.pcap
