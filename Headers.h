//Headers.h

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"tweakEnabled"
#define kISMutedConversationsKey @"mutedConvos"

@interface BBBulletin
@property(copy, nonatomic) NSString *sectionID;
@property (nonatomic, retain) NSString *message;
@property(retain, nonatomic) NSDictionary *context;
@end

@interface BBObserver
@end

@interface SBBBWidgetBulletinInfo
@property(readonly, nonatomic) BBBulletin *representedBulletin;
@end

@interface SBAwayBulletinListItem
@property(retain) BBBulletin* activeBulletin;
@end

@interface CKConversation
@property(retain, nonatomic) NSArray *recipients;
@property(readonly, retain, nonatomic) NSString *groupID;
@property(getter=isMuted,readonly) BOOL muted;
@end

@interface CKConversationList
- (id)conversations;
@end

@interface CKTranscriptRecipientsController
@property(retain, nonatomic) CKConversation *conversation;
- (void)_muteSwitchValueChanged:(UISwitch*)arg1;
@end

@interface CKConversationListController
@property CKConversationList * conversationList;
-(void)loadView;
@end

//Blocks NC Notifications
@interface BBServer
- (void)publishBulletin:(BBBulletin*)bulletin destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
@end

@interface SBBulletinObserverViewController
-(void)addBulletin:(SBBBWidgetBulletinInfo*)bulletinInfo toSection:(id)sectionInfo forFeed:(NSUInteger)arg3;
@end

//Blocks LS notifications
@interface SBLockScreenNotificationListController
- (void)_updateModelAndViewForAdditionOfItem:(id)item;
- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed;
@end

//Blocks Banners
@interface SBBulletinBannerController
-(void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed;
@end
