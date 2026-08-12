#!/usr/bin/env bash

#Note: If you are using "finder.dd" to test this script, remove the # from checkuser function in the last lines of this script as "finder.dd" is not root. This script was meant to run when the file is root."

echo "This script is for Q2. Create a bash script that Automates HDD and Memory File Carving."
echo "Note: For the sake of this project, we will be using finder.dd for everything & file.mem for Q2.6 from Cyberium Lab Automatic Carving."
echo "Note: For this script, sudo will be used for package installations as the files "finder.dd" & "file.mem" are not root, although it was meant to only run completely if it is root"
echo ""
echo "Downloading memory files..."

if [ ! -f "finder.dd" ]; then
	wget "https://cyberiumarena.com/lab/nx212/finder.dd" >/dev/null 2>&1
fi
if [ ! -f "file.mem" ]; then
	wget "https://cyberiumarena.com/lab/nx212/file_mem1.zip" >/dev/null 2>&1
	unzip -o file_mem1.zip
	rm -f file_mem1.zip
fi
 
#2.1 Check the current user; exit if not 'root'.
echo "Reminder: Remove # from checkuser function if file is root."
checkuser()																#Function to check current user
{
	if [[ $EUID != 0 ]]; then											#If current user represented by $EUID is not root
	echo "The current user is not root."								#This error message will appear
	exit 1																#The script exits due to failure
	fi
}

#2.2 Allow the user to specify the filename; check if the file exists
checkfile()																#Function to check if the file exists
{
	read -p "Please specify filename (finder.dd, file.mem for 2.6): " file							#Prompts user to specify the filename to check its existence
	if [[ -f "$file" ]]; then											#Checks if file is present
	echo "$file found!"													#Displays the name of the file specified as found
	
	else																#Otherwise
	echo "$file is not a valid file."									#Filename specified is not a valid file
	exit 1																#Once file is invalid, the entire script ends here
	fi
}

#2.3 Create a function to install the forensics tools if missing
#This question is with reference to the sample presented by Tushar in Notion, with minor tweaks of my own
tools=(foremost bulk_extractor binwalk)									#With reference from Notion sample, this represents as arrays containing the required forensic tools to be installed
missing_tools=()														#Empty array used to store the missing tools

checktools()															#Function to check if tools are installed
{
	for tool in "${tools[@]}"; do										#Loops through every tool stored in 'tools' array
		command -v "$tool" &> /dev/null									#Checks if each tool exists, then suppresses the error message for tidiness
		ERR_CODE=$(echo $?)												#Stores the error code of the previous command. 0 = tool found, non-0 = tool not found
	if [[ "$ERR_CODE" -ne 0 ]]; then									#If the error code is not equals to 0, the tool is missing
		echo "$tool is missing"											#Then displays a message informing the user that the tool is missing
		missing_tools+=($tool)											#Adds the missing tool to the "missing_tools' array
	else
		echo "$tool is already installed"								#Otherwise, the tool is already installed and displays the message
	fi
	done																#End of for loop
	checkinstall														#Calls the checkinstall function to install any missing tools
}

checkinstall()															#Function to check installation of tools
{
	sudo apt update -y &> /dev/null										#Update first, in case tool package is an older version resulting in error, which occurred before
	for tool in "${missing_tools[@]}"; do								#For every tool that is missing, case will select the right option to install it
	case "$tool" in														#Whatever tool that shows up in $tool, case will compare it and execute the matching installation command
		foremost)														#If missing tool is "foremost", installs the foremost package
			sudo apt install foremost -y
			echo "Foremost tool is installed."
			;;
		bulk_extractor)													#If missing tool is "bulk extractor", installs the bulk-extractor package
			sudo apt install bulk-extractor -y
			echo "Bulk-extractor tool is installed."
			;;
		binwalk)														#If missing tool is "binwalk", installs the binwalk package
			sudo apt install binwalk -y
			echo "Binwalk tool is installed."
			;;
	esac																#End of case statement

done																	#End of for loop

echo ""
}

#2.4 Use different carvers to automatically extract data
#2.5 Data should be saved into a directory
mkdir -p "carvedoutput/$file"											#A new directory is created to save all the data in it

