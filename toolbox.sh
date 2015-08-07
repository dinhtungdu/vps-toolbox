#!/bin/bash
get_owner_group() {
  if [ -d "$1" ]; then
    echo $(ls -lah $1 |  awk '{print $3,$4}'| sed -n -e 's/\ /:/' -e '2p')
  elif [ -f "$1" ]; then
    echo $(ls -lah $1 |  awk '{print $3,$4}'| sed 's/\ /:/')
  else
    echo "get_owner_group requires a valid directory or filename as an argument." >&2
    exit 1
  fi
}
# website=
cd /home/
ls -d *.*[a-z]/
echo -e "Input the website: \c "
read web

if [ ! -d "/home/$web" ]; then
  echo "Directory's not found!"; exit 1;
fi
owner=$(get_owner_group /home/$web/public_html)

echo -e "Choose action:"
echo -e "\t 1 - Update Wordpress"
echo -e "\t 2 - Update Wordpress + All Plugins"
echo -e "\t 3 - Update All Plugins"
echo -e "\t 4 - Install a plugin"
echo -e "\t 5 - Fix permission"
echo -e "----------------------"
echo -e "Your choice: \c"
read choice

if [ "$choice" -eq "1" ]; then
	cd /home/$web/public_html
	mv wp-config.php wp-content/
	mv robots.txt wp-content/
	mv wp-content/ ..
	rm -rf *
	wget https://wordpress.org/latest.zip
	unzip *.zip
	rm -rf wordpress/wp-content/
	mv wordpress/* .
	rm -rf wordpress/
	rm -f latest.zip
	mv ../wp-content/ .
	mv wp-content/robots.txt .
	mv wp-content/wp-config.php .
	chown -R $owner *
	find * -type d -print0 | xargs -0 chmod 0750
	find * -type f -print0 | xargs -0 chmod 0640
	find . -type f -name "wp-config.php" -exec chmod 400 {} \;
	echo -e "\n"
	echo -e "Done update Wordpress!"

elif [ "$choice" -eq "2" ]; then
	cd /home/$web/public_html
	mv wp-config.php wp-content/
	mv robots.txt wp-content/
	mv wp-content/ ..
	rm -rf *
	wget https://wordpress.org/latest.zip
	unzip *.zip
	rm -rf wordpress/wp-content/
	mv wordpress/* .
	rm -rf wordpress/
	rm -f latest.zip
	mv ../wp-content/ .
	mv wp-content/robots.txt .
	mv wp-content/wp-config.php .
	updatemsg="Update plugins status:\n"
	cd /home/$web/public_html/wp-content/plugins/
	chown -R $owner *
	for d in */ ; do
	    wget https://downloads.wordpress.org/plugin/${d%/}.zip
	    if [ -f ${d%/}.zip ]; then
	    	rm -rf ${d%/}
	    	unzip ${d%/}.zip
	    	rm -f ${d%/}.zip
	    	updatemsg="${updatemsg}${d%/} - ok\n"
	    else
	    	updatemsg="${updatemsg}${d%/} - notfound\n"
	    fi;
	done
	chown -R $owner *
	find * -type d -print0 | xargs -0 chmod 0750
	find * -type f -print0 | xargs -0 chmod 0640
	find . -type f -name "wp-config.php" -exec chmod 400 {} \;
	echo -e "\n"
	echo -e $updatemsg
	echo -e "\n"
	echo -e "Done update Wordpress + Plugins!"

elif [ "$choice" -eq "3" ]; then
	cd /home/$web/public_html/wp-content/plugins/
	chown -R $owner *
	for d in */ ; do
	    wget https://downloads.wordpress.org/plugin/${d%/}.zip
	    if [ -f ${d%/}.zip ]; then
	    	rm -rf ${d%/}
	    	unzip ${d%/}.zip
	    	rm -f ${d%/}.zip
	    	updatemsg="${updatemsg}${d%/} - ok\n"
	    else
	    	updatemsg="${updatemsg}${d%/} - notfound\n"
	    fi;
	done
	chown -R $owner *
	find * -type d -print0 | xargs -0 chmod 0750
	find * -type f -print0 | xargs -0 chmod 0640
	find . -type f -name "wp-config.php" -exec chmod 400 {} \;
	echo -e "\n"
	echo -e $updatemsg

elif [ "$choice" -eq "4" ]; then
	cd /home/$web/public_html/wp-content/plugins/
	echo -e "Choose action:"
	echo -e "\t 1 - Plugins from Wordpress.Org"
	echo -e "\t 2 - Plugins from custom URL"
	echo -e "----------------------"
	echo -e "Your choice: \c"
	read choice_4
	if [ "$choice_4" -eq "1" ]; then
		plug_exist="0"
		echo -e "Input the slug of plugin: \c"
		read plugin
		for d in */ ; do
			if [ "$plugin" = "$d" ]; then
				plug_exist="1"
			fi
		done
		if [ "$plug_exist" -eq "1" ]; then
			echo -e "Plguins exists!!!"
		else
			wget https://downloads.wordpress.org/plugin/${plugin}.zip
			unzip ${plugin}.zip
			rm -f ${plugin}.zip
			chown -R $owner $plugin
			chmod 750 $plugin
			find $plugin/* -type d -print0 | xargs -0 chmod 0750
			find $plugin/* -type f -print0 | xargs -0 chmod 0640
		fi
	elif [ "$choice_4" -eq "2" ]; then
		echo -e "Input the URL of plugin: \c"
		read plugin_url
		wget $plugin_url
		plugin_name=$(basename "$plugin")
		unzip ${plugin_name}.zip
		rm -f ${plugin_name}.zip
		chown -R $owner $plugin_name
		chmod 750 $plugin_name
		find $plugin_name/* -type d -print0 | xargs -0 chmod 0750
		find $plugin_name/* -type f -print0 | xargs -0 chmod 0640
	else
		echo -e "Wrong choice!"
	fi
elif [ "$choice" -eq "5" ]; then
	chmod 750 /home/$web/public_html
	find /home/$web/public_html/* -type d -print0 | xargs -0 chmod 0750
	find /home/$web/public_html/* -type f -print0 | xargs -0 chmod 0640
	if [ -f /home/$web/public_html/wp-config.php  ];
	then
	  chmod 400 /home/$web/public_html/wp-config.php
	elif [ -f /home/$web/public_html/library/config.php  ];
	then
	  chmod 400 /home/$web/public_html/library/config.php
	else
	  echo "Config file for this type of website hasn't added yet."
	fi
	chown -R $owner /home/$web/public_html/*
else
	echo -e "Wrong choice!"
fi