//
//      
//  ChatServer/jabber_autobuddy
//
//  Copyright 2010-2013 Apple. All rights reserved.
//

#import "JABMakeGroupBuddiesByGuidAction.h"

@implementation JABMakeGroupBuddiesByGuidAction

@synthesize groupGuid = _groupGuid;

//------------------------------------------------------------------------------
- (id) initWithCommandOptions: (NSDictionary *) cmdOpts
{
	self = [super initWithCommandOptions: cmdOpts];

	self.groupGuid = [cmdOpts objectForKey: CMDOPT_KEY_GROUPGUID];
	return self;
}

- (void) dealloc
{
	self.groupGuid = nil;

	[super dealloc];
}

//------------------------------------------------------------------------------
- (BOOL) requiresJid
{
	return NO;
}

//------------------------------------------------------------------------------
- (void) doDBAction
{
	// Add an entry to the 'autobuddy-guids' table for each user in the given group.
	// The user's roster will be updated by jabberd the next time they log in.
	if (! [_database verifyAutobuddyGuidForGuid: _groupGuid
										 source: __PRETTY_FUNCTION__
										   line: __LINE__])
	{
		[_database insertAutobuddyGroupGuidForGuid: _groupGuid
											source: __PRETTY_FUNCTION__
											  line: __LINE__];
	}
}

@end