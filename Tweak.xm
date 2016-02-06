#import "Headers.h"

#ifdef DEBUG
    #define ISLog(fmt, ...) NSLog((@"[Isol8] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define ISLog(fmt, ...)
#endif

static BOOL enabled;
static NSArray *keywords;

#pragma mark - Static Methods

static void ReloadSettings() {
	NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];

	NSNumber *enabledNum = preferences[kISEnabledKey];
	enabled = enabledNum ? [enabledNum boolValue] : 0;

	ISLog(@"RELOADSETTINGS: %@",preferences);
}

static void ReloadSettingsOnStartup() {
  NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];

  NSNumber *enabledNum = preferences[kISEnabledKey];
  enabled = enabledNum ? [enabledNum boolValue] : 0;

  ISLog(@"RELOADSETTINGSONSTARTUP: %@",preferences);
}

static BOOL CancelBulletin(BBBulletin *bulletin) {
  if (![bulletin.sectionID isEqualToString:@"com.apple.MobileSMS"] || !bulletin.context[@"AssistantContext"])
  {
    ISLog(@"INVALID BULLETIN FOR MUTING");
    return NO;
  }

  NSDictionary *context = bulletin.context;
  NSDictionary *assistantContext = context[@"AssistantContext"];

  ISLog(@"BULLETIN CONTEXT: %@",assistantContext);

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

  NSString *chatId;
  if (recipients) {
    chatId = context[@"CKBBUserInfoKeyChatIdentifier"];
  } else {
    if ([assistantContext[@"msgSender"][@"data"] isKindOfClass:[NSString class]]) {
      chatId = (NSString*)assistantContext[@"msgSender"][@"data"];
    } else {
      return NO;
    }
  }

  ISLog(@"CHATID: %@",chatId);

  NSDictionary *storedPrefs = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];
  NSArray *muted;
  if([storedPrefs objectForKey:kISMutedConversationsKey]) {
    muted = [storedPrefs objectForKey:kISMutedConversationsKey];
  } else {
    muted = [NSArray array];
  }

  ISLog(@"MUTED CHAT IDs: %@",muted);

  if (enabled && chatId) {
      ISLog(@"ENABLED FOR VALID CONVERSATIONS");
      for (NSString *identifier in muted) {
        ISLog(@"COMPARING ID FROM ARRAY: %@ TO CHATID FROM BULLETIN: %@",identifier,chatId);
        if ([identifier containsString:chatId]) {
          ISLog(@"MUTING CONVERSATION WITH CHAT ID: %@",identifier);
          return YES;
        }
      }
  } else {
    ISLog(@"DISABLED OR INVALID MESSAGE; NOT MUTING CONVERSATION");
    return NO;
  }
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

	[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		ISLog(@"STORED PREFS ARRAY: %@",[[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath] objectForKey:kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}

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

	[storedPrefs setObject:muted forKey:kISMutedConversationsKey];

	BOOL success = [storedPrefs writeToFile:kISSettingsPath atomically:YES];
	if (success) {
		ISLog(@"PREFS WRITTEN SUCCESSFULLY");
		ISLog(@"STORED PREFS ARRAY: %@",[[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath] objectForKey:kISMutedConversationsKey]);
	} else {
		ISLog(@"PREFS FAILED TO SAVE");
	}

}

%ctor {

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	ReloadSettingsOnStartup();

}


#pragma mark - Hooks

%hook CKConversationListController

- (void)loadView {
  %orig;
  if (enabled) {
    NSDictionary *storedPrefs = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];
    NSArray *mutedConversations;
    if([storedPrefs objectForKey:kISMutedConversationsKey]) {
      mutedConversations = [storedPrefs objectForKey:kISMutedConversationsKey];
    } else {
      mutedConversations = [NSArray array];
    }

    if ([self.conversationList conversations] && [self.conversationList.conversations isKindOfClass:[NSArray class]]) {
      NSArray *convos = [self.conversationList conversations];
      for (CKConversation *conversation in convos) {
        if (conversation.muted) {
          ISLog(@"ENABLED AND TRYING TO CHANGE MUTE STATUS FOR VALID CONVERSATION");
          ISLog(@"SWITCH TURNED ON; SAVING GROUPID IF POSSIBLE");
          if (![mutedConversations containsObject:conversation.groupID]) {
            ISLog(@"ADDING CONVERSATION TO MUTED WITH GROUPID: %@",conversation.groupID);
            SaveConversation(conversation);
          }
        } else {
          ISLog(@"SWITCH TURNED OFF; REMOVING GROUPID IF POSSIBLE");
          if ([mutedConversations containsObject:conversation.groupID]) {
            ISLog(@"REMOVING CONVERSATION TO MUTED WITH GROUPID: %@",conversation.groupID);
            RemoveConversation(conversation);
          }
        }
      }
    }
  }
}

%end

%hook CKTranscriptRecipientsController

- (void)_muteSwitchValueChanged:(UISwitch*)arg1 {
	%orig;
  if(enabled) {
    NSDictionary *storedPrefs = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];
    NSArray *mutedConversations;
    if([storedPrefs objectForKey:kISMutedConversationsKey]) {
      mutedConversations = [storedPrefs objectForKey:kISMutedConversationsKey];
    } else {
      mutedConversations = [NSArray array];
    }

    ISLog(@"ENABLED AND TRYING TO CHANGE MUTE STATUS FOR VALID CONVERSATION");
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

- (void)_updateModelAndViewForAdditionOfItem:(id)item {

	if ([item isKindOfClass:[%c(SBAwayBulletinListItem) class]]) {
		ISLog(@"VALID SBAWAYBULLETINLISTITEM FOR MUTING");
		SBAwayBulletinListItem *bulletinItem = (SBAwayBulletinListItem*)item;
		if (!CancelBulletin(bulletinItem.activeBulletin)) {
			ISLog(@"DID NOT MUTE BULLETIN: %@",bulletinItem.activeBulletin);
			%orig;
		} else {
			ISLog(@"MUTED BULLETIN: %@",bulletinItem.activeBulletin);
		}
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
