#!/bin/bash
# AWStats Installation Script
# Date: 16th of July, 2014
# Version 1.0
#
# Author: John McCarthy
# Email: midactsmystery@gmail.com
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
######## VARIABLES ########
prefix=/usr/share/doc/awstats/examples
zlib_ver=1.2.8
# http://cosminswiki.info/index.php/Installing_Awstats_for_Apache2_on_Debian
# http://webdevwonders.com/how-to-install-automate-and-secure-awstats-including-geoip-plugin-on-debian/
function install_apache2(){
	# Updates repos and installs Apache2
		echo
		echo -e '\e[34;01m+++ Installing Apache2...\e[0m'
		apt-get update
		apt-get -y install apache2
		echo -e '\e[01;37;42mApache2 has been successfully installed!\e[0m'
}
function install_awstats(){
	# Installing AWStats
		echo
		echo -e '\e[34;01m+++ Installing AWStats...\e[0m'
		apt-get -y install awstats
		echo -e '\e[01;37;42mAWStats has been successfully installed!\e[0m'

	# Unzips the default awstats.conf file
		cd $prefix
		gunzip $prefix/awstats.model.conf.gz

	# Configures the awstats_configure.pl file
		echo
		echo -e '\e[34;01m+++ Configuring the awstats_configure.pl file...\e[0m'
		sed -i "/\$AWSTATS_PATH='/c\$AWSTATS_PATH='/usr/share/awstats';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_ICON_PATH='/c\$AWSTATS_ICON_PATH='/usr/share/awstats/icon';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_CSS_PATH='/c\$AWSTATS_CSS_PATH='/usr/share/awstats/css';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_CLASSES_PATH='/c\$AWSTATS_CLASSES_PATH='/usr/share/awstats/lib';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_CGI_PATH='/c\$AWSTATS_CGI_PATH='/usr/lib/cgi-bin';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_MODEL_CONFIG='/c\$AWSTATS_MODEL_CONFIG='/usr/share/doc/awstats/examples/awstats.model.conf';" $prefix/awstats_configure.pl
		sed -i "/\$AWSTATS_DIRDATA_PATH='/c\$AWSTATS_DIRDATA_PATH='/var/lib/awstats';" $prefix/awstats_configure.pl
		sed -i '/if (! -s $modelfile ||/c\                if (! -s $modelfile || ! -w $modelfile) { $modelfile="$AWSTATS_MODEL_CONFIG"; }' $prefix/awstats_configure.pl

	# Sets permissions on the awstats.pl file
		chown www-data /usr/lib/cgi-bin/awstats.pl

	# Sets permissions on the /var/log/apache2 directory
		chown root:www-data -R /var/log/apache2
		chmod 755 /var/log/apache2
		echo -e '\e[01;37;42mAWStats has been successfully configured!\e[0m'

	# Stores the IP or hostname of the site in the $host variable
		echo
		echo -e "\e[33mWhat is that IP or hostname of your website's domain ?\e[0m"
		echo -e '\e[33;01mFor Example:  192.168.1.1 or www.example.com\e[0m'
		read host

	# Runs the awstats_configure.pl file
		echo
		echo -e '\e[01;34m+++ Initializing the awstats_configure.pl file...\e[0m'
		echo "-------------------------------------------------"
		sleep 1
		echo -e '\e[33mUse these as a guide to help answer the following questions: \e[0m'
		echo
		echo -e '\e[33;01my\e[0m'
		echo -e '\e[33;01m/etc/apache2/apache2.conf\e[0m'
		echo -e '\e[33;01my\e[0m'
		echo -e '\e[33;01mYour IP/hostname\e[0m'
		echo -e '\e[33;01mHit ENTER (x3)\e[0m'
		sleep 4
		echo
		echo -e '\e[97mHere\e[0m'
		sleep .5
		echo -e '\e[97mWe\e[0m'
		sleep .5
		echo -e '\e[01;97;42mG O  ! ! ! !\e[0m'
		perl $prefix/awstats_configure.pl
		echo -e '\e[01;37;42mThe awstats_configure.pl file has been successfully completed!\e[0m'

	# Configures the /etc/awstats/awstats.conf file
		echo
		echo -e '\e[34;01m+++ Configuring the /etc/awstats/awstats.conf and host file...\e[0m'
		sed -i '/^LogFile="/c\LogFile="/var/log/apache2/access.log"' /etc/awstats/awstats.conf
		sed -i '/^LogFormat/c\LogFormat=1' /etc/awstats/awstats.conf
		sed -i '/SiteDomain=""/c\SiteDomain="'"$host"'"' /etc/awstats/awstats.conf
		sed -i '/^DNSLookup=/c\DNSLookup=0' /etc/awstats/awstats.conf

	# Configures the /etc/awstats/awstats.$host.conf file
		sed -i '/^LogFile="/c\LogFile="/var/log/apache2/access.log"' /etc/awstats/awstats.$host.conf
		sed -i '/^LogFormat/c\LogFormat=1' /etc/awstats/awstats.$host.conf
		sed -i '/SiteDomain=""/c\SiteDomain="'"$host"'"' /etc/awstats/awstats.$host.conf
		sed -i '/^DNSLookup=/c\DNSLookup=0' /etc/awstats/awstats.$host.conf
		echo -e '\e[01;37;42mThe /etc/awstats/awstats.conf and host file have been successfully configured!\e[0m'

	# Gets the number of lines in the /etc/apache2/apache2.conf file
		echo
		echo -e '\e[01;34m+++ Editing the /etc/apache2/apache2.conf and\e[0m'
		lines=$(wc -l /etc/apache2/apache2.conf)

	# Stores the number from the $lines variable in the $number variable
		number=$(echo "${lines%%[[:space:]]*}")

	# Gets the line number to start deleting lines from
		start=`expr $number - 17`

	# Deletes the unneeded lines
		sed -i ''"$start"','"$number"'d' /etc/apache2/apache2.conf

	# Edits the /etc/apache2/apache2.conf file
		cat <<EOB >> /etc/apache2/apache2.conf
Alias /awstatsicons/ /usr/share/awstats/icon/
<Directory /usr/share/awstats/icon>
    Options None
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
EOB

	# Creates the /etc/apache2/conf.d/statistics file for awstats
		cat <<EOC >> /etc/apache2/conf.d/statistics
Alias /awstatsclasses "/usr/share/awstats/lib/"
Alias /awstatscss "/usr/share/doc/awstats/examples/css"
ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
ScriptAlias /statistics/ /usr/lib/cgi-bin/
Options ExecCGI -MultiViews +SymLinksIfOwnerMatch
EOC
		echo -e '\e[01;37;42mThe apache files have been successfully edited!\e[0m'

	# Restarts the apache2 service
		echo
		echo -e '\e[01;34m+++ Restarting the apache2 service\e[0m'
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been successfully restarted!\e[0m'

	# Runs the awstats.pl file
		echo
		echo -e '\e[01;34m+++ Running the awstats.pl file\e[0m'
		/usr/lib/cgi-bin/awstats.pl -config=$host -update
		echo -e '\e[01;37;42mThe awstats.pl has been successfully run!\e[0m'
}
function setup_cronjob(){
	# Checks to see if the $host variable is set
		if [[ -z "$host" ]]; then
			echo
			echo -e "\e[33mWhat is that IP or hostname of your website's domain ?\e[0m"
			echo -e '\e[33;01mFor Example:  192.168.1.1 or www.example.com\e[0m'
			read host
		fi

	# Creates the cronjob to auto update AWStats
		echo
		echo -e '\e[01;34m+++ Creating the AWStats cronjob\e[0m'
		cat <<EOD >> /var/spool/cron/crontabs/www-data
*/15 * * * * /usr/lib/cgi-bin/awstats.pl -config=$host -update
EOD
		echo -e '\e[01;37;42mThe awstats cronjob has been successfully created!\e[0m'
}
function setup_htaccess(){
	# Creates the .htaccess file to secure AWStats
		echo
		echo -e '\e[01;34m+++ Creating the .htaccess and .htpasswd files\e[0m'
		cat << EOE > /usr/lib/cgi-bin/.htaccess
<FilesMatch "awstats.pl">
    AuthName "Login Required"
    AuthType Basic
    AuthUserFile /etc/awstats/.htpasswd
    require valid-user
</FilesMatch>
EOE

	# Stores the username in the $username variable
		echo -e '\e[33mPlease select a \e[01;33musername\e[0m \e[33mto login and check your awstats statistics:\e[0m'
		read username

	# Creates the .htpasswd file
		echo
		echo -e '\e[33mPlease select a \e[01;33mpassword\e[0m \e[33mfor this user:\e[0m'
		htpasswd -c /etc/awstats/.htpasswd $username
		echo -e '\e[01;37;42mThe .htaccess and .htpasswd files have been successfully created!\e[0m'

	# Edits the /etc/apache2/sites-available/default file to allow overrides
		echo
		echo -e '\e[01;34m+++ Editing the /etc/apache2/sites-available/default file\e[0m'
		sed -i '/<Directory "\/usr\/lib\/cgi-bin">/{ N; s/<Directory "\/usr\/lib\/cgi-bin">\n[[:space:]]*AllowOverride None/<Directory "\/usr\/lib\/cgi-bin">\n                AllowOverride All/ }' /etc/apache2/sites-available/default
		echo -e '\e[01;37;42mThe /etc/apache2/sites-available/default has been successfully edited!\e[0m'

	# Restarts the apache2 service
		echo
		echo -e '\e[01;34m+++ Restarting the apache2 service\e[0m'
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been successfully restarted!\e[0m'
}
function install_GeoIP(){
	# Checks to see if the $host variable is set
		if [[ -z "$host" ]]; then
			echo
			echo -e "\e[33mWhat is that IP or hostname of your website's domain ?\e[0m"
			echo -e '\e[33;01mFor Example:  192.168.1.1 or www.example.com\e[0m'
			read host
		fi

	# Installs the prerequisite packages
		echo
		echo -e '\e[34;01m+++ Installing Required Packages...\e[0m'
		apt-get -y install build-essential zlib1g-dev
		echo -e '\e[01;37;42mThe required packages have been successfully installed!\e[0m'

	# Installs zlib
		echo
		echo -e '\e[34;01m+++ Installing Zlib...\e[0m'
		cd
		wget http://zlib.net/zlib-$zlib_ver.tar.gz
		tar xvzf zlib-$zlib_ver.tar.gz
		cd zlib-$zlib_ver
		./configure --prefix=/usr/local/zlib && make && make install
		echo -e '\e[01;37;42mZlib has been successfully installed!\e[0m'

	# Installs GeoIP
		echo
		echo -e '\e[34;01m+++ Installing GeoIP...\e[0m'
		cd
		wget http://maxmind.com/download/geoip/api/c/GeoIP.tar.gz
		tar xzvf GeoIP.tar.gz
		cd GeoIP*
		./configure && make && make install
		echo -e '\e[01;37;42mGeoIP has been successfully installed!\e[0m'

	# Edits the /etc/awstats/awstats.$host.conf file
		echo
		echo -e '\e[34;01m+++ Configuring the awstats.conf file...\e[0m'
		sed -i '/#LoadPlugin="geoip GEOIP_STANDARD/c\LoadPlugin="geoip GEOIP_STANDARD \/usr\/local\/share\/GeoIP\/GeoIP.dat"' /etc/awstats/awstats.$host.conf
		echo -e '\e[01;37;42mThe awstats.conf file has been successfully configured!\e[0m'

	# Runs the cpan configuration
		clear
		echo
		echo -e '\e[34;01m+++ Running cpan...\e[0m'
		echo "-------------------------------------"
		sleep 1
		echo -e '\e[33mPlease do the following to correctly proceed with the installation: \e[0m'
		echo
		echo -e "\e[33;01mAnswer [yes] to the two cpan questions by hitting `tput smul`ENTER (x2)`tput rmul`\e[0m"
		echo
		echo -e '\e[33mAt the span shell, run the following commands:\e[0m'
		echo
		echo -e '\e[33;01minstall YAML\e[0m'
		echo -e '\e[33;01minstall Geo::IP Geo::IPfree Geo::IP::PurePerl URI::Escape Net::IP Net::DNS Net::XWhois Time::HiRes Time::Local\e[0m'
		echo
		echo -e '\e[33mtype "\e[33;01mquit\e[0m\e[33m" after the final installation to continue with the AWStat installation script.\e[0m'
		sleep 4
		echo
		echo -e '\e[97mHere\e[0m'
		sleep .5
		echo -e '\e[97mWe\e[0m'
		sleep .5
		echo -e '\e[01;97;42mG O  ! ! ! !\e[0m'
		cpan
		echo -e '\e[01;37;42mcpan has been successfully ran!\e[0m'

	# Restarts the apache2 service
		echo
		echo -e '\e[01;34m+++ Restarting the apache2 service\e[0m'
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been successfully restarted!\e[0m'
}
function install_GeoCity(){
	# Checks to see if the $host variable is set
		if [[ -z "$host" ]]; then
			echo
			echo -e "\e[33mWhat is that IP or hostname of your website's domain ?\e[0m"
			echo -e '\e[33;01mFor Example:  192.168.1.1 or www.example.com\e[0m'
			read host
		fi

	# Installs GeoLiteCity
		echo
		echo -e '\e[34;01m+++ Setting up GeoLiteCity...\e[0m'
		cd
		wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
		gzip -d GeoLiteCity.dat.gz
		cp GeoLiteCity.dat /usr/local/share/GeoIP/GeoLiteCity.dat

	# Edits the awstats.conf file
		sed -i '/#LoadPlugin="geoip_city_/c\LoadPlugin="geoip_city_maxmind GEOIP_STANDARD /usr/local/share/GeoIP/GeoLiteCity.dat"' /etc/awstats/awstats.$host.conf
		echo -e '\e[01;37;42mGeoLiteCity has been successfully installed!\e[0m'

		echo -e '\e[01;34m+++ Restarting the apache2 service\e[0m'
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been successfully restarted!\e[0m'
}
function doAll(){
	# Calls Function 'install_apache2'
		echo
		echo
		echo -e "\e[33m=== Install Apache2 ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_apache2
		fi

	# Calls Function 'install_awstats'
		echo
		echo -e "\e[33m=== Install AWStats ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_awstats
		fi

	# Calls Function 'setup_cronjob'
		echo
		echo -e "\e[33m=== Setup a cronjob to automatically update AWStats ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			setup_cronjob
		fi

	# Calls Function 'setup_htaccess'
		echo
		echo -e "\e[33m=== Secure access to AWStats with a .htaccess file ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			setup_htaccess
		fi

	# Calls Function 'install_GeoIP'
		echo
		echo -e "\e[33m=== Install GeoIP ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_GeoIP
		fi

	# Calls Function 'install_GeoCIty'
		echo
		echo -e "\e[33m=== Install GeoCity ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			install_GeoCity
		fi

	# End of Script Congratulations, Farewell and Additional Information
		clear
		FARE=$(cat << EOZ


           \e[01;37;42mWell done! You have completed your AWStats Installation! \e[0m

     \e[34;01mBrowse to this link to login and check out your AWStats installation:\e[0m
            \e[39;01mhttp://$host/cgi-bin/awstats.pl?config=$host\e[0m

  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
EOZ
)

		#Calls the End of Script variable
		echo -e "$FARE"
		echo
		echo
		exit 0
}

# Check privileges
	[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	clear
	welcome=$(cat << EOA


                 \e[01;37;42mWelcome to Midacts Mystery's AWStats Installer!\e[0m


EOA
)

# Calls the welcome variable
	echo -e "$welcome"

# Calls the doAll function
	case "$go" in
		* )
			doAll ;;
	esac

exit 0
