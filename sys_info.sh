#!/bin/bash

#Exits the script if user is not root
if [ $UID -ne 0 ]; then
  echo "Please run this script as root."
  exit
fi

#Define variables
output=$HOME/research/sys_info.txt
ip=$(ip addr | grep inet | tail -2 | head -1)
execs=$(sudo find /home -type f -perm 777 2>/dev/null)
cpu=$(lscpu | grep CPU)
disk=$(df -H | head -2)

#Define lists
commands=(
  'date'
  'uname -a'
  'hostname -s'
)

files=(
  '/etc/passwd'
  '/etc/shadow'
)

#Create research directory if there is not one
if [ ! -d $HOME/research ]; then
  mkdir $HOME/research
fi

# Clears output file
if [ -f $output ]; then
  >$output
fi

#Script starts here

echo "A Quick System Audit Script" >>$output
echo "" >>$output

for x in {0..2}; do
  results=$(${commands[$x]})
  echo "Results of "${commands[$x]}" command:" >>$output
  echo $results >>$output
  echo "" >>$output
done

#Machine type
echo "Machine Type Info:" >>$output
echo -e "$MACHTYPE \n" >>$output

#IP Address info
echo -e "IP Info:" >>$output
echo -e "$ip \n" >>$output

#Memory usage
echo -e "\nMemory Info:" >>$output
free >>$output

#CPU usage
echo -e "\nCPU Info:" >>$output
lscpu | grep CPU >>$output

#Disk usage
echo -e "\nDisk Usage:" >>$output
df -H | head -2 >>$output

#Current user
echo -e "\nCurrent user login information: \n $(who -a) \n" >>$output

#DNS Info
echo "DNS Servers: " >>$output
cat /etc/resolv.conf >>$output

# List exec files
echo -e "\nexec Files:" >>$output
for exec in $execs; do
  echo $exec >>$output
done

#Top 10 processes
echo -e "\nTop 10 Processes" >>$output
ps aux --sort -%mem | awk {'print $1, $2, $3, $4, $11'} | head >>$output

#Check file permissions
echo -e "\nThe permissions for sensitive /etc files: \n" >>$output
for file in ${files[@]}; do
  ls -l $file >>$output
done
