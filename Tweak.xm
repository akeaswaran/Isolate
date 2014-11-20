#import "Headers.h"

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"tweakEnabled"
#define kISMutedConversationsKey @"mutedConvos"
#define kISHideInNCKey @"hideInNC"
#define kISHideBannersKey @"hideBanners"
#define kISHideOnLSKey @"hideOnLS"
#define kISClearBadgesKey @"clearBadges"

#ifdef DEBUG
    #define ISLog(fmt, ...) NSLog((@"[Isolate] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define ISLog(fmt, ...)
#endif

static BOOL enabled = YES;
static BOOL hideInNC = YES;
static BOOL hideOnLS = YES;
static BOOL hideBanners = YES;
static BOOL clearBadges = NO;
static NSMutableArray *mutedConversations;
static NSDictionary *prefs;

static BOOL _preventBadgeIncrement = NO;

#pragma mark - Static Methods

static void ReloadSettings()
{
	CFStringRef appID = CFSTR("com.akeaswaran.isolate");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
	    ISLog(@"There's been an error getting the key list!");	     
	    return;
	}
	prefs = (__bridge NSDictionary*)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!prefs) {
     ISLog(@"There's been an error getting the preferences dictionary!");
	}

  	//prefs = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];

    if (prefs) {
        if ([prefs objectForKey:kISEnabledKey]) {
            NSNumber *enabledNum = [prefs objectForKey:kISEnabledKey];
            if (enabledNum.intValue == 1) {
                enabled = YES;
            } else {
                enabled = NO;
            }
        }

        if ([prefs objectForKey:kISMutedConversationsKey]) {
        	mutedConversations = [NSMutableArray arrayWithArray:[prefs objectForKey:kISMutedConversationsKey]];
        }

        if ([prefs objectForKey:kISHideInNCKey]) {
        	NSNumber *ncNum = [prefs objectForKey:kISHideInNCKey];
            if (ncNum.intValue == 1) {
                hideInNC = YES;
            } else {
                hideInNC = NO;
            }
        }

        if ([prefs objectForKey:kISHideOnLSKey]) {
        	NSNumber *lsNum = [prefs objectForKey:kISHideOnLSKey];
            if (lsNum.intValue == 1) {
                hideOnLS = YES;
            } else {
                hideOnLS = NO;
            }
        }

        if ([prefs objectForKey:kISHideBannersKey]) {
        	NSNumber *bannerNum = [prefs objectForKey:kISHideBannersKey];
            if (bannerNum.intValue == 1) {
                hideBanners = YES;
            } else {
                hideBanners = NO;
            }
        }

        if ([prefs objectForKey:kISClearBadgesKey]) {
            NSNumber *badgesNum = [prefs objectForKey:kISClearBadgesKey];
            if (badgesNum.intValue == 1) {
                clearBadges = YES;
            } else {
                clearBadges = NO;
            }
        }
    }

    ISLog(@"RELOADSETTINGS: %@",prefs);
}

static void ReloadSettingsOnStartup()
{
   	CFStringRef appID = CFSTR("com.akeaswaran.isolate");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
	    ISLog(@"There's been an error getting the key list!");	     
	    return;
	}
	prefs = (__bridge NSDictionary*)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!prefs) {
     ISLog(@"There's been an error getting the preferences dictionary!");
	}

  	//prefs = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];

    if (prefs) {
        if ([prefs objectForKey:kISEnabledKey]) {
            NSNumber *enabledNum = [prefs objectForKey:kISEnabledKey];
            if (enabledNum.intValue == 1) {
                enabled = YES;
            } else {
                enabled = NO;
            }
        }

        if ([prefs objectForKey:kISMutedConversationsKey]) {
        	mutedConversations = [NSMutableArray arrayWithArray:[prefs objectForKey:kISMutedConversationsKey]];
        }

        if ([prefs objectForKey:kISHideInNCKey]) {
        	NSNumber *ncNum = [prefs objectForKey:kISHideInNCKey];
            if (ncNum.intValue == 1) {
                hideInNC = YES;
            } else {
                hideInNC = NO;
            }
        }

        if ([prefs objectForKey:kISHideOnLSKey]) {
        	NSNumber *lsNum = [prefs objectForKey:kISHideOnLSKey];
            if (lsNum.intValue == 1) {
                hideOnLS = YES;
            } else {
                hideOnLS = NO;
            }
        }

        if ([prefs objectForKey:kISHideBannersKey]) {
        	NSNumber *bannerNum = [prefs objectForKey:kISHideBannersKey];
            if (bannerNum.intValue == 1) {
                hideBanners = YES;
            } else {
                hideBanners = NO;
            }
        }

        if ([prefs objectForKey:kISClearBadgesKey]) {
            NSNumber *badgesNum = [prefs objectForKey:kISClearBadgesKey];
            if (badgesNum.intValue == 1) {
                clearBadges = YES;
            } else {
                clearBadges = NO;
            }
        }
    }

    ISLog(@"RELOADSETTINGSONSTARTUP: %@",prefs);
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

	if (!prefs) {
		ReloadSettings();
	}
	NSDictionary *storedPrefs = prefs;

	NSArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [storedPrefs objectForKey:kISMutedConversationsKey];
	} else {
		muted = [NSArray array];
	}

    ISLog(@"MUTED CHAT IDs: %@",muted);

	if (enabled && recipients && chatId && recipients.count > 1) {
		ISLog(@"ENABLED FOR VALID GROUP MESSAGE");
		for (NSString *groupID in muted) {
			if ([groupID isEqualToString:chatId]) {
				ISLog(@"MUTING CONVERSATION WITH GROUP ID: %@",groupID);
				if (clearBadges) {
					_preventBadgeIncrement = YES;
				} else {
					_preventBadgeIncrement = NO;
				}
				return YES;
			}
		}
	} else {
		ISLog(@"DISABLED, INVALID, OR NOT GROUP MESSAGE; SO NOT MUTING CONVERSATION");
		_preventBadgeIncrement = NO;
		return NO;
	}
	_preventBadgeIncrement = NO;
	return NO;
}

