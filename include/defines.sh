# Красивые цветные статус-сообщения
error_mes='[\E[31;47m Error \E[0m]' 	
ok_mes='[\E[32;47m\E[1m OK \E[0m]' 		
fail_mes='[\E[31;47m\E[1m FAIL \E[0m]'	

# те же яйца - вид сбоку (выравниваем по правой стороне):
#error_mes="$(tput hpa $(tput cols))$(tput cub 8)[\E[31;47m Error \E[0m]"
#ok_mes="$(tput hpa $(tput cols))$(tput cub 5)[\E[32;47m\E[1m OK \E[0m]"
#fail_mes="$(tput hpa $(tput cols))$(tput cub 7)[\E[31;47m\E[1m Fail \E[0m]"

WHOAMI=`whoami`
if [[ ${WHOAMI} == "root" ]]; then
	unalias chmod &>/dev/null
	unalias chown &>/dev/null
	unalias tar   &>/dev/null
	unalias awk   &>/dev/null
	# unalias -a
fi

# alias dbroot.sh='sudo /usr/local/bin/dbroot.sh'



#--------------------------------------------------------
# Ищем короткое имя cервера
short_hostname=`echo ${HOSTNAME} | awk -F. '{print $1}'` #serverXX splXX scpXX ...
server_type=`echo ${short_hostname} | sed 's/[0-9]*$//'`  #server spl scp ...
varwww_directory="/var/www"

#--------------------------------------------------------
# Файлы и каталоги
tmpBakDirName="tmpBackupsDir"
timestamp=`date +%Y.%m.%d_%H.%M.%S`    #date +%Y.%m.%d_%H:%M:%S_%N   %N - наносекунды :) # 2011.11.07_11:24:19_159425965
if [[ ${short_hostname} =~ (^spl[1-9]) ]]; then
	varwww_directory="/var/www/vhosts"
fi

#--------------------------------------------------------
# Пользователь MySQL
mysqladmin=root
if [[ ${short_hostname} =~ (^spl[1-9]) ]]; then
	mysqladmin=admin
fi

case "${short_hostname}" in 
	server[0-9]*|sbx[0-9]*)
		dbrootpass=`sudo grep Password /usr/local/ispmgr/etc/ispmgr.conf | gawk '{print $2}' | head -n1`
		;;
	scp[0-9]*)
		dbrootpass=`sudo cat /root/.my.cnf | grep pass | sed 's/^pass="//g' | sed 's/"$//g'`
		;;
	spl[0-9]*)
		dbrootpass=`sudo cat /etc/psa/.psa.shadow`

esac

