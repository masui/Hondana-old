dump:
	mysqldump -u root hondana > /tmp/hondana.mysqldump
load:
	scp hondana.org:/home/masui/hondana/db/backups/hondana.mysqldump /tmp/hondana.mysqldump
	mysql -u root hondana < /tmp/hondana.mysqldump

everything: load
	cd db; make

push:
	git push pitecan.com:/home/masui/git/hondana-sfc.git
	git push git@github.com:masui/Hondana.git

