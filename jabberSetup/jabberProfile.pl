#!/usr/bin/perl

$ToolPath = "/System/Library/ServerSetup/serversetup";
$ENetworkSetupToolPath = "/usr/sbin/networksetup";
$AddFW0=0;

$HostMasterLDAP=1.1;
$HostMasterLDAPNetInfo=1.2;
$HostMasterNetInfo=1.3;
$DirectoryClient=2;
$Standalone=3;
$Advanced=4;
$HostingReplicaLDAPDirectoryServer=6.1;
$HostingReplicaLDAPNetInfoDirectoryServer=6.2;
$HostingReplicaLDAPNetInfoServer=6.3;

$dbg=0;

open(OUT, '>/System/Library/ServerSetup/UnConfigured/jabberProfile.plist') or die ("Couldn't open the jabberProfile.plist file for writing.\n");
select(OUT);

@ThoseLines;

@PortDevices;
@PortMACList;
@PortStatus;
@PortATStatus;
@PortNames;
@DNSServers;
@DNSDomains;
@PortConfiguredToUse;
@IPS;
@SBMS;
@Routers;
@DHCPClientIDS;
@LocalUserList;
@LocalGroupsList;
$NumberOfLocalUsers=0;
@IPv6Type;
@IPv6Address;
@IPv6Router;
@IPv6PrefixLength;


WriteLog(); #3
FireWireSetup();

WriteLog(); #7
PrimaryLanguage();
WriteLog(); #11
HostName();
WriteLog(); #13
ComputerName();
WriteLog(); #14
GetAllPortNamesAndStatus();
WriteLog(); #15
GetAllDevices();
WriteLog(); #18
GetDNSServers();
WriteLog(); #19
GetDNSDomains();
WriteLog(); #20
NetworkInterfaces();
WriteLog(); #21
Header();
WriteLog(); #25
SupremeOutPut();
WriteLog(); #26
PrintNetInterfacesDict();
WriteLog(); #29
Footer();
WriteLog(); #30

close(OUT);
WriteLog(); #31

if (-e "/System/Library/ServerSetup/UnConfigured/jabberProfile.plist") {
    system("/bin/chmod 664 /System/Library/ServerSetup/UnConfigured/jabberProfile.plist");
}
WriteLog(); #32
#####################################################################################################
sub WriteLog() {
        return();  #Skip logging
        $dbg++;
        if($dbg == 1) {
                system("echo -n $dbg  > /System/Library/ServerSetup/jabberProfileLog.txt");
        }
        else {
                system("echo -n $dbg  >> /System/Library/ServerSetup/jabberProfileLog.txt");
        }
        system("echo -n \" \" >> /System/Library/ServerSetup/jabberProfileLog.txt");
        system("/bin/date >> /System/Library/ServerSetup/jabberProfileLog.txt");
}

sub FireWireSetup() {
	#See if we have a Firewire port?
    @lines = qx($ENetworkSetupToolPath '-listallhardwareports');
	for($i=0; $i<=$#lines; $i++) {
		$LG=$lines[$i];
		chomp($LG);
		if ("$LG" eq "Device: fw0") {
			$AddFW0=1;
		}
	}
	#See if the FW Port is already enabled?
    @lines = qx($ENetworkSetupToolPath '-listallnetworkservices');
	for($i=0; $i<=$#lines; $i++) {
		$LG=$lines[$i];
		chomp($LG);
		if ("$LG" eq "Built-in FireWire") {
			#Its already enabled so don't added it again
			$AddFW0=0;
		}
	}

	#If AddFW0 is true then add the port.
	if ("$AddFW0" eq "1") {
		@lines = qx($ENetworkSetupToolPath -createnetworkservice 'Built-in FireWire' 'Built-in FireWire');
	}
}



