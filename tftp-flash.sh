#!/bin/bash

# - iNFO -----------------------------------------------------------------------------
#
#        Author: wuseman <wuseman@nr1.nu>
#      FileName: loader.sh
#       Version: 1.0
#
#       Created: 2021-12-30 (18:24:16)
#      Modified: 2021-12-30 (18:57:38)
#
#           iRC: wuseman (Libera/EFnet/LinkNet) 
#       Website: https://www.nr1.nu/
#        GitHub: https://github.com/wuseman/
#
# - Descrpiption --------------------------------------------------------------------
#
#      Setup a temporary tftp server for bootp reply for flashing devices 
#
# - LiCENSE -------------------------------------------------------------------------
#
#      Copyright (C) 2021, wuseman                                     
#                                                                       
#      This program is free software; you can redistribute it and/or modify 
#      it under the terms of the GNU General Public License as published by 
#      the Free Software Foundation; either version 3 of the License, or    
#      (at your option) any later version.                                  
#                                                                       
#      This program is distributed in the hope that it will be useful,      
#      but WITHOUT ANY WARRANTY; without even the implied warranty of       
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        
#      GNU General Public License for more details.                         
#                                                                       
#      You must obey the GNU General Public License. If you will modify     
#      the file(s), you may extend this exception to your version           
#      of the file(s), but you are not obligated to do so.  If you do not   
#      wish to do so, delete this exception statement from your version.    
#      If you delete this exception statement from all source files in the  
#      program, then also delete it here.                                   
#
#      You should have received a copy of the GNU General Public License
#      along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# - End of Header -------------------------------------------------------------


usage() { 
    cat << EOF

    Usage: ./$basename$0 [-option] [-author] [-filename foo.bin] .....

          -a, --author        Show author information
          -h, --help          Print this useful help

          -f, --file          Choose firmware file
          -d, --dir           Path where firmware file is stored
          -i, --interface     Interface to setup bootp server
EOF
}

author() {
    cat << "EOF"

 Copyright (C) 2018-2020, wuseman

 tftp-flash.sh was created 2021 and was released as open source
 on github.com/wuseman/tftp-flash in January 2021 and is licensed
 under GNU LESSER GENERAL PUBLIC LICENSE GPLv3

   - Author: wuseman <wuseman@nr1.nu>
   - IRC   : wuseman <irc.libera.chat>

 Please report bugs/issues on:

   - https://github.com/wuseman/tftp-flash/issues

EOF
}



while getopts ":f:p:ha" opt; do
    case $opt in
        "a") 
            author; exit 1
            ;;
        "f")
            f=$OPTARG
            ;;
        "h")
            usage
            exit 0
            ;;
        "p") 
            p=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "option -$optarg requires an argument." >&2
            exit 1
            ;;
    esac
done



flash() {
    USER=$(whoami)
    IFNAME=enp0s20u4u3u4
    ip addr replace 192.168.1.10/24 dev $IFNAME
    ip link set dev $IFNAME up
    dnsmasq --user=$USER \
        --no-daemon \
        --listen-address 192.168.1.10 \
        --bind-interfaces \
        -p0 \
        --dhcp-authoritative \
        --dhcp-range=192.168.1.11,192.168.1.100 \
        --bootp-dynamic \
        --dhcp-boot=$f \
        --log-dhcp \
        --enable-tftp \
        --tftp-root=$p/
    }

if [[ ! -z $f && ! -z $p ]]; then
    echo -e "Path: $p" >&2
    echo -e "Filename: $f"
    read -p "Start server (y/N): " startserver
    if [[ $startserver = "y" ]]; then
        flash
    fi
elif [[ -z $f ]]; then 
    echo -e "$basename$0: internal error -- you must specify a filename, exiting..."
elif [[ -z $p ]]; then
    echo -e "$basename$0: internal error -- you must specify path where firmware is stored, exiting..."
else
    usage
fi
