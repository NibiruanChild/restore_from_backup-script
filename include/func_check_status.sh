check_status()
{
if [ $# -gt 1 ] && [ $2 == 'strict' ]; then
	mode='strict'
else
	mode='loose'
fi

if [ $1 -eq 0 ]; then
	echo -e "$ok_mes"
	else
		if [ $mode == 'strict' ]; then
		echo -e "$fail_mes"
		end_script
		else
		echo -e "$error_mes"
		clean_flag=0
		end_script
		end_script
		fi
fi
}
