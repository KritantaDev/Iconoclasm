#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSTableCell.h>
#include "NSTask.h"
#define kMainColor [UIColor colorWithWhite:0.05 alpha:1.00]
#define kDarkerColor [UIColor colorWithWhite:0.02 alpha:1.00]
#define kBrighterColor [UIColor colorWithWhite:0.07 alpha:1.00]
#define ICPref(key) CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef) key,(CFStringRef) @"me.kritanta.iconoclast"))

static BOOL infiniboardDylibSpotted() {
  return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Infiniboard.dylib"];
}

@interface IconoclastPrefsController : PSListController {
}
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end
@interface UITableView (Private)
-(void)_setTopPadding:(CGFloat)pad;
@end
@implementation IconoclastPrefsController

-(void) respring:(id)unused {
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
    [t launch];
}

-(NSString*) navigationTitle {
  return @"Iconoclast";
}

-(NSArray*) specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"IconoclastPrefs" target:self];
  }	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}
  return _specifiers;
}
-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"CurrentLayout"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"PerPageLayout-Page0"],self.savedSpecifiers[@"PerPageLayout-Page1"],self.savedSpecifiers[@"PerPageLayout-Page2"],self.savedSpecifiers[@"PerPageLayout-Page3"],self.savedSpecifiers[@"PerPageLayout-Page4"],self.savedSpecifiers[@"PerPageLayout-Page5"],self.savedSpecifiers[@"PerPageLayout-Page6"],self.savedSpecifiers[@"PerPageLayout-Page7"],self.savedSpecifiers[@"PerPageLayout-Page8"],self.savedSpecifiers[@"PerPageLayout-Page9"],self.savedSpecifiers[@"PerPageLayout-Page10"]] animated:YES];
}
-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	
	if (YES) {
		NSNumber *valueObj = (NSNumber *)ICPref(@"Enable");
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue && [ICPref(@"PerPageLayoutsEnabled") intValue] == 0) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"CurrentLayout"]] afterSpecifierID:@"switcher" animated:YES];
		}
		else if (valueObj.intValue == 0) { // If users chooses for URL
			//[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"PerPageLayout-Page0"],self.savedSpecifiers[@"PerPageLayout-Page1"],self.savedSpecifiers[@"PerPageLayout-Page2"],self.savedSpecifiers[@"PerPageLayout-Page3"],self.savedSpecifiers[@"PerPageLayout-Page4"],self.savedSpecifiers[@"PerPageLayout-Page5"],self.savedSpecifiers[@"PerPageLayout-Page6"],self.savedSpecifiers[@"PerPageLayout-Page7"],self.savedSpecifiers[@"PerPageLayout-Page8"],self.savedSpecifiers[@"PerPageLayout-Page9"],self.savedSpecifiers[@"PerPageLayout-Page10"]] afterSpecifierID:@"switcher" animated: YES];
		}
	}
}

-(NSArray*) layouts {
  NSArray* layoutsRaw = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Iconoclast/Layouts" error:nil];
  NSMutableArray* layoutsNoPlist = [NSMutableArray array];
  for (NSString* layout in layoutsRaw) {
    if ([layout hasSuffix:@".plist"])
      [layoutsNoPlist addObject:[layout stringByReplacingOccurrencesOfString:@".plist" withString:@""]];
  }
  return layoutsNoPlist;
}
-(NSInteger)navigationItemLargeTitleDisplayMode 
{
  return 1;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  [self.table setBackgroundColor:kMainColor];
  self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.table _setTopPadding:0];
  //self.navigationController.navigationBarHidden = YES;
  //self.navigationController.interactivePopGestureRecognizer.delegate = self;	
  [self setPreferenceValue:ICPref(@"Enabled") specifier:[self specifierForID:@"Enabled"]];
  UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(respring:)];
  respringButton.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
  self.navigationItem.rightBarButtonItem = respringButton;
}

// Called by "Enable Iconoclast"
// Used to prepare the SB for 4 columns and respring on toggle; may want to remove icon caches as well though that's minor
-(void) setToggle:(id)value specifier:(NSString*)specifier {
  [self setPreferenceValue:value specifier:specifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self respring:nil];
}

-(void) getMoreLayouts:(id)unused {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://sections/Addons%20(Iconoclast)"]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  PSTableCell *tableCell = (PSTableCell*)cell;
                tableCell.clipsToBounds = YES;
  BOOL heck = NO;
  if ([[tableCell titleLabel].text isEqualToString:@"Page 1"])
  {
    heck = YES;
  }
	int height = [tableCell.specifier.properties[@"height"] intValue];
  if (height==50 || heck)
  {
            CGFloat cornerRadius = 14.f;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.subviews[1].bounds, 0, 0);
            CGRect bounds2 = CGRectInset(cell.subviews[1].bounds, 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
            {
                
                tableCell.clipsToBounds = NO;return;CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            }
            else if (heck)
            {
                tableCell.clipsToBounds = YES;
                [tableCell.subviews[1].layer.sublayers[0] setShadowOffset:CGSizeMake(-5.0f, -5.0f)];
                [tableCell.subviews[1].layer.sublayers[1] setShadowOffset:CGSizeMake(5.0f, -.02f)];
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            }
            else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
            {tableCell.clipsToBounds = NO;
                [tableCell.subviews[1].layer.sublayers[1] setShadowOffset:CGSizeMake(5.0f, 5.0f)];
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            }
            else
            {
                CGPathAddRect(pathRef, nil, bounds2);
                //tableCell.subviews[1].layer.sublayers[0].shadowOpacity = 0;
                //tableCell.subviews[1].layer.sublayers[1].shadowOpacity = 0;
                addLine = YES;
            }

            for (CALayer *lay in tableCell.subviews[1].layer.sublayers)
            {
              ((CAShapeLayer*)lay).path = pathRef;
            }
            CFRelease(pathRef);
  } else {tableCell.clipsToBounds = NO;}
}

@end
