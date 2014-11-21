#import "Headers.h"

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"tweakEnabled"
#define kISMutedConversationsKey @"mutedConvos"

#ifdef DEBUG
    #define ISLog(fmt, ...) NSLog((@"[Isol8] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define ISLog(fmt, ...)
#endif

static BOOL enabled = YES;
static NSMutableArray *mutedConversations;
static NSDictionary *preferences;

#pragma mark - Static Methods

static void ReloadSettings() {
	preferences = nil;
	CFStringRef appID = CFSTR("com.akeaswaran.isolate");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		ISLog(@"There's been an error getting the key list!");
		return;
	}
	preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		ISLog(@"There's been an error getting the preferences dictionary!");
	}
	CFRelease(keyList);

	if ([preferences objectForKey:kISEnabledKey]) {
    	NSNumber *enabledNum = [preferences objectForKey:kISEnabledKey];
    	if (enabledNum.intValue == 1) {
    		enabled = YES;
    	} else {
    		enabled = NO;
    	}    
    }

    if ([preferences objectForKey:kISMutedConversationsKey]) {
    	mutedConversations = [NSMutableArray arrayWithArray:[preferences objectForKey:kISMutedConversationsKey]];
    }

    ISLog(@"RELOADSETTINGS: %@",preferences);
}

static void ReloadSettingsOnStartup()
{
   	preferences = nil;
	CFStringRef appID = CFSTR("com.akeaswaran.isolate");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		ISLog(@"There's been an error getting the key list!");
		return;
	}
	preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		ISLog(@"There's been an error getting the preferences dictionary!");
	}
	CFRelease(keyList);

	if ([preferences objectForKey:kISEnabledKey]) {
    	NSNumber *enabledNum = [preferences objectForKey:kISEnabledKey];
    	if (enabledNum.intValue == 1) {
    		enabled = YES;
    	} else {
    		enabled = NO;
    	}    
    }

    if ([preferences objectForKey:kISMutedConversationsKey]) {
    	mutedConversations = [NSMutableArray arrayWithArray:[preferences objectForKey:kISMutedConversationsKey]];
    }

    ISLog(@"RELOADSETTINGS: %@",preferences);
}


static BOOL CancelBulletin(BBBulletin *bulletin) {
	if (![bulletin.sectionID isEqualToString:@"com.apple.MobileSMS"] || !bulletin.context[@"AssistantContext"]) {
		ISLog(@"INVALID BULLETIN FOR MUTING");
		return NO;
	}

	NSDictionary *context = bulletin.context;
	NSDictionary *assistantContext = context[@"AssistantContext"];
	NSString *chatId = context[@"CKBBUserInfoKeyChatIdentifier"];

	NSArray *recipients;
	if (assistantContext[@"msgRecipients"]) {
		if ([assistantContext[@"msgRecipients"] isKindOfClass:[NSArray class]]) {
			recipients = assistantContext[@"msgRecipients"];
		} else {
			recipients = nil;
		}
	} else {
		recipients = nil;
	}

	ISLog(@"CHATID: %@",chatId);

	/*NSMutableDictionary *storedPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	NSArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [storedPrefs objectForKey:kISMutedConversationsKey];
	} else {
		muted = [NSArray array];
	}*/
	NSArray *muted = (__bridge NSArray*)CFPreferencesCopyAppValue ( CFSTR("mutedConvos"), CFSTR("com.akeaswaran.isolate") );

    ISLog(@"MUTED CHAT IDs: %@",muted);

	if (enabled && recipients && chatId && recipients.count > 1) {
		ISLog(@"ENABLED FOR VALID GROUP MESSAGE");
		for (NSString *groupID in muted) {
			if ([groupID isEqualToString:chatId]) {
				ISLog(@"MUTING CONVERSATION WITH GROUP ID: %@",groupID);
				return YES;
			}
		}
	} else {
		ISLog(@"DISABLED, INVALID, OR NOT GROUP MESSAGE; SO NOT MUTING CONVERSATION");
		return NO;
	}
	return NO;
}

