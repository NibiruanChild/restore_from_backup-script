#--------------------------------------------------------
# Чистим за собой
end_script()
{

if [[ "${clean_flag}" == "1" && -d ~/${tmpBakDirName} && ! "`dirname ${tmpBakDirName}`/`basename ${tmpBakDirName}`" == "`dirname ~/`/`basename ~/`" ]] ; then	
	echo -n "Removing temporary files from ~/${tmpBakDirName}/: "
	if [[ `whoami` == "root" ]]; then
		chmod 777 -R ~/${tmpBakDirName} &> /dev/null
	else
		sudo /usr/local/bin/sup_exec chmod 777 -R ~/${tmpBakDirName} &> /dev/null
	fi
	rm -rf ~/${tmpBakDirName}/*
	check_status $? strict   
fi

rm -f /var/run/restore_script.pid

exit 0;

}

trap "end_script" KILL HUP INT TERM                 # чистим за собой, если процесс умер
