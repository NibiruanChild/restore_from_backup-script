#!/bin/bash

case $1 in
u[0-9][0-9][0-9][0-9][0-9][0-9][0-9]|user_0000[0-9][0-9][0-9][0-9][0-9][0-9])
	user_login=`echo $1 | sed -e 's/\(.*\)/\L\1/' | sed 's#\D##g'`
	;;

*.[a-zA-Z][a-zA-Z][a-zA-Z]|*.[a-zA-Z][a-zA-Z]|*.[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]|*.xn--p1ai)
	sitename=`echo $1 | sed -e 's/\(.*\)/\L\1/' `
	;;

*)
	echo "Inknown parameter"
	cat <<USAGE
usage: 	
	domain -> path  		:		script.sh DOMAIN
	user   -> sites 		:		script.sh LOGIN site
	user   -> pathsofsites	:		script.sh LOGIN path
USAGE
	exit 0
	;;

esac

apacheconf_path="/etc/apache2/apache2.conf /etc/httpd/httpd.conf /etc/apache2/sites-enabled/* /etc/apache2/sites-enabled/* /etc/httpd/conf/httpd.conf /etc/apch2_2/conf.d/zz010_psa_httpd.conf"

domainsList=
aliasesList=
domainPath=
domainUser=
domainGroup=
domainsOfUser=

sudo cat ${apacheconf_path} 2>/dev/null| grep -i 'VirtualHost\|ServerAlias\|DocumentRoot\|ServerName\|SuexecUserGroup' | grep -v "NameVirtualHost\|^[ \t]*#" | sed 's#(^[ \t]*)|([ \t]$)##g' | sed 's/^<.*$/#/g' | sed -e 's/\(.*\)/\L\1/' |
while read LINE
do
	if [[ "${LINE}" == "#" ]]; then

		if [[ ! -z "${sitename}" && " ${aliasesList} ${domainsList}" =~ (${sitename}) ]]; then
			if [[ ! -z ${domainPath} ]]; then
				echo ${domainPath}
			fi
			exit			
		fi
		
		domainUser=`echo ${domainUser} | sed 's#\D##g'`
		if [[ ! -z ${user_login} && "${domainUser}" == "${user_login}" && "$2" == "site" ]]; then
			if [[ ! -z ${domainsList} ]]; then
				echo ${domainsList}
			fi
		fi				
		
		if [[ ! -z ${user_login} && "${domainUser}" == "${user_login}" && "$2" == "path" ]]; then
			if [[ ! -z ${domainPath} ]]; then
				echo ${domainPath}
			fi
		fi				
		
		domainsList=
		aliasesList=
		domainPath=
		domainUser=
		domainGroup=
	fi
		
	if [[ ${LINE} =~ (^[sS]erver[nN]ame) ]]; then		
		domainsList="${domainsList} `echo ${LINE} | sed 's#^[sS]erver[nN]ame[ \t]*##' | sed 's#^[sS]erver[aA]lias[ \t]*##' | sed 's#[\n\r\t ]# #' | sed -e 's/\(.*\)/\L\1/'`"	
		aliasesList="${aliasesList} `echo ${LINE} | sed 's#^[sS]erver[nN]ame[ \t]*##' | sed 's#^[sS]erver[aA]lias[ \t]*##' | sed 's#[\n\r\t ]# #' | sed -e 's/\(.*\)/\L\1/'`"	
	fi
	
	if [[ ${LINE} =~ (^[sS]erver[aA]lias) ]]; then		
		aliasesList="${aliasesList} `echo ${LINE} | sed 's#^[sS]erver[nN]ame[ \t]*##' | sed 's#^[sS]erver[aA]lias[ \t]*##' | sed 's#[\n\r\t ]# #' | sed -e 's/\(.*\)/\L\1/'`"	
	fi
	
	
	if [[ ${LINE} =~ (^[dD]ocument[rR]oot) ]]; then
		domainPath="${domainPath} `echo ${LINE} | sed 's#^[dD]ocument[rR]oot[ \t]*##' | sed 's#[\n\r\t ]# #' | sed -e 's/\(.*\)/\L\1/'`"	
	fi
		
	if [[ ${LINE} =~ (^[sS]uexec[uU]ser[gG]roup) ]]; then		
		domainUser="`echo ${LINE} | awk '{print $2}'` "
		domainGroup="`echo ${LINE} | awk '{print $3}'` "	
	fi
done