sub SupremeOutPut() {
#### Serial Number

#### Services
#### Services

	if (length($ResultsHostName)) {
		print ('     <key>HostName</key>'. "\n");
		print ('     <string>'.$ResultsHostName.'</string>'. "\n");
	}
#####################
#####################
#####################
#####################
#####################
	if (length($PrimaryLanguage)) {
		print ('     <key>PrimaryLanguage</key>'. "\n");
		print ('     <string>'. $PrimaryLanguage.'</string>'. "\n");
	}
#####################

}
##########################################
sub PrintNetInterfacesDict() {
	print ('    <key>' . 'NetworkInterfaces' . "</key>" . "\n");
	print ('    <array>'. "\n");

	for($i=0; $i<=$#PortConfiguredToUse; $i++) {
	    if ( lc($IPS[$i]) eq lc("NA") ) { next; }
	    
		if ( (lc($PortNames[$i]) ne lc("Bluetooth")) &&
		 (lc($PortNames[$i]) ne lc("USB Bluetooth Modem Adaptor")) &&
		 (lc($PortNames[$i]) ne lc("Internal Modem")) &&
		 (lc($PortNames[$i]) ne lc("Modem Port")) &&
		 (lc($PortNames[$i]) ne lc("Modem")) &&
		 (lc($PortNames[$i]) ne lc("Serial Port")) &&
		 (lc($PortNames[$i]) ne lc("Serial")) &&
		 (lc($PortNames[$i]) ne lc("DB9")) &&
		 ($PortDevices[$i] ne "Bluetooth-Modem") &&
		 ($PortDevices[$i] ne "stf0") ) {
	
		print ("        <dict>" . "\n");
	
		#ActiveAT
		
		#ActiveTCPIP
		print ("            <key>" . "ActiveTCPIP" . "</key>" . "\n");
		if($PortStatus[$i] eq "1") {
			print ("            <true/>" . "\n");
		}
		else {
			print ("            <false/>" . "\n");
		}
		
	#PortName
		print ("            <key>" . "PortName" . "</key>" . "\n");
		print ("            <string>" . $PortNames[$i] . "</string>" . "\n");
	
	#DeviceName
		print ("            <key>" . "DeviceName" . "</key>" . "\n");
		print ("            <string>" . $PortDevices[$i] . "</string>" . "\n");
	
	#DNSDomains
		print ('            <key>' . 'DNSDomains' . "</key>" . "\n");
		@Domains=();
		@Domains=split(/,/, $DNSDomains[$i]);
		if($#Domains >= 0){
			print ("            <array>" . "\n");
			for($k=0; $k<=$#Domains;$k++) {
				print ("                <string>" . $Domains[$k] . "</string>" . "\n");
			}
			print ("            </array>" . "\n");
		}
		else {
			print ("            <array/>" . "\n");
		}
	
	#DNSServers
		print ("            <key>" . "DNSServers" . "</key>" . "\n");
	@Server=();
	@Servers=split(/,/, $DNSServers[$i]);
	#print("$DNSServers[$i]\n");
	#print("@Servers\n");
		if($#Servers >= 0) {
			print ("            <array>" . "\n");
			for($k=0; $k<=$#Servers;$k++) {
				print ("                <string>" . $Servers[$k] . "</string>" . "\n");
			}
			print ("            </array>" . "\n");
		}
		else {
			print ("            <array/>" . "\n");
		}

	#EthernetAddress
	
	####### Settings
		print ("            <key>" . "Settings" . "</key>" . "\n");
		print ("            <dict>". "\n");
		#PortName
		print ("                <key>" . "Type" . "</key>" . "\n");
		print ("                <string>" . $PortConfiguredToUse[$i] . "</string>" . "\n");
		print ("                <key>" . "IPAddress" . "</key>" . "\n");
		print ("                <string>" . $IPS[$i] . "</string>" . "\n");
		print ("                <key>" . "SubnetMask" . "</key>" . "\n");
		print ("                <string>" . $SBMS[$i] . "</string>" . "\n");
		print ("                <key>" . "Router" . "</key>" . "\n");
		print ("                <string>" . $Routers[$i] . "</string>" . "\n");
		print ("                <key>" . "DHCPClientID" . "</key>" . "\n");
		print ("                <string>" . $DHCPClientIDS[$i] . "</string>" . "\n");
		
		print ("            </dict>" . "\n");
	####### Settings
	
	####### IPv6 Settings
	####### IPv6 Settings

	####### Ethernet Settings
	####### Ethernet Settings

		print ("        </dict>" . "\n");
		}
	}
	print ("    </array>" . "\n");
}

sub NetworkInterfaces() {
	for($i=0; $i<=$#PortNames; $i++) {
		$PN=$PortNames[$i];
		if($PortStatus[$i] eq "1") {
			@tmp = qx($ENetworkSetupToolPath -getinfo "$PN");
			$tmp2="$tmp[0]";
			chomp($tmp2);
			push(@PortConfiguredToUse, "$tmp2");
			## Will be one of the following for 
			#Manual Configuration
			#Manually Using DHCP Router Configuration
			#DHCP Configuration
			#BOOTP Configuration
			if("$tmp2" eq "Manual Configuration") {
			#IP SN R
				$IP=$tmp[1]; chomp($IP); @tt=split(/IP address: /, $IP); $IP=$tt[1];
				$SN=$tmp[2]; chomp($SN); @tt=split(/Subnet mask: /, $SN); $SN=$tt[1];
				$R =$tmp[3]; chomp($R); @tt=split(/Router: /, $R); $R=$tt[1];
				$CID="";
			}
			if("$tmp2" eq "Manually Using DHCP Router Configuration") {
			#IP
				$IP=$tmp[1]; chomp($IP); @tt=split(/IP address: /, $IP); $IP=$tt[1]; if (!length($IP)) { $IP="NA"; }
				$SN=$tmp[2]; chomp($SN); @tt=split(/Subnet mask: /, $SN); $SN=$tt[1]; if (!length($SN)) { $SN="NA"; }
				$R =$tmp[3]; chomp($R); @tt=split(/Router: /, $R); $R=$tt[1]; if (!length($R)) { $R="NA"; }
				$CID="";
			}
			if("$tmp2" eq "DHCP Configuration") {
			#CLIENTID
				$IP=$tmp[1]; chomp($IP); @tt=split(/IP address: /, $IP); $IP=$tt[1]; if (!length($IP)) { $IP="NA"; }
				$SN=$tmp[2]; chomp($SN); @tt=split(/Subnet mask: /, $SN); $SN=$tt[1]; if (!length($SN)) { $SN="NA"; }
				$R =$tmp[3]; chomp($R); @tt=split(/Router: /, $R); $R=$tt[1]; if (!length($R)) { $R="NA"; }
				$CID=$tmp[4]; chomp($CID); @tt=split(/Client ID: /, $CID); $CID=$tt[1]; if (!length($CID)) { $CID=""; }
			}
			if("$tmp2" eq "BOOTP Configuration") {
			# none
				$IP=$tmp[1]; chomp($IP); @tt=split(/IP address: /, $IP); $IP=$tt[1];
				$SN=$tmp[2]; chomp($SN); @tt=split(/Subnet mask: /, $SN); $SN=$tt[1];
				$R =$tmp[3]; chomp($R); @tt=split(/Router: /, $R); $R=$tt[1];
				$CID="";
			}
			push(@IPS, $IP);
			push(@SBMS, $SN);
			push(@Routers, $R);
			push(@DHCPClientIDS, $CID);

#### IPv6
#### IPv6

		}
		else {
				push(@PortConfiguredToUse, "PortOff");
		}
	}
}

