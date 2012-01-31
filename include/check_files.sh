#--------------------------------------------------------
# Проверяем есть ли файл с паролем /etc/rsync.secret
if [[ ! -e /etc/rsync.secret ]] ; then		
#		echo -e "${ok_mes}"
#	else
		echo -n "rsync password file /etc/rsync.secret not found: "
		echo -e "${error_mes}"
		clean_flag=0
		end_script
		exit 1;
fi

#--------------------------------------------------------
backup_server_script_path=`whereis backup_server.sh | awk {'print $2'}`
echo -n "Checking backup server: "
if [[ -e ${backup_server_script_path} ]] ; then		
		backup_server=`${backup_server_script_path}`
		echo -n "${backup_server} "
		echo -e "${ok_mes}"
	else
		echo -n "script backup_server.sh not found "
		echo -e "${error_mes}"
		clean_flag=0
		end_script
		exit 1;
fi


#--------------------------------------------------------
if [[ ! -e ~/${tmpBakDirName} ]] ; then		
		echo -n "Creating temporary directory ~/${tmpBakDirName}: "
		mkdir ~/${tmpBakDirName}
				
		if [[ -e ~/${tmpBakDirName} ]] ; then		
				echo -e "${ok_mes}"
			else
				echo -e "${error_mes}"
				clean_flag=0
				end_script
				exit 1;
		fi
fi




