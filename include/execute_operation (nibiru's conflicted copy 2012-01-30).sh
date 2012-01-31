#--------------------------------------------------------
# Обрабатываем файлы
if [[ ${restore_files_count} -ge 1 ]]; then
	echo "FILES (${restore_files_count}):"
fi
for i in `seq 1 ${restore_files_count}`
do
	echo -e "\t${restore_files[$i]}"
	# Сначала качаем файлы
	echo -e -n "\t\tDownloading: "	
	sudo rsync -a --no-D -R --password-file=/etc/rsync.secret rsync://${short_hostname}@${backup_server}/${short_hostname}/userdata.${short_backup_date}${user_dir_short}/${restore_files[$i]} ~/${tmpBakDirName}/ 
	check_status $? strict   
	
	# Если надо, то восстанавливаем
	if [[ "${operation_type}" == "restore" ]]; then
		# делаем резервную копию
		if [[ -e ${varwww_directory}/${user_dir_short}/${restore_files[$i]} ]]; then		
			# проверим, не хомяк ли это
			if [[ ! "`dirname ${varwww_directory}/${user_dir_short}/${restore_files[$i]}`/`basename ${varwww_directory}/${user_dir_short}/${restore_files[$i]}`" == "`dirname ${varwww_directory}/${user_dir_short}`/`basename ${varwww_directory}/${user_dir_short}/`" ]]; then
				echo -e -n "\t\tBackuping:   "
				if [[ ${WHOAMI} == "root" ]]; then
					mv ${varwww_directory}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}/${user_dir_short}/`dirname ${restore_files[$i]}`/`basename ${restore_files[$i]}`_${timestamp}  
					check_status $? strict
				else
					sudo /usr/local/bin/sup_exec mv ${varwww_directory}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}/${user_dir_short}/`dirname ${restore_files[$i]}`/`basename ${restore_files[$i]}`_${timestamp}  &> /dev/null				
					check_status $? strict
				fi
				
				echo -e -n "\t\tRestoring:   "
				if [[ ${WHOAMI} == "root" ]]; then
					mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}${user_dir_short}/${restore_files[$i]} 
					check_status $? strict
				else
					sudo /usr/local/bin/sup_exec mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}${user_dir_short}/${restore_files[$i]} 		&> /dev/null
					check_status $? strict
				fi
			else
				echo -e -n "\t\tWARNING: all files of user will be deleted!!! (Use \"-S -B\" for restoring all files and backup current files)"
				
				echo -n " Do you want to continue? (y/n): "				
				read CONFIRM
				case $CONFIRM in
					y|Y|yes|YES|Yes)  ;;
					*) 
					  clean_flag=0
					  end_script
					  exit 0 
					  ;;
				esac				

				for i in `seq 0 5 | sort -r`; 
				do					
					echo -e -n "${i}"
					sleep 1
					echo -e -n "\b"
				done

				echo -e -n "\t\tRestoring:   "
				if [[ ${WHOAMI} == "root" ]]; then
					mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/* ${varwww_directory}${user_dir_short}/ 
					check_status $? strict
				else
					sudo /usr/local/bin/sup_exec mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/* ${varwww_directory}${user_dir_short}/ 		&> /dev/null
					check_status $? strict
				fi
			fi
		else
			# если бэкапить нечего, просто восстанавливаем
			echo -e -n "\t\tRestoring:   "
			if [[ ${WHOAMI} == "root" ]]; then
				mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}${user_dir_short}/${restore_files[$i]} 
				check_status $? strict
			else
				sudo /usr/local/bin/sup_exec mv ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/${restore_files[$i]} ${varwww_directory}${user_dir_short}/${restore_files[$i]} 	 &> /dev/null
				check_status $? strict
			fi
		fi	
	fi
	
	
	
	# Если не надо восстанавливать, то в любом случае создаем архив
	if [[ "${operation_type}" == "archive" || "${operation_type}" == "put" ]]; then
		echo -e -n "\t\tArchiving:   "		
		archive_name="backup`echo "${restore_files[$i]}" | sed "s#/\+#_#g" `_${backup_date}.tar.gz"		
		if [[ ${WHOAMI} == "root" ]]; then
			
			tar --gzip -c -f ~/${tmpBakDirName}/${archive_name} -C ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/ ./${restore_files[$i]} &> /dev/null  
			check_status $? strict
			chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${archive_name} 								
        else			
			sudo /usr/local/bin/sup_exec tar --gzip -c -f ~/${tmpBakDirName}/${archive_name} -C ~/${tmpBakDirName}/userdata.${short_backup_date}/${user_dir_short}/ ./${restore_files[$i]} # &> /dev/null  
			check_status $? strict
			sudo /usr/local/bin/sup_exec chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${archive_name} &> /dev/null        
        fi
        
	fi
	
	
	
	# Созданный архив если надо, то выдаем
	if [[ "${operation_type}" == "put" ]]; then
		echo -e -n "\t\tMoving:      "
		
		# чтобы создавался каталог для выкладывания бэкапа в него, а не в корень
		if [[ ! -e ${varwww_directory}${user_dir_short}/backups_${backup_date} ]]; then
			if [[ `whoami` == "root" ]]; then
				mkdir -p ${varwww_directory}${user_dir_short}/backups_${backup_date}
				chown ${user_login}:${ownerGroup} ${varwww_directory}${user_dir_short}/backups_${backup_date}
			fi
		fi		
		
		# ЧТОБЫ КОПИРОВАЛОСЬ В ПОДКАТАЛОГ
		if [[ -d ${varwww_directory}${user_dir_short}/backups_${backup_date} ]]; then
			if [[ ${WHOAMI} == "root" ]]; then
				mv -f ~/${tmpBakDirName}/${archive_name} ${varwww_directory}${user_dir_short}/backups_${backup_date}/ 
				check_status $? strict		
			else
				sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${archive_name} ${varwww_directory}${user_dir_short}/backups_${backup_date}/ &>/dev/null
				check_status $? strict		
			fi			
		else			
			if [[ ${WHOAMI} == "root" ]]; then
				mv -f ~/${tmpBakDirName}/${archive_name} ${varwww_directory}${user_dir_short}/
				check_status $? strict		
			else
				sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${archive_name} ${varwww_directory}${user_dir_short}/ &>/dev/null
				check_status $? strict	
			fi			
		fi       
	fi		
done



#--------------------------------------------------------
# Обрабатываем базы
if [[ ${restore_bases_count} -ge 1 ]]; then
	echo "BASES (${restore_bases_count}):"
fi

for i in `seq 1 ${restore_bases_count}`
do
	echo -e "\t${restore_bases[$i]}"
	
	# Сначала базу качаем
	echo -e -n "\t\tDownloading: "
	if [[ ${WHOAMI} == "root" ]]; then
		rsync -a --no-D --password-file=/etc/rsync.secret rsync://${short_hostname}@${backup_server}/${short_hostname}/databases/${restore_bases[$i]}-${backup_date}.sql.gz ~/${tmpBakDirName} #2>/dev/null
		check_status $? strict
	else
		sudo rsync -a --no-D --password-file=/etc/rsync.secret rsync://${short_hostname}@${backup_server}/${short_hostname}/databases/${restore_bases[$i]}-${backup_date}.sql.gz ~/${tmpBakDirName} #2>/dev/null
		check_status $? strict
	fi

	if [[ "${operation_type}" == "restore" ]]; then
		# предварительно бэкапим текущее состояние
		echo -e -n "\t\tBackuping:   "	
		# создаем дамп
        mysqldump -u${mysqladmin} -p`sudo dbroot.sh` ${restore_bases[$i]} > ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql
    
        
        # собственно если было чего сдампить
        if [[ -e ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql ]]; then
        
			if [[ ${WHOAMI} == "root" ]]; then			
				chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql
				tar --gzip -c -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz -C ~/${tmpBakDirName}/ ./${restore_bases[$i]}_${timestamp}.sql &> /dev/null
				chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz
			else			
				sudo /usr/local/bin/sup_exec chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql &>/dev/null
				sudo /usr/local/bin/sup_exec tar --gzip -c -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz -C ~/${tmpBakDirName}/ ./${restore_bases[$i]}_${timestamp}.sql &> /dev/null
				sudo /usr/local/bin/sup_exec chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz &>/dev/null
			fi
        
			if [[ `whoami` == "root" ]]; then
				mkdir -p ${varwww_directory}${user_dir_short}/backups_${timestamp}
				chown ${user_login}:${ownerGroup} ${varwww_directory}${user_dir_short}/backups_${timestamp}
			fi
			
			# перетаскиваем в каталог пользователя
			if [[ -d ${varwww_directory}${user_dir_short}/backups_${timestamp} ]]; then
				if [[ ${WHOAMI} == "root" ]]; then
					mv -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz ${varwww_directory}${user_dir_short}/backups_${timestamp}/ 
					check_status $? strict
				else
					sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz ${varwww_directory}${user_dir_short}/backups_${timestamp}/ &>/dev/null		
					check_status $? strict
				fi
			else
				if [[ ${WHOAMI} == "root" ]]; then
					mv -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz ${varwww_directory}${user_dir_short}/ 
					check_status $? strict
				else
					sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${restore_bases[$i]}_${timestamp}.sql.tar.gz ${varwww_directory}${user_dir_short}/ &>/dev/null
					check_status $? strict
				fi
			fi	
		else
				echo -e "${error_mes}"
				clean_flag=0
				end_script
				exit 0
        fi
        
		echo -e -n "\t\tImport:      "	
		gunzip ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz
        mysql -u${mysqladmin} -p`sudo dbroot.sh` ${restore_bases[$i]} < ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql
        check_status $? strict
	fi
	
	# если не надо выдать, то выдаем (база бэкапируется уже в архиве)	
	if [[ "${operation_type}" == "put" ]]; then
		echo -e -n "\t\tMoving:      "
		if [[ ${WHOAMI} == "root" ]]; then
			chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz
		else
			sudo /usr/local/bin/sup_exec chown ${user_login}:${ownerGroup} ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz  &>/dev/null
		fi
		
		# чтобы создавался каталог для выкладывания бэкапа в него, а не в корень
		if [[ ! -e ${varwww_directory}${user_dir_short}/backups_${backup_date} ]]; then			
			if [[ `whoami` == "root" ]]; then
				mkdir -p ${varwww_directory}${user_dir_short}/backups_${backup_date}
				chown ${user_login}:${ownerGroup} ${varwww_directory}${user_dir_short}/backups_${backup_date}
			fi
		fi		
		
		# ЧТОБЫ КОПИРОВАЛОСЬ В ПОДКАТАЛОГ
		if [[ -d ${varwww_directory}${user_dir_short}/backups_${backup_date} ]]; then
			if [[ ${WHOAMI} == "root" ]]; then
				mv -f ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz ${varwww_directory}${user_dir_short}/backups_${backup_date}/ 
				check_status $? strict
			else
				sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz ${varwww_directory}${user_dir_short}/backups_${backup_date}/ &>/dev/null		
				check_status $? strict
			fi
		else
			if [[ ${WHOAMI} == "root" ]]; then
				mv -f ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz ${varwww_directory}${user_dir_short}/ 
				check_status $? strict
			else
				sudo /usr/local/bin/sup_exec mv -f ~/${tmpBakDirName}/${restore_bases[$i]}-${backup_date}.sql.gz ${varwww_directory}${user_dir_short}/ &>/dev/null
				check_status $? strict
			fi
		fi        
	fi	
done
