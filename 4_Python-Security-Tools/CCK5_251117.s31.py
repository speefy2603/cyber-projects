#!/usr/bin/env python

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#References are labelled with [x] and their relevant citations can be found in the PDF file.
#192.168.152.131
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

import socket															#[1] | This allows my program to use the socket module for networking communication between TCP & UDP
import subprocess														#[12] | This allows ping to be used

#1. Accepts a target IP address or host name
target = input("Enter a target IP address or hostname: ")				#Requesting user to input an IP address or hostname
ip = socket.gethostbyname(target)										#[2] | socket.gethostbyname(target) can be used to get the IP address of a hostname if hostname was keyed in instead
print(f"Scanning target: {ip}")											#Displays the IP that was given as input

#2. Allows the user to specify a range of ports to scan
print("Now decide on a range of port to scan below: ")
startport = int(input("	Enter a starting port: "))						#Requests user to enter the port number at the start of the range of ports to scan
endport = int(input("	Enter an ending port: "))						#Requests user to enter the port number at the end of the range of ports to scan

#3. Scans for open TCP or UDP ports
#4. Prints the results (open ports) in a user-friendly format
print("-------------------------------------------------------")
print(f"Scan results for {ip}")
print("-------------------------------------------------------")
portchoice = input("Scan TCP or UDP?:")
#6 Save scan results to a file for later analysis
with open("scanresults.txt", "w") as file:								#Creates a file to store output
	for port in range(startport, endport + 1):							#Scans the ports within range given by user
		if portchoice == "TCP":
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)		#[3], [4] | socket.socket is used to create a socket to make use of IP (sock.AF_INET) & TCP parameters (socket.SOCK_STREAM)
			s.settimeout(1)												#[4] | This is needed to ensure the scan does not take forever. It means that each port will take 1 second to scan before scanning the next
			result = s.connect_ex((ip, port))							#[5] | This establishes a TCP connection with the IP provided & range of ports
			if result == 0:		
				output = f"- Port {port} is OPEN."						#Lines 34-36: Output represents the ports OPEN or closed. This prints the port status into the scanresults.txt
				print(output)
				file.write(output + "\n")
				try:
#5 Retrieve and display service banners for open ports
					banner = s.recv(1024).decode()						#Reads the data sent by the server. Maximum 1024 bytes. Then converts to readable texts with .decode()
					banneroutput = f"Banner: {banner}"					#Lines 38-40: Writes any additional information like banner into scanresults.txt
					print(banneroutput)
					file.write(banneroutput + "\n")
				except: 
					banneroutput = "Banner: Not available"
					print(banneroutput)
					file.write(banneroutput + "\n")
			else:
				output = f"Port {port} is CLOSED."						#Lines 48-50: Same as Lines 34-36
				print(output)
				file.write(output + "\n")
			s.close()													#Resets the scan
		elif portchoice == "UDP":										#[6] | Scanning for UDP is different from TCP because UDP is connectionless. There is no handshake, so connecting to a port to see if it is opened or closed is impossible. Sending a packet and waiting for a response is needed instead.
			s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)		#[7] | SOCK_DGRAM is the UDP version
			s.settimeout(1)
			try: 															
				s.sendto(b"hello", (ip, port))							#[8], [9] | UDP scanning works by sending a UDP packet to a target port and analyzing the response. If the target replies, the port is considered open.
#5 Retrieve and display service banners for open ports				
				banner = s.recvfrom(1024).decode()						#[10] | Once a UDP packet is sent, this is meant to receive. [11] Converts the data into readable texts and displays the banner information.
				output = f"UDP {port} is OPEN | Banner: {banner}"		#When UDP port is opened | Lines 59-61: Same as Lines 34-36.
				print(output)
				file.write(output + "\n")
			except socket.timeout:
				output = f"UDP port {port} is OPEN or FILTERED"			#When the program waits for a response but no reply arrives within the timeout
				print(output)											#Lines 63-65: Same as Lines 34-36
				file.write(output + "\n")
			except:
				banneroutput = f"UDP port {port} is CLOSED"				#When UDP port is closed | Lines 67-69: : Same as Lines 34-36
				print(banneroutput)
				file.write(banneroutput + "\n")
	print("-------------------------------------------------------")
