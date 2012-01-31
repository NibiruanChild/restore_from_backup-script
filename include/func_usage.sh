# Показать помощь
usage() {

cat <<USAGE

Usage: $0 [ options [argument]]

-h, --help                
		- this helps		
-c, --no_clean				
		- will not delete all from temporary directory after restore
-u USER, --user USER
		- user's login (u1234567 or user_0001234567)		
-d DATE, --date	DATE
		- date of backup (2011-12-31)
OPERATION TYPE:
-r, --restore            
		- restore (default operation)		
-a, --put_archive         
		- archive and move to user's home (without restore)		
-A, --make_archive        
		- archive and save without move (without restore)
SUBJECTS:
-f /PATH/FILE, --file /PATH/FILE     
		- subject is \${USERHOMEDIR}/PATH/FILE		
-F, --all_files
		- subject is  all files of USER (equal "-f /")
-s DOMAIN, --site DOMAIN         
		- subject is  directory of site by DOMAIN (can't restore autosubdomains)		
-S, --all_sites           
		- subject is  all sites of USER (can't restore autosubdomains)
-b DBNAME, --base DBNAME
		- subject is  base DBNAME		
-B, --all_bases
		- subject is  all bases
EXAMPLE:
restore.sh	-u u1234567 -d 2011-10-09 -a -s site.ru -s forum.site.ru -b u1234567_default -b u1234567_forum
restore.sh	u1234567 2011-10-09 -A
USAGE
}
