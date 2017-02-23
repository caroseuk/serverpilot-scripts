#!/bin/bash
# === Variables ===
red="\e[1;31m"
green="\e[32m"
blue="\e[34m"
normal="\e[0m"
error="${red}ERROR: ${normal}"

run_all=false
# === /Variables ===

# === Functions ===
function show_error()
{
  msg=$1
  printf "%b" "${error}${msg}\n"
  exit 1
}

function show_notice()
{
  msg=$1
  printf "%b" "${green}${msg}\n"
}

function show_info()
{
  msg=$1
  printf "%b" "${blue}${msg}\n"
}
# === /Functions ===

while [[ "$1" != "" ]]; do
  case $1 in
    -a | --all )
      shift
      run_all=true
      ;;
  esac
done

# Check script is being run as root
if [[ "$USER" != "root" ]]; then
  show_error "This script must be run as root"
fi

# === Get PHP Version ===
echo -n "What verion of PHP are you running? e.g. 5.6, 7.0, 7.1: "
read php_version
if [ -n "$php_version" ]; then
  echo "PHP Version: $php_version"
elif [ ! -n "$php_version" ]; then
  show_error "You must supply a PHP version."
fi
# === /Get PHP Version ===

# === LEMP Stack ===
if [[ ! $run_all ]]; then
  echo -n "Create LEMP Stack (Nginx Only, No Apache)? (y/n): "
  read lemp
fi

if [ "$lemp" = "y" ] || [ $run_all = true ]; then
  show_notice "Creating LEMP Stack..."
  show_notice "Finished Creating LEMP Stack..."
fi
# === /LEMP Stack ===

# === Imagick ===
if [[ ! $run_all ]]; then
  echo -n "Install Imagick? (y/n): "
  read imagick
fi

if [ "$imagick" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing Imagick..."
  show_info "When asked for a prefix simply press enter."
  
  show_info "Installing Pacakges..."
  apt-get install gcc make autoconf libc-dev pkg-config
  apt-get install libmagickwand-dev
  
  show_info "Pecl Installing Imagick..."
  (eval "pecl${php_version}-sp install imagick")
  
  show_info "Enabling Imagick Extension..."
  bash -c "echo extension=imagick.so > /etc/phpX.Y-sp/conf.d/imagick.ini"
  
  show_info "Restarting PHP FPM..."
  (eval "service php${php_version}-fpm-sp restart")
  
  show_notice "Finished Installing Imagick..."
fi
# === /Imagick ===

# === AutoMySQLBackup ===
if [[ ! $run_all ]]; then
  echo -n "Install AutoMySQLBackup? (y/n): "
  read automysqlbackup
fi

if [ "$automysqlbackup" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing AutoMySQLBackup..."
  
  apt-get install automysqlbackup
  
  show_notice "Finished Installing AutoMySQLBackup..."
fi
# === /AutoMySQLBackup ===

# === Disable MySQL 5.7 Strict Mode ===
if [[ ! $run_all ]]; then
  echo -n "Disable MySQL Strict Mode? (y/n): "
  read mysql_strict
fi

if [ "$mysql_strict" = "y" ] || [ $run_all = true ]; then
  show_notice "Disabling MySQL Strict Mode..."
  
  if [ -e /etc/mysql/conf.d/disable_strict_mode.cnf ]; then
    show_info "Disable strict mode config already exists"
  else
    show_info "Creating file..."
    touch /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Adding config..."
    printf "[mysqld]\nsql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\n" > /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Restarting MySql..."
    service mysql restart
  fi
  
  show_notice "Finished Disabling MySQL Strict Mode..."
fi
# === /Disable MySQL 5.7 Strict Mode ===