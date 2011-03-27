dump:
	mysqldump -u root hondana > /tmp/hondana.mysqldump
load:
	mysql -u root hondana < /tmp/hondana.mysqldump

push:
	git push pitecan.com:/home/masui/git/hondana-sfc.git
	git push git@github.com:masui/Hondana.git


