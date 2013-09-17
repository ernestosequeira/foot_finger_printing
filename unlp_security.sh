#!/bin/bash
########### Autor: Ernesto Sequeira ###############################################
########### UNLP - Seguridad y Privacidad en Redes de Datos - D - 2013 ############

# Colors constants
NONE="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="\n$(tput setaf 3)"
BLUE="\n$(tput setaf 4)"

message_date() {
	# $1 : Message
	# $2 : Color
	# return : Message colorized
	local NOW="[$(date +%H:%M:%S)]"
	echo -e "${2}${NOW}${1}${NONE}"
}

message() {
	# $1 : Message
	# $2 : Color
	# return : Message colorized
	echo -e "${2}${1}${NONE}"
}

install_packages() {
	sudo aptitude install nmap -y > /dev/null
}

main_menu() {
	clear
	while [ "$option" != 3 ]
	do
		echo " Main Menu: "
		echo " -----------"
		echo "[1]. Footprinting (non-intrusive)"
		echo "[2]. Fingerprinting(intrusive)"
		echo "[3]. Other"
		echo "[4]. Exit"
		read -p "Select an option [1-4]: " option
	case $option in
		1) footprinting;;
		2) fingerprinting;;
		3) other;;
		4) exit 0;;
		*) echo "$option is an invalid option.";
		echo "Press any key to finish continue...";
		read foo;;
	esac
	done
}
footprinting(){
	echo "Input the name site: (example: unlp.edu.ar)"
	read web
	message ">> Start scanning web site." ${GREEN}
	echo $(host $web) > scan_3.out
    	message "$(awk '{ print "IP:";print $4 }' FS=" " scan_3.out)" ${RED}

    	echo "------------------------------------------"
    	message "Register/s MX:" ${RED}
	message "$(dig -t mx $web | grep IN)" ${RED}

	echo "------------------------------------------"
    	message "Server/s DNS:" ${RED}
	message "$(dig -t ns $web | grep IN)" ${RED}

	echo "------------------------------------------"
	ip=$(awk '{ print $4 }' FS=" " scan_3.out)
	message "Server version DNS BIND:" ${RED}
	message "$(dig @$ip version.bind chaos txt | grep DiG)" ${RED}

	message_date ">> Scanning complete." ${GREEN}
	echo "Press any key to finish..."
	read p
	clear
}

fingerprinting(){
	echo "Input the network range to discover: (example: 192.168.1.0/24)"
	read net
	message_date ">> Start scanning network." ${GREEN}
	sudo nmap -sP $net -oN scan_1.out >/dev/null
	message "$(grep report scan_1.out)" ${RED}
	message_date ">> Scanning complete." ${GREEN}

	echo "Input the IP number to discover: (example: 192.168.1.33)"
	read ip
	message_date ">> Start scanning ports and SO" ${GREEN}
	sudo nmap -O $ip -oN scan_2.out >/dev/null
	message "$(grep windows scan_2.out || grep linux scan_2.out || grep Mac scan_2.out 2>/dev/null)" ${RED}
	message "$(grep open scan_2.out 2>/dev/null)" ${RED}
	message_date ">> Scanning complete." ${GREEN}

	echo "Press any key to finish..."
	read p
	clear
}

install_packages
main_menu

