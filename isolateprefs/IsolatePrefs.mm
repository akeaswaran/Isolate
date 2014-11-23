#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"tweakEnabled"

@interface IsolatePrefsListController: PSListController {
}
@end

@implementation IsolatePrefsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        [self setTitle:@"Isolate"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Isol8 0.0.3"];
        [firstGroup setProperty:@"© 2014 Akshay Easwaran" forKey:@"footerText"];
        
        PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [enabled setIdentifier:kISEnabledKey];
        [enabled setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"Developer"];
        [thirdGroup setProperty:@"This tweak is open source. You can check out this and other projects on my GitHub." forKey:@"footerText"];
        
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
        [specifiers addObject:github];
        
        _specifiers = specifiers;
    }
    
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    /*NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:kISSettingsPath];
    
    if ([specifier.identifier isEqualToString:kISEnabledKey]) {
        if (settings) {
            if ([settings objectForKey:kISEnabledKey]) {
                NSNumber *enabledNum = [settings objectForKey:kISEnabledKey];
                if ([enabledNum intValue] == 1) {
                    return [NSNumber numberWithBool:YES];
                } else {
                    return [NSNumber numberWithBool:NO];
                }
            } 
        }
    }
    
    return [NSNumber numberWithBool:NO];*/

    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];
    if (settings[specifier.identifier]) {
        NSNumber *settingEnabled = settings[specifier.identifier];
        if (settingEnabled.intValue == 1) {
            return [NSNumber numberWithBool:YES];
        } else {
            return [NSNumber numberWithBool:NO];
        }
    }
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    /*if ([specifier.identifier isEqualToString:kISEnabledKey]) {
        if ([value intValue] == 1) {
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
        
    }*/

    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
    [defaults setObject:value forKey:specifier.identifier];
    [defaults writeToFile:kISSettingsPath atomically:YES];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, YES);
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/akeaswaran"]];
}

@end

