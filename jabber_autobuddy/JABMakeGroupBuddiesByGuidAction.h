//
//  JABMakeGroupBuddiesByGuidAction.h
//  ChatServer/jabber_autobuddy
//
//  Copyright 2010-2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JABDatabaseAction.h"

@interface JABMakeGroupBuddiesByGuidAction : JABDatabaseAction {

	NSString *_groupGuid; // GeneratedUID of OD group for JID membership
}
@property(retain,readwrite) NSString *groupGuid;

- (id) initWithCommandOptions: (NSDictionary *) cmdOpts;
- (void) dealloc;

- (BOOL) requiresJid;
- (void) doDBAction;

@end
