check_args() {
while [[ $# -gt 0 ]]; do
case "$1" in
	-l|--enable-log)
			keeplog="yes"
			shift;;
	-c|--pref-curl)
			prefwget="no"
			shift;;
	-w|--use-wget)
			downagent="wget"
			shift;;
	-r|--redownload)
			forcedown="yes"
			shift;;
	-f|--force-distro)
			forcedistro="yes"
			shift;;
	-n|--nobakup)
			keepbackup="no"
			shift;;
	-t|--use-tts)
			tts="yes"
			shift;;
	-d|--debug)
			if [[ -r "$logfile" ]]; then
				cat "$logfile"
			else
				echo -e "No logfile exists. Try running Fedora Utils with logging enabled. Use --help for more details"
			fi
			exit;;
	-e|--exec)			
			if [[ `grep -w "# Command: $2" $plugindir/*.sh` ]]; then
				interactive="no"
				check_root
				enable_log
				check_lock
				check_req
				initialize_program
				while [[ $# -gt 1 && `grep -w "# Command: $2" $plugindir/*.sh` ]]; do			
					for plug in $plugindir/*.sh; do source "$plug"; done
					eval "$2"
					shift
				done
				complete_program
			elif [[ $2 = "list" ]]; then
				echo -e "Usage:\tfedorautils --exec [COMMANDS...]"
				echo -e "\v"
				for plug in $plugindir/*.sh; do
					command=$(cat $plug | grep "# Command: " | sed 's/# Command: //g')
					name=$(cat $plug | grep "# Name: " | sed 's/# Name: //g')
					printf "\t%-30s%-s\n" "$command" "$name"
				done
				echo -e "\v"
				echo -e "The \"--exec\" argument does not accept other arguments with it."
				exit
			else
				echo -e "Invalid command \"$2\". Try \"--exec list\" for a list of available commands."
				exit
			fi;;
	-h|--help)
			args=( "-l, --enable-log" "-c, --pref-curl" "-w, --use-wget" "-r, --redownload" "-f, --force-distro" "-n, --nobakup" "-t, --use-tts" "-e, --exec <commands>" "-d, --debug" "-h, --help" )
			desc=( "start with logging enabled" "prefer curl over wget unless specified" "use wget for download instead of curl" "force redownload of files" "run with unsupported distro" "do not keep backups" "use text-to-speech" "execute commands from the plugins" "show last logfile and exit" "show this help message and exit" )
			echo -e "Usage:\tfedorautils [ARGUMENT...]"
			echo -e "\v"
			for ((i=0; i < ${#args[@]}; i++)); do
				printf "\t%-30s%-s\n" "${args[i]}" "${desc[i]}"
			done
			echo -e "\v"
			echo -e "See the man page for more help."
			exit;;
	*)
			echo -e "Invalid argument \"$1\". Try \"--help\" for list of arguments."
			exit;;
esac
done
}