sub GetDNSDomains() {
	for($i=0; $i<=$#PortNames; $i++) {
		$PN=$PortNames[$i];
		if($PortStatus[$i] eq "1") {
			$daString="";
			@tmp = qx($ToolPath -getDNSDomain "$PN");
			#print("GetDNSDomains := @tmp\n");
			for($j=0; $j<=$#tmp; $j++) {
				$tmp2=$tmp[$j];
				chomp($tmp2);
				if($j ne $#tmp) {
					$daString=$daString."$tmp2,";
				}
				else {
					$daString=$daString."$tmp2";
				}
			}
			push(@DNSDomains, "$daString");
		}
		else {
			push(@DNSDomains, "");
		}
	}
}

sub GetDNSServers() {
	for($i=0; $i<=$#PortNames; $i++) {
		$PN=$PortNames[$i];
		if($PortStatus[$i] eq "1") {
			$daString="";
			@tmp = qx($ToolPath -getDNSServer "$PN");
			#print("GetDNSServers := @tmp\n");
			for($j=0; $j<=$#tmp; $j++) {
				$tmp2=$tmp[$j];
				chomp($tmp2);
				if($j ne $#tmp) {
					$daString=$daString."$tmp2,";
				}
				else {
					$daString=$daString."$tmp2";
				}
			}
			push(@DNSServers, "$daString");
		}
		else {
			push(@DNSServers, "");
		}
	}
}


sub GetAllPortNamesAndStatus() {
    @PortNamesList = qx($ENetworkSetupToolPath -listnetworkserviceorder);
    for($j=1; $j<=$#PortNamesList; $j=$j+3) {
	$tmp=$PortNamesList[$j];
	chomp($tmp);
	$asterix=index($tmp, "(*)");
	$cc=index($tmp, ')');
	if($asterix eq -1) {
# 	    print("1: ".substr($tmp, $cc+2, (length($tmp)-1))."\n");
	    push(@PortNames, substr($tmp, $cc+2, (length($tmp)-1)) );
	    push(@PortStatus,"1");
	}
	else {
# 	    print("0: $tmp\n");
	    push(@PortNames, substr($tmp, $cc+2, (length($tmp)-1)) );
	    push(@PortStatus,"0");
	}
#	print("j := " . $j . " " . $tmp . "\n");
    }
}

sub GetAllDevices() {
	@PortDeviceList = qx($ENetworkSetupToolPath -listnetworkserviceorder);
	for($i=0; $i<$#PortDeviceList; $i=$i+3) {
		$blank=$PortDeviceList[$i];
		$PN=$PortDeviceList[$i+1];
		$INFO=$PortDeviceList[$i+2];
		chomp($blank);
		chomp($PN);
		chomp($INFO);
		@jDEV=split(/Device: /, $INFO);
		$jDEV[1] =~ s/\)//;
#       print("b:     $blank\n");
#       print("PN:    $PN\n");
#       print("INFO:  $INFO\n");
#       print("DEV$i: $jDEV[1]\n");
		push(@PortDevices,$jDEV[1]);
	}
}



sub HostName() {
	$cmd = "$ToolPath -getHostName";
	$ResultsHostName = qx($cmd);
	chomp($ResultsHostName);
}


sub ComputerName() {
	$cmd = "$ToolPath -getComputerName";
	$ResultsComputerName = qx($cmd);
	chomp($ResultsComputerName);
}


sub PrimaryLanguage() {
	$cmd = "$ToolPath -getPrimaryLanguage";
	$PrimaryLanguage = qx($cmd);
	chomp($PrimaryLanguage);
}

sub Header() {
	print ('<?xml version="1.0" encoding="UTF-8"?>' . "\n");
	print ('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' . "\n");
	print ('<plist version="1.0">' . "\n");
	print ('<dict>' . "\n");
}

sub Footer() {
    print ("</dict>" . "\n");
    print ("</plist>" . "\n");
}
