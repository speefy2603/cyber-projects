#!/bin/bash

echo "This script is for Scope 1. Automate Memory Analysis with Bash Script."
echo ""
echo "Tip: Please insert memory file into the same folder as project7.sh script"
echo "For the sake of this project, we will be using m4.vmem from Memory Analysis Cyberium Lab QE1 & memdump.mem from Q3"
echo "==============================IMPORTANT: PLEASE HAVE volatility3 & VENV FOLDERS IN THE SAME DIRECTORY AS THIS .sh FILE=============================="
echo "There was too much issue downloading them in this script and their files are too big to submit together."
echo ""

echo "Downloading memory files & Volatility2..."
if [ ! -f "memdump.mem" ]; then
	if [ ! -f "memdump.zip" ]; then
		wget "https://cyberiumarena.com/lab/nx212/memdump.zip" >/dev/null 2>&1
	fi
	unzip -oq memdump.zip
	unzip -oq memory_file.zip
	unzip -oq Volatililty_for_Linux.zip
	
	rm -f memory_file.zip
	rm -f memdump.zip
	rm -f Volatililty_for_Linux.zip
	rm -f volRef.pdf
fi

if [ ! -f "m4.vmem" ]; then
    if [ ! -f "vol3_files.zip" ]; then
        wget "https://cyberium.s3.eu-central-1.amazonaws.com/Files/vol3_files.zip" >/dev/null 2>&1
    fi
    unzip -oq vol3_files.zip m4.vmem
    rm -f vol3_files.zip
fi
echo ""

#1.1 Check if the file can be analysed in Volatility; if yes, let the user choose to run Volatility2 or Volatility3.
echo "-----Memory Analysis Automation-----"															#Title
read -p "Enter memory file (memdump.mem for Volatility2, m4.vmem for Volatility3): " memoryfile		#Prompts the user to enter a valid memory file to proceed with the tool
if [ ! -f "$memoryfile" ]; then																		#Checks if the memory file exists
	echo "File does not exist."
	exit 1	
fi
echo "File found."														#Memory file used will be "memdump.mem in the same folder. If "memdump.mem" is keyed in, the message in this line will show
echo ""

echo "Please select Volatility Version: "								#Display version selection menu
echo "1. Volatility2"													#Shows Volatility2 as option 1
echo "2. Volatility3"													#Shows Volatility3 as option 2
read -p "Selection: " choice											#Operates as a prompt for the user to key in with -p flag

echo ""
case $choice in															#Use of case statement to validate user's selection
	1)																	#Option 1
		echo "Running Volatility2..."									#If option 1 selected, this will be displayed
#1.2.1 Find the memory profile and save it into a variable. (Only for Volatility2)
		echo ""
		echo "Finding memory profile..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		v2profile=$(./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" imageinfo | grep "Suggested Profile(s)" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d ' ')
		echo "Detected Profile: $v2profile"								#This line and the line above extracts the profile after running the imageinfo flag for Volatility2, then stores into v2profile
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.2 Extract the Process Information into a file and Display the running processes
		echo ""
		echo "Extracting Process Information..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" pslist > pslist1.txt	#Extracts the Process Information
		cat pslist1.txt													#Displays the content produced by Volatility2 pslist flag which was inserted into pslist.txt
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.3 Extract the Network Connections into a file and Display network connections.
		echo ""
		echo "Extracting Network Connections..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" connections > connections.txt	#Extracts the Network Connections and stores into a file
		cat connections.txt												#Displays the content produced by Volatility2 connections flag, which was inserted into connections.txt
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.4 Extract the Commands Executed into a file and Display the commands.
		echo ""
		echo "Extracting Commands Executed..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" cmdline > cmdline1.txt	#Extracts the Commands Executed and stores into a file
		cat cmdline1.txt												#Displays the content produced by Volatiltiy2 cmdline flag, which was inserted into cmdline1.txt
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.5 Extract the Dll List into a file
		echo ""
		echo "Extracting the Dll List..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" dlllist > dlllist1.txt	#Extracts the Dll List and stores into a file
		echo ""
		echo "The Dll List has been stored into a file, "dlllist1.txt"."	#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.6 Extract hashes into a file and Display the hashes.
		echo ""
		echo "Extracting hashes..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" hashdump > hashdump1.txt	#Extracts the hashes and stores into a file
		cat hashdump1.txt												#Displays the content produced by Volatiltiy2 hashdump flag, which was inserted into hashdump1.txt
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.7 Extract the Registry Information into a file
		echo ""
		echo "Extracting Registry Information..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" hivelist > hivelist1.txt	#Extracts the registry information and stores into a file
		echo "The Registry Information has been stored into a file, "hivelist1.txt"."	#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.8 Extract the SIDs into a file
		echo ""
		echo "Extracting the SIDs..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		./volatility_2.5.linux.standalone/volatility_2.5_linux_x64 -f "$memoryfile" --profile="$v2profile" getsids > sid1.txt	#Extracts the SIDs and stores into a file
		echo "The SIDs have been stored into a file, "sid1.txt"."		#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		;;																
	2)																	#Option 2
		echo "Running Volatility3..."									#If option 2 selected, this will be displayed