carveddata()															#Function to choose and execute carver
{
	echo "Extraction of data using different carvers..."
	
	echo "Please select a carver: "										#A multiple choice scenario to allow user to select his choice
	echo "1. Foremost"
	echo "2. Bulk Extractor"
	echo "3. Binwalk"
	
	read -p "Enter your choice (1-3): " choice							#When option is selected, 1,2 or 3, variable "choice" will be assigned for case statement
	
	case "$choice" in													#Case statement with the variable choice remembering the option chosen before
	1)
		echo ""
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		mkdir -p "carvedoutput/$file/foremost_output"
		foremost -i "$file" -o carvedoutput/$file/foremost_output &> /dev/null		#Foremost tool executed. Input is the $file, output is foremost_output inside carvedoutput directory
		echo "Foremost extraction completed."
		;;
	2)
		echo ""
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		mkdir -p "carvedoutput/$file/bulkextractor_output"
		bulk_extractor -o carvedoutput/$file/bulkextractor_output "$file"  &> /dev/null	#Bulk Extractor tool executed. Input is the $file, output is bulkextractor_output inside carvedoutput directory
		echo "Bulk extractor completed."
		;;
	3)
		echo ""
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		cd carvedoutput/"$file"
		binwalk -e "../../$file" &> /dev/null							#Binwalk tool executed
		cd ..
		echo "Binwalk extraction completed."
		;;
	*)
		echo "Invalid choice."
		;;
	esac
}

#2.6 Attempt to extract network traffic; if found, display to the user the location and size
#Note: Use file.mem
networktraffic()														#Function to detect and locate file with network traffic
{
	echo "Attempting to extract network traffic..."
	
	pcap1=$(find carvedoutput -type f -iname "*.pcap")					#Searching for .pcap file assigned to pcap1 as variable
	pcap2=$(find carvedoutput -type f -iname "*.pcapng")				#Searching for .pcapng file assigned to pcap2 as variable
	
	if [[ -n "$pcap1" || -n "$pcap2" ]]; then							#If else statement to check if .pcap from pcap1 and .pcapng from pcap2 exist within the extracted outputs
		pcap="$pcap1 $pcap2"											#Assigned both variables together for convenience
		echo "Network traffic detected!"								#When if statement is fulfilled, this message will be displayed
		echo "Size	Location: $(du -sh $pcap)"							#Once if statement fulfilled, this line is able to detect the file size and its location
	else
		echo "No network traffic detected."								#Otherwise, non detected
	fi
}

#2.7 Check for human-readable (exe files, passwords, usernames, IP Address, Emails, Darkweb activity etc.). 
checkhumanreadable()
{
	echo "Checking for human-readables..."
	
	find carvedoutput -type f -exec grep -i "\.exe"  strings {} + 2> /dev/null > exe.txt													#Searches for every possible .exe file and store them
	find carvedoutput -type f -exec grep -i "password"  strings {} + 2> /dev/null > passwords.txt											#Searches for every possible password and store them
	find carvedoutput -type f -exec grep -i "username"  strings {} + 2> /dev/null > usernames.txt											#Searches for every possible usernames and store them
	find carvedoutput -type f -exec grep -E "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"  strings {} + 2> /dev/null > ip.txt	#Searches for every possible IP address and store them
	find carvedoutput -type f -exec grep -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}"  strings {} + 2> /dev/null > emails.txt			#Searches for every possible emails and store them
	find carvedoutput -type f -exec grep -Ei "onion|darkweb|tor"  strings {} + 2> /dev/null > darkweb.txt									#Searches for every possible darkwebs and store them
	
	echo "EXE Files found: $(wc -l < exe.txt)"							#Uses word count to count the number of lines and display it in terminal
	echo "Passwords found: $(wc -l < passwords.txt)"					#Uses word count to count the number of lines and display it in terminal
	echo "Usernames found: $(wc -l < usernames.txt)"					#Uses word count to count the number of lines and display it in terminal
	echo "IP Addresses found: $(wc -l < ip.txt)"						#Uses word count to count the number of lines and display it in terminal
	echo "Emails found: $(wc -l < emails.txt)"							#Uses word count to count the number of lines and display it in terminal
	echo "Darkweb activities found: $(wc -l < darkweb.txt)"				#Uses word count to count the number of lines and display it in terminal
	
	echo "Search completed."
}	
#checkuser
checkfile
echo ""
checktools
echo ""
carveddata
echo ""
networktraffic
echo ""
checkhumanreadable
