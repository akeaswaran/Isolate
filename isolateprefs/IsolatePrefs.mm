#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"enabled"

@interface IsolatePrefsListController: PSListController {
}
@end

@implementation IsolatePrefsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        [self setTitle:@"Isolate"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Isolate 0.1"];
        [firstGroup setProperty:@"© 2014 Akshay Easwaran" forKey:@"footerText"];
        
        PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [enabled setIdentifier:kISEnabledKey];
        [enabled setProperty:@(YES) forKey:kISEnabledKey];
        
        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"contact developer"];
        [thirdGroup setProperty:@"Feel free to follow me on Twitter for any updates on my apps and tweaks or contact me for support questions.\n\nThis tweak is open source, so make sure to check out my GitHub." forKey:@"footerText"];
        
        PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"twitter"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:Nil
                                                               cell:PSLinkCell
                                                               edit:Nil];
        twitter.name = @"@akeaswaran";
        twitter->action = @selector(openTwitter);
        [twitter setIdentifier:@"twitter"];
        [twitter setProperty:@(YES) forKey:@"enabled"];
        [twitter setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/IsolatePrefs.bundle/twitter.png"] forKey:@"iconImage"];
        
        PSSpecifier *github = [PSSpecifier preferenceSpecifierNamed:@"github"
                                                              target:self
                                                                 set:nil
                                                                 get:nil
                                                              detail:Nil
                                                                cell:PSLinkCell
                                                                edit:Nil];
        github.name = @"https://github.com/akeaswaran";
        github->action = @selector(openGithub);
        [github setIdentifier:@"github"];
        [github setProperty:@(YES) forKey:@"enabled"];
        [github setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/IsolatePrefs.bundle/github.png"] forKey:@"iconImage"];
        
        [specifiers addObject:firstGroup];
        [specifiers addObject:enabled];
        [specifiers addObject:thirdGroup];
        [specifiers addObject:twitter];
        [specifiers addObject:github];
        
        _specifiers = specifiers;
    }
    
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:kISSettingsPath];
    
    if ([specifier.identifier isEqualToString:kISEnabledKey]) {
        if (settings) {
            if ([settings objectForKey:kISEnabledKey]) {
                if ([[settings objectForKey:kISEnabledKey] boolValue]) {
                    return [NSNumber numberWithBool:YES];
                }
            }
        }
    }
    
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    if ([specifier.identifier isEqualToString:kISEnabledKey]) {
        if ([value boolValue]) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISEnabledKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISEnabledKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, TRUE);
        
    }  
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/akeaswaran"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=akeaswaran"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=akeaswaran"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=akeaswaran"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/akeaswaran"]];
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/akeaswaran"]];
}

@end

