#-----------------------
# version 2.0
#
#-----------------------
There are two plist files needed to be defined:
PrinterList.plist
PrinterConfig.plist

PrinterList.plist:
This file defines all the printers for each computer group and how to identify computer group.

PrinterConfig.plist
defines all printers configurations, and if needed where to look for the printer driver.


#-----------------------------
Structure of each plist file
A. PrinterList.plist:
	1. ComputerInfo (string):
	2. log_file (string): full path of log file. not being used.
	3. log_tag (string): tag the log. not being used.
	4. Version (string): =2.0
	5. CompGroups (array of dictionary): define group of computer configurations,
		"CompGroups" field structure:
		1. ComputerID (string): define this group of computer ID
		2. Default (boolean): if this is default group. if one computer is not in any computer group, default will be aplied.
		3. PrinterAdmin (array of dictionary): define the user/group to be added to _lpadmin group
			1. group (string): the type of this member, either "user", "group", "computer", or "computergroup"
			2. member (string): the name of the member user/group
		4. PrinterOperator (array of dictionary): define the user/group to be added to _lpoperator group
			1. group (string): the type of this member, either "user", "group", "computer", or "computergroup"
			2. member (string): the name of the member user/group
		5. PrinterList (array of string): define all the printers to be installed for this group of computers.
		6. removeOD (boolean): if true, will remove the computer from bound OD.
		7. RemovePrinterList (array of dictionary): printers to be removed.
			1. Type (string): supported type: Description; DeviceName; Protocol.
			2. Name (string): the name of this type of printer.
		8. resetCUPS (boolean): if reset CUPS system.

B. PrinterConfig.plist
	1. Printers (array of dictionary): all printer configurations
		1. Brand (string): printer brand, used for installing brand of driver
		2. Descritpion (string): the printer name showed for end user.
		3. Driver (string): the full path of PPD file
		4. IP (string): printer IP address
		5. Location (string): the printer location info. option
		6. Device (string): the printer device name. this is used to identify printers in PrinterList
			of CompGroups in PrinterList.plist file.
		7. Options (array of string): define the printer options
		8. protocol (string): the protocol name, i.e. socket, ldp, ipp etc.		 
	2. Drivers (array of dictionary): all driver configurations
		1. BrandIndex (dictionary): each brand printer index - not being used.
		2. Drivers (array of dictionary): define each driver info
			1. Brand (string): the brand of this driver
			2. Path (string): the full path to download the printer installation package
			3. Protocol (string): protocol to be used to download the driver package
			4. Username (string): username to access
			5. Password (string): username's password

#-----------------------------
Command line:
	-c: define the printer configuration plist file
	-l: define the PrinterList plist file
	-v: verbose mode
	-h|--help|-?: display help

#-----------------------------
AARM policy:
	1. UNIX command:
server="s404wss1.edu.cbe.ab.ca"; mkdir /tmp/installPrinters; cd /tmp/installPrinters; curl -o ip.sh "http://${server}/installPrinters.sh"; chmod +x ip.sh; curl -o pc.plist "http://${server}/PrinterConfig.plist"; curl -o pl.plist "http://${server}/PrinterList.plist"; ./ip.sh -c ./pc.plist -l ./pl.plist

#-----------------------------
How to find a printer driver:


#-----------------------------
How to find computer group


#-----------------------------------------
How to find printer configuration details:



#-----------------------------
1. Define computer to be run on
   You can define a group of computers to apply this configurations.
   the <ComputerInfo> defined which ARD computer Info field to be used, and <ComputerID>
   define the group of computer string. the program will retrieve the current computer
   computer info field string and compare it with <ComputerID>, if it contains <ComputerID>
   substring, then it will continue, otherwise it quits.


#-----------------------------
Details explianing:
1. Drivers:
  Drivers (array of dictionary):
    Brand: the brand of this driver
    Username & Password (string): for download authentication (not used).
    Path: the driver DMG file download path
    Protocol: the download server protocol, i.e. http

2. Printers:
  Brand (string): the brand of the printer, must be the same in Drivers.
  Description (string): the printer description that user see when print.
  Driver (string): the real full path of the printer PPD file.
  IP (string): the IP address of the printer.
  Location (string): desription of the printer location. 
  Name (string): the printer device name.
  Options (array of strings): the printer configuration options.
  protocol (string): the printer protocol, i.e. socket.

3. printerOperator:
	group (string): valide values: group, user, computer, computergroup
	member (string): the name of the operator user/group
	
4. printerAdmin:
	group (string): valide values: group, user, computer, computergroup
	member (string): the name of the operator user/group
