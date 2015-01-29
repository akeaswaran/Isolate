#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTextFieldSpecifier.h>
#import "../Headers.h"

@interface IsolatePrefsListController : PSListController {
}
@end

@implementation IsolatePrefsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        [self setTitle:@"Isol8"];

        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Options"];
        [firstGroup setProperty:@"If Keyword Unmuting is enabled, then messages containing keywords will be unmuted." forKey:@"footerText"];

        PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [enabled setIdentifier:kISEnabledKey];
        [enabled setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *keywordUnmuting = [PSSpecifier preferenceSpecifierNamed:@"Enable Keyword Unmuting"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [keywordUnmuting setIdentifier:kISKeywordsEnabledKey];
        [keywordUnmuting setProperty:@(YES) forKey:@"enabled"];

        PSTextFieldSpecifier *keywordsField = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Keywords" target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:Nil cell:PSEditTextCell edit:Nil];
        [keywordsField setPlaceholder:@"john jappleseed"];
        [keywordsField setIdentifier:kISKeywordsKey];
        [keywordsField setProperty:@(YES) forKey:@"enabled"];
        [keywordsField setKeyboardType:UIKeyboardTypeASCIICapable autoCaps:UITextAutocapitalizationTypeWords autoCorrection:UITextAutocorrectionTypeYes];

        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"Developer"];
        [secondGroup setProperty:@"This tweak is open source. You can check out this and other projects on my GitHub." forKey:@"footerText"];

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
        [specifiers addObject:keywordUnmuting];
        [specifiers addObject:keywordsField];

        [specifiers addObject:secondGroup];
        [specifiers addObject:github];
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kISSettingsPath];
    if (settings[specifier.identifier]) {
        if (![specifier.identifier isEqual:kISKeywordsKey]) {
            NSNumber *settingEnabled = settings[specifier.identifier];
            if (settingEnabled.intValue == 1) {
                return [NSNumber numberWithBool:YES];
            } else {
                return [NSNumber numberWithBool:NO];
            }
        } else {
            return settings[specifier.identifier];
        }
    }
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
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