#1.2.2 Extract the Process Information into a file and Display the running processes
		echo ""
		echo "Extracting Process Information..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.pslist.PsList > pslist2.txt		#With the usage of pslist flag for Volatility3, extracts all process information like task manager & stores into a file
		cat pslist2.txt													#Displays the information stored in the file
		deactivate
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.3 Extract the Network Connections into a file and Display network connections.
		echo ""
		echo "Extracting Network Connections..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.netscan.NetScan > netscan.txt		#With the usage of netscan.NetScan flag for Volatility3, extracts all network connections & stores into a file
		cat netscan.txt													#Displays the network connections stored in the file
		deactivate
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.4 Extract the Commands Executed into a file and Display the commands.
		echo ""
		echo "Extracting Commands Executed..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.cmdline.CmdLine > cmdline2.txt		#With the usage of cmdline.CmdLine flag for Volatility3, extracts all commands executed & stores into a file
		cat cmdline2.txt												#Displays the commands executed stored in the file
		deactivate
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.5 Extract the Dll List into a file
		echo ""
		echo "Extracting the Dll List..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.dlllist.DllList > dlllist2.txt		#With the usage of dlllist.DllList flag for Volatility3, extracts the Dll List & stores into a file
		deactivate
		echo "The Dll List has been stored into a file, "dlllist2.txt"."	#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.6 Extract hashes into a file and Display the hashes.
		echo ""
		echo "Extracting hashes..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.hashdump.Hashdump > hashdump2.txt	#With the usage of hashdump.Hashdump flag for Volatility3, extracts all hashes & stores into a file
		cat hashdump2.txt												#Displays the hashes stored in the file
		deactivate
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.7 Extract the Registry Information into a file
		echo ""
		echo "Extracting Registry Information..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.registry.hivelist.HiveList > hivelist2.txt	#With the usage of registry.hivelist.HiveList flag for Volatility3, extracts all registry information & stores into a file
		deactivate
		echo "The Registry Information has been stored into a file, "hivelist2.txt"."	#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
#1.2.8 Extract the SIDs into a file
		echo ""
		echo "Extracting the SIDs..."
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		python -m venv venv												#Creating a venv virtual environment
		. ./venv/bin/activate
		vol -f "$memoryfile" windows.getsids.GetSIDs > sid2.txt	#With the usage of getsids.GetSIDs flag for Volatility3, extracts all SIDs & stores into a file
		deactivate
		echo "The SIDs have been stored into a file, "sid2.txt"."		#Successful message
		echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
		;;
	*)																	#Everything else but option 1 or 2
		echo "Invalid entry."											#If anything else is keyed instead, this will be displayed
		;;																#Ends the case statement
esac