static void SaveConversation(CKConversation *conversation) {
	/*NSMutableDictionary *storedPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	NSMutableArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [NSMutableArray arrayWithArray:[storedPrefs objectForKey:kISMutedConversationsKey]];
	} else {
		muted = [NSMutableArray array];
	}*/

	NSMutableArray *muted = [NSMutableArray arrayWithArray:(__bridge NSArray*)CFPreferencesCopyAppValue ( CFSTR("mutedConvos"), CFSTR("com.akeaswaran.isolate") )];
	[muted addObject:conversation.groupID];

	/*[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
		ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}*/

	CFPreferencesSetAppValue ( CFSTR("mutedConvos"), (__bridge CFArrayRef)muted, CFSTR("com.akeaswaran.isolate"));	
	NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	if (temp.allKeys.count > 0 && [temp[kISMutedConversationsKey] count] == muted.count) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}
}

static void RemoveConversation(CKConversation *conversation) {
	/*NSMutableDictionary *storedPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	NSMutableArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [NSMutableArray arrayWithArray:[storedPrefs objectForKey:kISMutedConversationsKey]];
	} else {
		muted = [NSMutableArray array];
	}*/

	NSMutableArray *muted = [NSMutableArray arrayWithArray:(__bridge NSArray*)CFPreferencesCopyAppValue ( CFSTR("mutedConvos"), CFSTR("com.akeaswaran.isolate") )];
	[muted removeObject:conversation.groupID];

	/*[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
		ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}*/

	CFPreferencesSetAppValue ( CFSTR("mutedConvos"), (__bridge CFArrayRef)muted, CFSTR("com.akeaswaran.isolate"));	
	NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	if (temp.allKeys.count > 0 && [temp[kISMutedConversationsKey] count] == muted.count) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}

}

%ctor {
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, kNilOptions);

	ReloadSettingsOnStartup();
    
}


#pragma mark - Hooks

%hook CKTranscriptRecipientsController
- (void)_muteSwitchValueChanged:(UISwitch*)arg1 {
	%orig;
	if(enabled && self.conversation.recipients.count > 1) {
		if (!mutedConversations) {
			//NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
			//mutedConversations = temp[kISMutedConversationsKey];
			mutedConversations = [NSMutableArray arrayWithArray:(__bridge NSArray*)CFPreferencesCopyAppValue ( CFSTR("mutedConvos"), CFSTR("com.akeaswaran.isolate") )];
		}

		ISLog(@"ENABLED AND TRYING TO CHANGE MUTE STATUS FOR VALID GROUP MESSAGE");
		if (arg1.on) {
			ISLog(@"SWITCH TURNED ON; SAVING GROUPID IF POSSIBLE");
			if (![mutedConversations containsObject:self.conversation.groupID]) {
				ISLog(@"ADDING CONVERSATION TO MUTED WITH GROUPID: %@",self.conversation.groupID);
				SaveConversation(self.conversation);
			}
		} else {
			ISLog(@"SWITCH TURNED OFF; REMOVING GROUPID IF POSSIBLE");
			if ([mutedConversations containsObject:self.conversation.groupID]) {
				ISLog(@"REMOVING CONVERSATION TO MUTED WITH GROUPID: %@",self.conversation.groupID);
				RemoveConversation(self.conversation);
			}
		}
	}
}

%end

//Blocks LS notifications
%hook SBLockScreenNotificationListController

- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed {
	if (!CancelBulletin(bulletin)) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);
	}
}

- (void)_updateModelAndViewForAdditionOfItem:(SBAwayBulletinListItem*)item {
	if (!CancelBulletin(item.activeBulletin)) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",item.activeBulletin);
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",item.activeBulletin);
	}
}

%end

//Blocks NC notifications
%hook BBServer

- (void)publishBulletin:(BBBulletin*)bulletin destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3 {
	if (!CancelBulletin(bulletin)) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);
	}
}

%end

%hook SBBulletinObserverViewController  

-(void)addBulletin:(SBBBWidgetBulletinInfo*)bulletinInfo toSection:(id)sectionInfo forFeed:(NSUInteger)arg3 {
	if (!CancelBulletin(bulletinInfo.representedBulletin)) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletinInfo.representedBulletin);
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletinInfo.representedBulletin);
	}
}

%end

//Blocks Banners
%hook SBBulletinBannerController

- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed {
	if (!CancelBulletin(bulletin)) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);
	}
}

%end





