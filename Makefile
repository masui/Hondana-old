dump:
	mysqldump -u root hondana > /tmp/hondana.mysqldump
load:
	mysql -u root hondana < /tmp/hondana.mysqldump
