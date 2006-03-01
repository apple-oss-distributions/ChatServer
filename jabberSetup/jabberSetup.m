#import <Foundation/Foundation.h>

#define kProfilePath			@"/System/Library/ServerSetup/UnConfigured/jabberProfile.plist"
#define kJabberXMLPath			@"/private/etc/jabber/jabber.xml"
#define kJabberBackUpXMLPath	@"/private/etc/jabber/jabber.xml.bak"

#define	kShellPath				@"/bin/sh"
#define kMarkArgTapPath			@"/var/jabber/modules/proxy65/makeargtap"

#define kUserID					84 //jabber user
#define kUserIDString			@"84"
#define kGroupID				84 //jabber group
#define kGroupIDString			@"84"

NSString* getHostname();
NSString* getIpAddress();

NSDictionary* poaDict;
NSMutableString* xmlFile;

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	poaDict = [NSDictionary dictionaryWithContentsOfFile:kProfilePath];
	xmlFile = [NSMutableString stringWithContentsOfFile:kJabberXMLPath];
	
	NSString* hostname = getHostname();
	//NSString* ipAddress = getIpAddress();
	
	// exit if an error occured
	if(!hostname)	{	return 1;	}
	//if(!ipAddress)	{	return 1;	}
	
	// modify the xml file
	[xmlFile replaceOccurrencesOfString:@"localhost" 
							 withString:hostname
								options:nil
								  range:NSMakeRange(0,[xmlFile length])];
	
	/*
	[xmlFile replaceOccurrencesOfString:@"127.0.0.1" 
							 withString:ipAddress
								options:nil
								  range:NSMakeRange(0,[xmlFile length])];
	
	[xmlFile replaceOccurrencesOfString:@"localloopback" 
							 withString:@"127.0.0.1"
								options:nil
								  range:NSMakeRange(0,[xmlFile length])];
	*/
	
	// append the number to the backup file, so we don't trash anything
	int count = 1;
	NSString* backupPath = kJabberBackUpXMLPath;
	while([[NSFileManager defaultManager] fileExistsAtPath:backupPath]) {
		backupPath = [NSString stringWithFormat:@"%@.%d", kJabberBackUpXMLPath, ++count];
	}
	
	// make a copy for safekeeping
	if(![[NSFileManager defaultManager] copyPath:kJabberXMLPath
										 toPath:backupPath
										handler:nil]) {
		NSLog(@"Error: Backup of %@ to %@ failed", kJabberXMLPath, backupPath);
		return 1;
	}
	
	// write out the new file
	if(![xmlFile writeToFile:kJabberXMLPath atomically:YES]) {
		NSLog(@"Error: Writing of \"%@\" failed", kJabberXMLPath);
		return 1;
	}
    
	// update the proxy65.tap file
	NSArray* tapArgs = [NSArray arrayWithObjects:kMarkArgTapPath, hostname, @"secret", @"127.0.0.1", @"51234", hostname, @"7777", kUserIDString, kGroupIDString, nil];
	[NSTask launchedTaskWithLaunchPath:kShellPath
							 arguments:tapArgs];
	
	// chown the files to jabber user/group
	if(chown([kJabberXMLPath cString], kUserID, kGroupID))
		NSLog(@"Error: Chown of \"%@\" failed", kJabberXMLPath);
	if(chown([backupPath cString], kUserID, kGroupID))
		NSLog(@"Error: Chown of \"%@\" failed", backupPath);

	[pool release];
    return 0;
}

NSString* getHostname() {
	NSString* host = [poaDict objectForKey:@"HostName"];
	if(![host length]) {
		NSLog(@"Error: No hostname found");
		return nil;
	}
	return host;
}

NSString* getIpAddress() {
	NSString* addr = nil;
	NSArray* interfaces = [poaDict objectForKey:@"NetworkInterfaces"];
	if([interfaces count] == 0) {
		NSLog(@"Error: No interfaces found");
		return nil;
	}
	NSDictionary* defaultInterface = [interfaces objectAtIndex:0];
	NSDictionary* settings = [defaultInterface objectForKey:@"Settings"];

	addr = [settings objectForKey:@"IPAddress"];

	return addr;
}

