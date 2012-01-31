#--------------------------------------------------------
# Отпарсим аргументы ОСНОВНОГО скрипта
user_login=""
operation_type="restore"
backup_date=""
#restore_files[0]=""
#restore_bases[0]=""
restore_files_count=0
restore_bases_count=0
sitesPaths=
sitesList=

clean_flag=1

sites_flag=0
allSites_flag=0

bases_flag=0
allBases_flag=0

files_flag=0
allFiles_flag=0

while [ "$1" ]
do
    case "$1" in
    
    # Пользователь
    -u|--user)       
        # проверяем есть ли у флага аргумент и удовлетворяет ли он u1234567 или user_0123456789
        if [[ ("$2" =~ (^u[0-9]{7,}$) || "$2" =~ (^user[_]{0,1}[0-9]{7,}$)) ]]; then 
                # если совпадает с видом логина, то все гуд
                user_login="$2"
            else
                # если не совпадает, то usage и exit
                usage
                exit 1;
        fi
        
        #--------------------------------------------------------
	#	# HOME каталог пользователя
	#	user_dir_short=`sudo grep "${user_login}" /etc/passwd | grep -v "^#" | awk -F: '{print $6}'` ;
	#	user_dir_short=`echo ${user_dir_short} | sed "s#^${varwww_directory}##g"`
	#	if [[ -z ${user_dir_short} ]]; then
	#		echo -e "There is no user ${fail_mes}"
	#		end_script
	#		exit 0
	#	fi
        
        # стираем сам флаг
        shift 
        # стираем и аргумент флага
        shift        
        ;;
        
    -d|--date)   
		
        # проверяем есть ли у флага аргумент и удовлетворяет 2011-12-31
        if [[ "$2" =~ (^[0-9]{4}-[0-9]{2}-[0-9]{2}$) ]]; then 
                # если совпадает с видом даты, то все гуд
                backup_date="$2"
            else
                # если не совпадает, то usage и exit
                echo -e "There is not date argument or it have incorrect format ${fail_mes}"
                usage
                exit 1;
        fi        
        
		#--------------------------------------------------------
		# Определяем короткий формат даты 2011-12-31 -> 20111231
		short_backup_date=`echo ${backup_date} | sed 's/-//g'`
			
        # стираем сам флаг
        shift
        # стираем и аргумент флага
        shift        
        ;;    
    
    # Тип операции:
    
    -r)
        # восстановлени
        operation_type="restore"
        # стираем сам флаг
        shift         
        ;;
    -a)
        # выдача архива
        operation_type="put"
        # стираем сам флаг
        shift
        ;;
    -A)
        # создание архива без выдачи
        operation_type="archive"
		clean_flag=0
        # стираем сам флаг
        shift
        ;;
        
     # Операнды:
     
    -f|--file)
        # файл или каталог
        files_flag=1
        if [[ "$2" =~ (^/.*?$) ]]; then 
                # если совпадает с видом пути, то все гуд
                let "restore_files_count=restore_files_count+1"
                restore_files[${restore_files_count}]="$2"
            else
                # если не совпадает, то usage и exit
                echo -e "There is not file argument or it have incorrect format ${fail_mes}"
                usage
                exit 1;
        fi        
        # стираем сам флаг
        shift
        # стираем и аргумент флага
        shift   
        ;;
        
    -F|--all_files)
        allFiles_flag=1
        let "restore_files_count=restore_files_count+1"
        # все файлы пользователя (по сути каталог ~/)
        restore_files[${restore_files_count}]="/" 
        # стираем сам флаг
        shift
        ;;

    -s|--site)
        if [[ "$2" =~ (^[^-].*?\..*?$) ]]; then      

					sites_flag=1;
					sitesList="${sitesList} $2"

            else
                # если не совпадает, то usage и exit
                echo -e "There is not site argument or it have incorrect format ${fail_mes}"
                usage
                exit 1;
        fi        

        # сайт ( по сути каталог с сайтом), вычисляем из apache2.conf
        
        # стираем сам флаг
        shift
        # стираем и аргумент флага
        shift 
        ;;
    
    -S|--all_sites)
        # все сайты                     
        allSites_flag=1  
                
        # стираем сам флаг
        shift
        ;;
     
    -b|--base)
        # база данных
        if [[ "$2" =~ (^[^-].*?$) ]]; then 				
                # если совпадает с видом пути, то все гуд
                let "restore_bases_count=$restore_bases_count+1"
                restore_bases[${restore_bases_count}]="${2}"
            else
                # если не совпадает, то usage и exit
                echo -e "There is not base argument or it have incorrect format ${fail_mes}"
                usage
                exit 1;
        fi         
        bases_flag=1
        # стираем сам флаг
        shift
        # стираем и аргумент флага
        shift 
        ;;
    
    -B|--all_bases)
        # все базы пользователя
        allBases_flag=1
        
      
        # стираем сам флаг
        shift
        ;;        
        
     # Другие флаги:   
     
    -c|--no_clean)
		clean_flag=0;
		shift;
        ;;
        
    -h|--help)
        usage;
        exit 1;
        ;;
        
    -V|--version)
	echo -e "Version: ${SCRIPT_VERSION}"
	shift
	;;
        
     # автопарсинг
     
     u[0-9][0-9][0-9][0-9][0-9][0-9][0-9]|user_000[0-9][0-9][0-9][0-9][0-9][0-9][0-9])
		user_login="$1"     

		#--------------------------------------------------------
		#	# HOME каталог пользователя
		#	user_dir_short=`sudo grep "${user_login}" /etc/passwd | grep -v "^#" | awk -F: '{print $6}'` ;
		#	user_dir_short=`echo ${user_dir_short} | sed "s#^${varwww_directory}##g"`
		#	if [[ -z ${user_dir_short} ]]; then
		#		echo -e "There is no user ${fail_mes}"
		#		end_script
		#		exit 0
		#	fi
		shift
		;;

	 20[0-9][0-9]-[0-9][0-9]-[0-9][0-9])
		backup_date="$1"        
		short_backup_date=`echo ${backup_date} | sed 's/-//g'`
		shift
		;;
		
	 u[0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*|user_000[0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*)
		let "restore_bases_count=$restore_bases_count+1"
        restore_bases[${restore_bases_count}]="${1}"                   
        bases_flag=1
		shift
		;;
		
	 /*)
		files_flag=1
        let "restore_files_count=restore_files_count+1"
        restore_files[${restore_files_count}]="$1"
		shift
		;;
		
	 *.[a-zA-Z][a-zA-Z][a-zA-Z]|*.[a-zA-Z][a-zA-Z]|*.[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]|*.xn--p1ai)
		sites_flag=1;
		sitesList="${sitesList} $1"
		shift
		;;  
        
        
    *)    
        usage;
        exit 1;
        ;;
    esac

done


if [[ -z "${user_login}" ]] ; then
    echo -e "There is not user for restore (use \"-u u1234567\") ${fail_mes}"
    end_script
    exit 0
fi

if [[ ! ${operation_type} == "archive" ]]; then
    #--------------------------------------------------------
    # HOME каталог пользователя   
    user_dir_short=
    user_dir_short=`sudo grep "${user_login}:" /etc/passwd | grep -v "^#" | grep -v "/bin/false" | awk -F: '{print $6}'` ;
    if [[ -z ${user_dir_short} ]]; then
	user_dir_short=`sudo grep "${user_login}" /etc/passwd | grep -v "^#" | grep -v "/bin/false" | awk -F: '{print $6}'` ;
	echo "username was changed from ${user_login}: Flag -S does not work" 
    fi    
    
    if [[ -z ${user_dir_short} ]]; then
	    echo -e "There is no user ${fail_mes}"
	    end_script
	    exit 0
    fi
    user_dir_short=`readlink -f ${user_dir_short}` ; # резолвим реальный каталог, если это симлинк
    user_dir_short=`echo ${user_dir_short} | sed "s#^${varwww_directory}##g"`

    #--------------------------------------------------------
    # Группа пользователя для выставления прав на выданные файлы
    ownerGroup="${user_login}"
    if [[ ${short_hostname} =~ (^spl[1-9]) ]]; then
	ownerGroup=psaserv
    fi

else
    #--------------------------------------------------------
    # HOME каталог пользователя 
    user_dir_short=
    user_dir_short=`sudo grep "${user_login}" /etc/passwd | grep -v "^#" | awk -F: '{print $6}'` ;    
    if [[ -z ${user_dir_short} ]]; then
	    # Если пользователя уже нет на хостинг сервере, то надо как то указать путь к его HOME на backup сервера	    
	    echo "May be user was deleted: Flag -S does not work" 
	    case "$1" in
	    sbx*|server*)
		user_dir_short=/var/www/${user_login}
		;;
	    scp*)
		user_dir_short=/var/www/${user_login}
		;;
	    spl*)
		user_dir_short=/var/www/vhosts/${user_login}.plsk.regruhosting.ru
		;;
	    esac
    else	
	    user_dir_short=`readlink -f ${user_dir_short}` ; # резолвим реальный каталог, если это симлинк    	
    fi
    
    user_dir_short=`echo ${user_dir_short} | sed "s#^${varwww_directory}##g"`
    
fi

if [[ -z "${backup_date}" ]] ; then
    echo -e "There is not date of backup (use \"-d 2011-12-31\") ${fail_mes}"
    end_script
    exit 0
fi

if [[ 	${sites_flag}    == 0 &&
	${allSites_flag} == 0 &&
	${bases_flag}    == 0 &&
	${allBases_flag} == 0 &&
	${files_flag}    == 0 &&
	${allFiles_flag} == 0 ]] ; then

	allSites_flag=1;
	allBases_flag=1;	
fi


if [[ ${allBases_flag} == 1 ]] ; then		
	for current_base in `( sudo rsync -a --no-D --password-file=/etc/rsync.secret rsync://${short_hostname}@${backup_server}/${short_hostname}/databases/${user_login}_\*${backup_date}.sql.gz 2>/dev/null )  | awk {'print $5'} | sed "s/-${backup_date}.sql.gz$//"`
	do
		let "restore_bases_count=$restore_bases_count+1"
		restore_bases[${restore_bases_count}]="${current_base}"
	done
fi


if [[ ${allSites_flag} == 1 ]] ; then		
	echo -e -n "Parcing sites of user: "
	for currentSitePath in `${dirname0}/apacheconf_parcer.sh ${user_login} path | sed 's#^"##' | sed 's#"$##' |sed "s#^${varwww_directory}${user_dir_short}##"`
	do
		let "restore_files_count=restore_files_count+1"
		restore_files[${restore_files_count}]="${currentSitePath}"
		echo -e -n "\n\t${restore_files[${restore_files_count}]}"
	done
	echo
fi


if [[ ${sites_flag} == 1 ]] ; then	
	echo -e -n "Parcing paths of sites: "
	for currentSite in ${sitesList}
	do
		echo -e -n "\n\t${currentSite}: "
		
		# если ISP:
		if [[ -e /usr/local/ispmgr/sbin/mgrctl ]]; then
			let "restore_files_count=restore_files_count+1"
			restore_files[${restore_files_count}]=`sudo /usr/local/ispmgr/sbin/mgrctl wwwdomain.edit elid=${currentSite}  | grep docroot | /usr/bin/awk -F= '{print $2}' | sed "s#^${varwww_directory}${user_dir_short}##" | sed 's#(^[ \t])|([ \t]$)##'`			
			if [[ -z ${restore_files[${restore_files_count}]} ]]; then
					let "restore_files_count=restore_files_count-1"
					echo -e "There isn't catalog of site${fail_mes}"
				else
					echo -e "${restore_files[${restore_files_count}]} ${ok_mes}"
			fi
		else			
			let "restore_files_count=restore_files_count+1"
			restore_files[${restore_files_count}]="`${dirname0}/apacheconf_parcer.sh ${currentSite}  | sed 's#^"##' | sed 's#"$##' | sed "s#^${varwww_directory}${user_dir_short}##" | sed 's#(^[ \t])|([ \t]$)##'`"
			if [[ -z ${restore_files[${restore_files_count}]} ]]; then
					let "restore_files_count=restore_files_count-1"
					echo -e "There isn't catalog of site${fail_mes}"
				else
					echo -e "${restore_files[${restore_files_count}]} ${ok_mes}"
			fi
		fi
	done	
fi


if [[ "${restore_bases_count}" -eq 0 && "${restore_files_count}" -eq 0 ]] ; then
    echo -e "Nothing for restore ${fail_mes}"
    end_script
    exit 0
fi

if [[ ${operation_type} == "restore" ]]; then
  if [[ ${bases_flag} == 1 || ${allBases_flag} == 1 ]]; then
    #--------------------------------------------------------
    # Проверим наличие БД, в которые будет производиться импорт, чтобы при отсутствии даже не выкачивать их
    echo -e "Is bases exist:"
    for i in `seq 1 ${restore_bases_count}`
    do
	    echo -ne "\t${restore_bases[$i]}: "
	    existsFlag=0;
	    dbrootpass=`sudo dbroot.sh`
	    existsFlag=`mysql -u${mysqladmin} -p${dbrootpass} ${restore_bases[$i]} -e "show databases" | grep "^${restore_bases[$i]}$" | wc -l`
	    
	    if [[ -z ${existsFlag} ]]; then 
	      echo -e "There isn't base ${restore_bases[$i]}. Please create base from user's hosting panel and restart script ${fail_mes}"
	      end_script
	      exit 0
	    else 
	      echo -e "${ok_mes}"
	    fi	
    done
  fi
fi