static void SaveConversation(CKConversation *conversation) {
	NSMutableDictionary *storedPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	NSMutableArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [NSMutableArray arrayWithArray:[storedPrefs objectForKey:kISMutedConversationsKey]];
	} else {
		muted = [NSMutableArray array];
	}
	[muted addObject:conversation.groupID];

	//[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	//BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	CFPreferencesSetAppValue ( CFSTR("mutedConvos"), (__bridge CFArrayRef)muted, CFSTR("com.akeaswaran.isolate") );

	NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	if (temp.allKeys.count > 0) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}
	/*if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
		ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}*/
}

static void RemoveConversation(CKConversation *conversation) {
	NSMutableDictionary *storedPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	NSMutableArray *muted;
	if([storedPrefs objectForKey:kISMutedConversationsKey]) {
		muted = [NSMutableArray arrayWithArray:[storedPrefs objectForKey:kISMutedConversationsKey]];
	} else {
		muted = [NSMutableArray array];
	}
	[muted removeObject:conversation.groupID];

	//[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	//BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	CFPreferencesSetAppValue ( CFSTR("mutedConvos"), (__bridge CFArrayRef)muted, CFSTR("com.akeaswaran.isolate") );

	NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
	ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	if (temp.allKeys.count > 0) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}

	/*if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
		ISLog(@"STORED PREFS ARRAY: %@",temp[kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}*/

}

%ctor {
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	ReloadSettingsOnStartup();
    
}


#pragma mark - Hooks

%hook CKTranscriptRecipientsController
- (void)_muteSwitchValueChanged:(UISwitch*)arg1 {
	%orig;
	if(enabled && self.conversation.recipients.count > 1) {
		if (!mutedConversations) {
			NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
			mutedConversations = temp[kISMutedConversationsKey];
		}

		ISLog(@"ENABLED AND TRYING TO CHANGE MUTE STATUS FOR VALID GROUP MESSAGE");
		if (arg1.on) {
			if (![mutedConversations containsObject:self.conversation.groupID]) {
				ISLog(@"ADDING CONVERSATION TO MUTED WITH GROUPID: %@",self.conversation.groupID);
				SaveConversation(self.conversation);
			}
		} else {
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
	if (!CancelBulletin(bulletin) && !hideOnLS) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		_preventBadgeIncrement = NO;
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);

	}
}

- (void)_updateModelAndViewForAdditionOfItem:(SBAwayBulletinListItem*)item {
	if (!CancelBulletin(item.activeBulletin) && !hideOnLS) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",item.activeBulletin);
		_preventBadgeIncrement = NO;
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",item.activeBulletin);
	}
}

%end

//Blocks NC notifications
%hook BBServer

- (void)publishBulletin:(BBBulletin*)bulletin destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3 {
	if (!CancelBulletin(bulletin) && !hideInNC) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		_preventBadgeIncrement = NO;
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);
	}
}

%end

/*
%hook SBBulletinObserverViewController  

-(void)addBulletin:(SBBBWidgetBulletinInfo*)bulletinInfo toSection:(id)sectionInfo forFeed:(NSUInteger)arg3 {
	if (!CancelBulletin(bulletinInfo.representedBulletin) && !hideInNC) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletinInfo.representedBulletin);
		_preventBadgeIncrement = NO;
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletinInfo.representedBulletin);
	}
}

%end
*/

//Blocks Banners
%hook SBBulletinBannerController

- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed {
	if (!CancelBulletin(bulletin) && !hideBanners) {
		ISLog(@"DID NOT MUTE BULLETIN: %@",bulletin);
		_preventBadgeIncrement = NO;
		%orig;
	} else {
		ISLog(@"MUTED BULLETIN: %@",bulletin);
	}
}

%end

//Blocks Badges
%hook SBIcon 

-(void)setBadge:(NSString*)arg1 {
	if (enabled && clearBadges && _preventBadgeIncrement && [[self applicationBundleID] isEqual:@"com.apple.MobileSMS"]) {
		ISLog(@"BLOCKING BADGE FOR MESSAGES");
	} else {
		%orig;
	}
}

%end





