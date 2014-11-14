//Headers.h

@interface BBBulletin
@property(copy, nonatomic) NSString *sectionID;
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
- (void)_updateModelAndViewForAdditionOfItem:(SBAwayBulletinListItem*)item;
- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed;
@end

//Blocks Banners
@interface SBBulletinBannerViewController
- (void)observer:(BBObserver*)observer addBulletin:(BBBulletin*)bulletin forFeed:(NSUInteger)feed;
@end

@interface CKTranscriptRecipientsController
@property(retain, nonatomic) CKConversation *conversation;
- (void)_muteSwitchValueChanged:(UISwitch*)arg1;
@end
