#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kISSettingsPath @"/var/mobile/Library/Preferences/com.akeaswaran.isolate.plist"
#define kISEnabledKey @"tweakEnabled"
#define kISHideInNCKey @"hideInNC"
#define kISHideBannersKey @"hideBanners"
#define kISHideOnLSKey @"hideOnLS"

@interface IsolatePrefsListController: PSListController {
}
@end

@implementation IsolatePrefsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        [self setTitle:@"Isolate"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Isol8 0.1"];
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

        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"Options"];
        [secondGroup setProperty:@"Toggling these switches will enable or disable features of Isol8." forKey:@"footerText"];

        PSSpecifier *hideInNC = [PSSpecifier preferenceSpecifierNamed:@"Hide in Notification Center"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [hideInNC setIdentifier:kISHideInNCKey];
        [hideInNC setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *hideOnLS = [PSSpecifier preferenceSpecifierNamed:@"Hide on Lock Screen"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [hideOnLS setIdentifier:kISHideOnLSKey];
        [hideOnLS setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *hideBanners = [PSSpecifier preferenceSpecifierNamed:@"Hide Banners"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [hideBanners setIdentifier:kISHideBannersKey];
        [hideBanners setProperty:@(YES) forKey:@"enabled"];


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

        [specifiers addObject:secondGroup];
        [specifiers addObject:hideInNC];
        [specifiers addObject:hideOnLS];
        [specifiers addObject:hideBanners];

        [specifiers addObject:thirdGroup];
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
                NSNumber *enabled = [settings objectForKey:kISEnabledKey];
                if (enabled.intValue == 1) {
                    return [NSNumber numberWithBool:YES];
                } else {
                    return[NSNumber numberWithBool:NO];
                }
            } 
        }
    } 

    if ([specifier.identifier isEqualToString:kISHideInNCKey]) {
        if (settings)
        {
            if ([settings objectForKey:kISHideInNCKey]) {
                NSNumber *enabled = [settings objectForKey:kISHideInNCKey];
                if (enabled.intValue == 1) {
                    return [NSNumber numberWithBool:YES];
                } else {
                    return[NSNumber numberWithBool:NO];
                }
            }
        }
    }

    if ([specifier.identifier isEqualToString:kISHideOnLSKey]) {
        if (settings)
        {
            if ([settings objectForKey:kISHideOnLSKey]) {
                NSNumber *enabled = [settings objectForKey:kISHideOnLSKey];
                if (enabled.intValue == 1) {
                    return [NSNumber numberWithBool:YES];
                } else {
                    return[NSNumber numberWithBool:NO];
                }
            }
        }
    }

    if ([specifier.identifier isEqualToString:kISHideBannersKey]) {
        if (settings)
        {
            if ([settings objectForKey:kISHideBannersKey]) {
                NSNumber *enabled = [settings objectForKey:kISHideBannersKey];
                if (enabled.intValue == 1) {
                    return [NSNumber numberWithBool:YES];
                } else {
                    return[NSNumber numberWithBool:NO];
                }
            }
        }
    }
    
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    if ([specifier.identifier isEqualToString:kISEnabledKey]) {
        if ([value intValue] == 1) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISEnabledKey];
            [defaults setObject:value forKey:kISHideInNCKey];
            [defaults setObject:value forKey:kISHideOnLSKey];
            [defaults setObject:value forKey:kISHideBannersKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISEnabledKey];
            [defaults setObject:value forKey:kISHideInNCKey];
            [defaults setObject:value forKey:kISHideOnLSKey];
            [defaults setObject:value forKey:kISHideBannersKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, TRUE);
        [self reloadSpecifiers];
    }

    if ([specifier.identifier isEqualToString:kISHideInNCKey]) {
        if ([value intValue] == 1) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideInNCKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideInNCKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, TRUE);
    }

    if ([specifier.identifier isEqualToString:kISHideOnLSKey]) {
        if ([value intValue] == 1) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideOnLSKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideOnLSKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, TRUE);
    }

    if ([specifier.identifier isEqualToString:kISHideBannersKey]) {
        if ([value intValue] == 1) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideBannersKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kISSettingsPath]];
            [defaults setObject:value forKey:kISHideBannersKey];
            [defaults writeToFile:kISSettingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.akeaswaran.isolate/ReloadSettings"), NULL, NULL, TRUE);
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/akeaswaran/"]];
}

@end

