#!/bin/bash

# @author Lukovkin Petr
# @email p.lukovkin@reg.ru
# @description restore files with rsync

source `dirname $0`/include/func_usage.sh           # функция, выводящая usage

SCRIPT_VERSION=2.6.1

# include files
script_name=`basename $0`
script_dir=`dirname $0`
dirname0=`dirname $0`	

if [ -f /var/run/restore_script.pid ];then
  echo "Sсript is running already (pid: `echo -n`). Please wait."
fi
if [[ ${WHOAMI} == "root" ]]; then
  echo $$>/var/run/restore_script.pid
fi


# usage, если запущен без параметров
if [[ "$#" -eq 0 ]]; then
    usage
    clean_flag=0
    end_script
    exit 0
fi

source `dirname $0`/include/func_check_status.sh    # функция проверки результата выполнения последней команды
source `dirname $0`/include/defines.sh              # определение переменных
source `dirname $0`/include/func_end_script.sh      # функция окончания скрипта
source `dirname $0`/include/check_files.sh          # проверяем наличие необходимых файлов и каталогов
source `dirname $0`/include/argument_parcing.sh     # парсим аргументы скрипта
source `dirname $0`/include/execute_operation.sh    # собственно само восстановление/архив

#--------------------------------------------------------
# Посмертные действия
end_script

