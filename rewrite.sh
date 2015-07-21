#!/bin/bash

if [ "$#" -lt 5 ]
then
echo "Missing parameters. See -h for help"
exit 0
fi

DEBUG=false

for i in "$@"
do
case $i in
    -d=*|--dmac=*)
    DESTINATION_MAC="${i#*=}"
    shift # past argument=value
    ;;
    -e=*|--dip=*)
    DESTINATION_IP="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--smac=*)
    SOURCE_MAC="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--sip=*)
	SOURCE_IP="${i#*=}"
	shift #past argument=value
	;;
	-f=*|--file*)
	FILE_PATH="${i#*=}"
	shift #past argument=value
	;;
	-h*|--help*)
    printf "Usage:
-d | --dmac  Destination MAC Address
-e | --dip   Destination IP Address
-s | --smac  Source MAC Address
-t | --sip   Source IP Address
-f | --file  Pcap file path to process
Example:
./rewrite.sh -d=00:15:17:57:c7:ad -e=10.1.2.2 -s=00:15:17:57:c6:c5 -t=10.1.2.3 -f=Vimeo1.pcap"
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


echo "DESTINATION_MAC  = ${DESTINATION_MAC}"
echo "DESTINATION_IP     = ${DESTINATION_IP}"
echo "SOURCE_MAC    = ${SOURCE_MAC}"
echo "SOURCE_IP    = ${SOURCE_IP}"
echo "FILE_PATH    = ${FILE_PATH}"
# echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
# if [[ -n $1 ]]; then
#     echo "Last line of file specified as non-opt/last argument:"
#     tail -1 $1
# fi
cd /users/barisymn

if $DEBUG ;
then
    echo "Running tcprewrite to convert MAC addresses.."
fi
tcprewrite --enet-dmac=$DESTINATION_MAC --enet-smac=$SOURCE_MAC --infile=$FILE_PATH --outfile=yturewrite_output_intermediate.pcap

if $DEBUG ;
then
    echo 'Running tcpprep..'
fi
tcpprep --auto=bridge --pcap=$FILE_PATH --cachefile=yturewrite_output_intermediate_cache.cache

if $DEBUG ;
then
    echo 'Running tcprewrite to convert IP addresses..'
fi
tcprewrite --endpoints=$SOURCE_IP:$DESTINATION_IP --cachefile=yturewrite_output_intermediate_cache.cache --infile=yturewrite_output_intermediate.pcap --outfile=yturewrite_output_intermediate_2.pcap --skipbroadcast

if $DEBUG ;
then
    echo 'Removing unncessesary files'
fi
rm yturewrite_output_intermediate.pcap
rm yturewrite_output_intermediate_cache.cache

if $DEBUG ;
then
    echo 'Running tcpreplay to broadcast..'
fi
tcpreplay --loop=0 --intf1=eth3 --mbps=100.0 yturewrite_output_intermediate_2.pcap
