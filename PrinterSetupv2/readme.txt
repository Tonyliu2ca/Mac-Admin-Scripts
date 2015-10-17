# ------------------------------
# setup printer scripts
# script name: setNPrn.sh

# version 2.1
#    
# ------------------------------

main scripts: setNPrn.sh
tools: getPrinterOptions.sh

Command line:
  1. setNPrn.sh
     setNPrn.sh [-v] -c Config.plist -l List.plist
     the -c defines the printer config plist file.
     the -l defines the printer list plist file.

  2. getPrinterOptions.sh /etc/cups/ppd/office.ppd
     On a test machine, set up printer appropriate and locate the ppd file. On Mac, this 
     file is in /etc/cups/ppd/ folder. use this tool to find the customized printer 
     options and add it to PrinterConfig.plist file.


There are two plist files needed to be defined:
PrinterList.plist
PrinterConfig.plist

PrinterList.plist:
	This file defines how to manipulate printers on a certain group of computers.


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
		7. everyone (boolean): if everyone can add/remove printers
		8. RemovePrinterList (array of dictionary): printers to be removed.
			1. Type (string): supported type: Description; DeviceName; Protocol.
			2. Name (string): the name of this type of printer.
			3. Compare (string): how to find the name, support:
				(is | eq): equal to
				(not is|nq): no equal to
				(like): contains, name is a substring of it
				(not like): not contains, name is not a sub string of it
				(-z | null): is null
				(-n | not null): is NOT null
				(> | gt): bigger than
				(< | lt): less than
				(>= | nl): not less than
				(<= | le): less or equal than
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
server="your.server.com"; 
mkdir /tmp/installPrinters;
cd /tmp/installPrinters; 
curl -o ip.sh "http://${server}/installPrinters.sh"; 
chmod +x ip.sh; 
curl -o pc.plist "http://${server}/PrinterConfig.plist"; 
curl -o pl.plist "http://${server}/PrinterList.plist"; 
./ip.sh -c ./pc.plist -l ./pl.plist


#-----------------------------
Q: How does it find a printer driver:
A: If get the printer Brand and looks for the Brand in Drivers of Drivers in PrinterConfig
plist file

#-----------------------------
Q: How does it find computer group
A: Scripts read the ComputerInfo from PrinterConfig.plist file and then read the local 
workstation Info from the field ComputerInfo defined. This we get current workstation
info, according to this to look for which ComputerID of each group of CompGroups of 
PrinterList. If found, use it, if not found, use the Default one, if no Default exist,
then do nothing.

#-----------------------------------------
Q: How does it find printer configuration details:
A: It gets all printers defined in PrinterList item in PrinterList plist file.
for each printer in the list searchs the printer name in the Device of Printers in
PrinterConfig plist file. If found then read all the configurations and setup.
  

#-----------------------------------------
Q: How does it remove printers details:
A: This' about the RemovePrinterList item in PrinterList.plist.
1. a printer can be identified by different Types: Description, DeviceName or Protocol.
	The Description is a printer name what a end user see on printing. 
	The DeviceName is a printers CUPS device name, admin can list all printers on a local
	machine using command:lpstat -p | awk '{print $2}'
	The Protocol is a printers device_uri. admin may find all printers uri using command:
	lpstat -v | awk '{print $4}'.
2. The Name is what part of the string of the Type you want to use.
3. The Compare defines how to find a match printer.
   system supports 10 compare verbs:
		(is | eq): means  the Name is identical to the Types.
		(not is|nq): means  the Name is NOT identical to the Types.
		(like): means the Name is substring of the Types.
		(not like): means the Name is NOT substring of the Types.
		(-z | null): means a printer Types is NULL.
		(-n | not null): means a printer Types is NOT NULL.
		(> | gt): means a printer's Type is bigger than the Name.
		(< | lt):  means a printer's Type is smaller than the Name.
		(>= | nl): means a printer's Type is bigger than or equal to the Name.
		(<= | le): means a printer's Type is smaller than or equal to the Name.
You define the search criteria by the above three factors, which type, what name and how
to Compare.

For example: 
   a. you want to remove a printer, which has protocol using dnns, then use:
	   Type: Protocol
   	Name: dnns
   	Compare: like
   b. you want to remove a printer, which IP=10.10.10.10, then use:
   	Type: Protocol
   	Name: 10.10.10.10
   	Compare: like
   c. you want to remove a printer, which printer name doen't has "OFF", then use:
   	Type: Description
   	Name: OFF
   	Compare: not like
   d. you want to remove a printer, which device name > "ABC", then use:
   	Type: DeviceName
   	Name: ABC
   	Compare: >

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
