#!/bin/bash

#3.1 Identifies system's public IP
echo '3.1. What is the public IP address: '
curl ifconfig.io 																			#curl sends the request to a URL and prints the response, ifconfig replies with the public IP address
echo

#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.2 Identifies private IP address assigned to the system's network interface
echo '3.2. What is the private IP address: '

#Credit: Cannon, J. Linux Training Academy. Available at: https://www.linuxtrainingacademy.com/determine-public-ip-address-command-line-curl/
hostname -I 																				#-I tells the hostname to print the private IP address
echo

#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.3 Displays the MAC address
echo '3.3. What is the MAC address: '
ifconfig | grep ether | awk '{print $2}'													#Prints only the MAC address line & prints only the MAC value column 
echo

#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.4 Displays the percentage of CPU usage for the top 5 processes
echo '3.4 Top 5 Processes of CPU Usage (%)'

#Credit: arif. StackExchange. Available at: https://unix.stackexchange.com/questions/13968/show-top-five-cpu-consuming-processes-with-ps
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6												#Uses the command ps (Process Status) to display all processes (-e). Uses -o to bring out the information of Process ID (pid), command (comm) & % of CPU usage (%cpu)
																							#"--sort=-%cpu" sorts the CPU usage in descending order and "head -n 6" brings out the headings and top 5 of the information needed
echo
														
#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.5 Displays the total and available memory usage statistics
echo '3.5 Total and Available Memory Usage Statistics:' #Display the sentence I intend it to do
#Credit: Matteo. stack overflow. Available at: https://stackoverflow.com/questions/51039780/linux-basic-script-to-print-free-and-total-memory	
free -m | grep -v Swap | sed 1d | awk '{print "Total | Available Memory: ", $2,"|",$7}' 	#I used the command from the source above and editted it on my own. 
																							#"free -m" to display memory usage data in MB. "grep -v" to exclude the swap line. "sed 1d" to exclude the first line heading. Then used "awk" to print the column I want, which is only total and available memory
echo

#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.7 Locate the Top 10 Largest Files in /home
echo '3.7 Top 10 Largest Files in /home'
#Credit: George B. VIRTONO. Available at: https://www.virtono.com/community/tutorial-how-to/how-to-find-the-largest-files-in-linux/
du -ah /home | sort -rh | head -n 10														#Uses du (Disk Usage) to estimate file and directory sizes. "-ah" to show all files in readable units (MB, GB, KB). "sort -rh" to sort from largest to smallest in readable units. "head -n 10" to display only the top 10 in the list
echo

#---------------------------------------------------------------------------------------------------------------------------------------------------

#3.6 Lists active system services with their status
echo '3.6 Active system services with status: '
#Credit: TECMINT #1 LINUX BLOG. Available at: https://www.tecmint.com/list-all-running-services-under-systemd-in-linux/
systemctl list-units --type=service															#Uses systemctl to list all out all its system service statuses. "list-units" to generate only active units and "--type=service" to filter only service units
