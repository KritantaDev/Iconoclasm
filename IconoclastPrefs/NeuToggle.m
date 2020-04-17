#include "/Users/kritanta/ios/tweaks/Iconoclast/Iconoclast/ICMacros.h"
#include <Preferences/PSTableCell.h>
#include <AudioToolbox/AudioToolbox.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
@interface IconoclastPrefsController : PSListController {
}
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end
#define kMainColor [UIColor colorWithWhite:0.05 alpha:1.00]
#define kDarkerColor [UIColor colorWithWhite:0.02 alpha:1.00]
#define kBrighterColor [UIColor colorWithWhite:0.07 alpha:1.00]
#define kCornerRadius 14
#define kSideInset 15
#define kDeviceWidth [[UIScreen mainScreen] bounds].size.width
#define kToggleSize (kDeviceWidth-60)/3
#define fakeCopy(what) [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:what]]
#define ICPref(key) CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef) key,(CFStringRef) @"me.kritanta.iconoclast"))
static CALayer *enabledLayer;
static CALayer *disabledLayer;
@interface PSTableCell (Private)

-(IconoclastPrefsController *)_viewControllerForAncestor;
@end
@interface KRNeuToggleBar : PSTableCell 
@end

static UIImpactFeedbackGenerator *pressGenerator;
@implementation KRNeuToggleBar

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier 
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {

        self.backgroundColor = kMainColor;
        UIView *barContainer = [[UIView alloc] initWithFrame:CGRectMake(15,0,kDeviceWidth-(kSideInset*2),kToggleSize+15)];
        self.contentView.backgroundColor = kMainColor;
        
        UIControl *buttonOne = [[UIControl alloc] initWithFrame:(CGRectMake(0,0,kToggleSize,kToggleSize))];
        buttonOne.backgroundColor = kMainColor;

        CAShapeLayer* shadowLayerInnerTopLeft = [CAShapeLayer layer];
        [shadowLayerInnerTopLeft setFrame:[buttonOne bounds]];
        [shadowLayerInnerTopLeft setShadowColor:[kDarkerColor CGColor]];
        [shadowLayerInnerTopLeft setShadowOffset:CGSizeMake(20.0f, 20.0f)];
        [shadowLayerInnerTopLeft setShadowOpacity:1.0f];
        [shadowLayerInnerTopLeft setShadowRadius:5];
        [shadowLayerInnerTopLeft setFillRule:kCAFillRuleEvenOdd];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectInset(buttonOne.bounds, -42, -42));
        CGPathRef innerPath = CGPathCreateWithRoundedRect(CGRectInset(buttonOne.bounds, -20, -20), kCornerRadius, kCornerRadius, nil);
        CGPathAddPath(path, NULL, innerPath);
        CGPathCloseSubpath(path);
        [shadowLayerInnerTopLeft setPath:path];
        CGPathRelease(path);

        CAShapeLayer* shadowLayerInnerBottomRight = fakeCopy(shadowLayerInnerTopLeft);
        [shadowLayerInnerBottomRight setShadowColor:[kBrighterColor CGColor]];
        [shadowLayerInnerBottomRight setShadowOffset:CGSizeMake(-20.0f, -20.0f)];

        enabledLayer = fakeCopy([buttonOne layer]);
        enabledLayer.masksToBounds = YES;
        enabledLayer.cornerRadius = kCornerRadius;
        [enabledLayer addSublayer:shadowLayerInnerTopLeft];
        [enabledLayer addSublayer:shadowLayerInnerBottomRight];

        CAShapeLayer* shadowLayerOuterTopLeft = [CAShapeLayer layer];
        [shadowLayerOuterTopLeft setFrame:[buttonOne bounds]];
        [shadowLayerOuterTopLeft setShadowColor:[kBrighterColor CGColor]];
        [shadowLayerOuterTopLeft setShadowOffset:CGSizeMake(-5.0f, -5.0f)];
        [shadowLayerOuterTopLeft setShadowOpacity:.7f];
        [shadowLayerOuterTopLeft setShadowRadius:5];
        [shadowLayerOuterTopLeft setFillColor:[kMainColor CGColor]];
        path = CGPathCreateWithRoundedRect(CGRectInset(buttonOne.bounds, 0,0), kCornerRadius, kCornerRadius, nil);
        [shadowLayerOuterTopLeft setPath:path];
        CGPathRelease(path);
        CAShapeLayer* shadowLayerOuterBottomRight = fakeCopy(shadowLayerOuterTopLeft);
        [shadowLayerOuterBottomRight setShadowColor:[kDarkerColor CGColor]];
        [shadowLayerOuterBottomRight setShadowOffset:CGSizeMake(5.0f, 5.0f)];

        disabledLayer = fakeCopy([buttonOne layer]);
        [disabledLayer addSublayer:shadowLayerOuterBottomRight];
        [disabledLayer addSublayer:shadowLayerOuterTopLeft];


        [buttonOne.layer addSublayer:fakeCopy(enabledLayer)];
        [buttonOne.layer addSublayer:fakeCopy(disabledLayer)];
        buttonOne.layer.sublayers[[(NSNumber*)(ICPref(@"Enable")) intValue] ? 1 : 0].opacity = 0;

        //buttonOne.layer.masksToBounds = [(NSNumber*)(ICPref(@"Enable")) boolValue];


        UILabel *enableTweakLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonOne.frame.size.height/2 - 22,buttonOne.frame.size.width, 44)];
        [enableTweakLabel setText:@"Enable\nTweak"];
        [enableTweakLabel setFont:[UIFont systemFontOfSize:16]];
        enableTweakLabel.numberOfLines = 2;
        enableTweakLabel.textColor=[UIColor whiteColor];
        enableTweakLabel.textAlignment=NSTextAlignmentCenter;
        
        [buttonOne addSubview:enableTweakLabel];

        UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(kCornerRadius*1.5, kToggleSize-kCornerRadius, kToggleSize-kCornerRadius*3, 4)];
        indicator.backgroundColor = [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
        indicator.layer.shadowColor =  [[UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00] CGColor];
        indicator.layer.shadowOffset = CGSizeMake(0,0);
        indicator.layer.shadowOpacity = 1;
        indicator.layer.shadowRadius = 2;
        indicator.layer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(indicator.bounds, 0, 0), 2, 2, nil);
        indicator.layer.cornerRadius = 2;

        [buttonOne addSubview:indicator];

        [barContainer addSubview:buttonOne];

        /* 2 */
        
        UIControl *buttonTwo = [[UIControl alloc] initWithFrame:(CGRectMake(120,0,kToggleSize,kToggleSize))];
        buttonTwo.backgroundColor = kMainColor;

        [buttonTwo.layer addSublayer:fakeCopy(enabledLayer)];
        [buttonTwo.layer addSublayer:fakeCopy(disabledLayer)];
        buttonTwo.layer.cornerRadius = kCornerRadius;
        buttonTwo.layer.sublayers[[(NSNumber*)(ICPref(@"PerPageLayoutsEnabled")) boolValue] ? 1 : 0].opacity = 0;
        //buttonTwo.layer.masksToBounds = [(NSNumber*)(ICPref(@"PerPageLayoutsEnabled")) boolValue];

        UILabel *enableTweakLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonOne.frame.size.height/2 - 36,buttonOne.frame.size.width, 66)];
        [enableTweakLabel2 setText:@"Page\nSpecific\nLayouts"];
        [enableTweakLabel2 setFont:[UIFont systemFontOfSize:16]];
        enableTweakLabel2.numberOfLines = 3;
        enableTweakLabel2.textColor=[UIColor whiteColor];
        enableTweakLabel2.textAlignment=NSTextAlignmentCenter;
        
        [buttonTwo addSubview:enableTweakLabel2];

        UIView *indicator2 = [[UIView alloc] initWithFrame:CGRectMake(kCornerRadius*1.5, kToggleSize-kCornerRadius, kToggleSize-kCornerRadius*3, 4)];
        indicator2.backgroundColor = [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
        indicator2.layer.shadowColor =  [[UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00] CGColor];
        indicator2.layer.shadowOffset = CGSizeMake(0,0);
        indicator2.layer.shadowOpacity = 1;
        indicator2.layer.shadowRadius = 2;
        indicator2.layer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(indicator.bounds, 0, 0), 2, 2, nil);
        indicator2.layer.cornerRadius = 2;

        [buttonTwo addSubview:indicator2];

        [barContainer addSubview:buttonTwo];

        [buttonOne addTarget:self action:@selector(button1ProperlyActivated:) forControlEvents:UIControlEventTouchUpInside];
        [buttonOne addTarget:self action:@selector(button1Pressed:) forControlEvents:UIControlEventTouchDown];
        [buttonOne addTarget:self action:@selector(buttonDraggedOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [buttonOne addTarget:self action:@selector(buttonDraggedInside:) forControlEvents:UIControlEventTouchDragInside];
        [buttonTwo addTarget:self action:@selector(button2ProperlyActivated:) forControlEvents:UIControlEventTouchUpInside];
        [buttonTwo addTarget:self action:@selector(button2Pressed:) forControlEvents:UIControlEventTouchDown];
        [buttonTwo addTarget:self action:@selector(buttonDraggedOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [buttonTwo addTarget:self action:@selector(buttonDraggedInside:) forControlEvents:UIControlEventTouchDragInside];

        /* 3 */
        
        UIView *buttonThree = [[UIView alloc] initWithFrame:(CGRectMake(240,0,kToggleSize,kToggleSize))];
        buttonThree.backgroundColor = kMainColor;

        [buttonThree.layer addSublayer:fakeCopy(disabledLayer)];



        //CAShapeLayer* maskLayer = [CAShapeLayer layer];
        //[maskLayer setPath:someInnerPath];
        //[shadowLayerInnerTopLeft setMask:maskLayer];
        buttonThree.layer.cornerRadius = kCornerRadius;
        //buttonThree.layer.masksToBounds = YES;


        UILabel *enableTweakLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonOne.frame.size.height/2 - 22,buttonOne.frame.size.width, 44)];
        [enableTweakLabel3 setText:@"Coming\nSoon!"];
        [enableTweakLabel3 setFont:[UIFont systemFontOfSize:16]];
        enableTweakLabel3.numberOfLines = 2;
        enableTweakLabel3.textColor=[UIColor whiteColor];
        enableTweakLabel3.textAlignment=NSTextAlignmentCenter;
        
        [buttonThree addSubview:enableTweakLabel3];

        UIView *indicator3 = [[UIView alloc] initWithFrame:CGRectMake(kCornerRadius*1.5, kToggleSize-kCornerRadius, kToggleSize-kCornerRadius*3, 4)];
        indicator3.backgroundColor = [UIColor blackColor];
        indicator3.layer.shadowColor = [[UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00] CGColor];
        indicator3.layer.shadowOffset = CGSizeMake(0,0);
        indicator3.layer.shadowOpacity = 0;
        indicator3.layer.shadowRadius = 2;
        indicator3.layer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(indicator.bounds, 0, 0), 2, 2, nil);
        indicator3.layer.cornerRadius = 2;

        [buttonThree addSubview:indicator3];

        [barContainer addSubview:buttonThree];

        [self.contentView addSubview:barContainer];

    pressGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [pressGenerator prepare];
        //buttonTwo.layer = (ICPref(@"PerPageLayoutsEnabled")) ? fakeCopy(enabledLayer) : fakeCopy(disabledLayer);

    CFPreferencesAppSynchronize((CFStringRef)@"me.kritanta.iconoclast");
            BOOL e = ![(NSNumber*)(ICPref(@"PerPageLayoutsEnabled")) boolValue];
        [UIView animateWithDuration:.00 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
            buttonTwo.layer.sublayers[e ? 0 : 1].opacity = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.00 delay:0.00 options:UIViewAnimationOptionCurveLinear  animations:^{
                    buttonTwo.layer.sublayers[e ? 1 : 0].opacity = 1;
                    buttonTwo.subviews[1].layer.shadowOpacity = e ? 0 : 1;
                    buttonTwo.subviews[1].backgroundColor = e ? [UIColor blackColor] : [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
                } completion:^(BOOL finished) {
                }];
            }];    e = ![(NSNumber*)(ICPref(@"Enable")) boolValue];
    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        buttonOne.layer.sublayers[e ? 0 : 1].opacity = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
                buttonOne.layer.sublayers[e ? 1 : 0].opacity = 1;
                buttonOne.subviews[1].layer.shadowOpacity = e ? 0 : 1;
                buttonOne.subviews[1].backgroundColor = e ? [UIColor blackColor] : [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
            } completion:^(BOOL finished) {
            }];
        }];    
    }

    return self;
}
-(void)button1ProperlyActivated:(UIButton*)button
{
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    BOOL e = [(NSNumber*)(ICPref(@"Enable")) boolValue];
    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        button.layer.sublayers[e ? 0 : 1].opacity = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
                button.layer.sublayers[e ? 1 : 0].opacity = 1;
                button.subviews[1].layer.shadowOpacity = e ? 0 : 1;
                button.subviews[1].backgroundColor = e ? [UIColor blackColor] : [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
            } completion:^(BOOL finished) {
            }];
        }];    
    CFPreferencesAppSynchronize((CFStringRef)@"me.kritanta.iconoclast");
    CFPreferencesSetValue((CFStringRef)@"Enable", (CFPropertyListRef)([NSNumber numberWithBool:!e]), (CFStringRef)@"me.kritanta.iconoclast", CFSTR("mobile"), kCFPreferencesAnyHost);
  [[self _viewControllerForAncestor] setPreferenceValue:@"Enabled" specifier:[[self _viewControllerForAncestor] specifierForID:@"Enabled"]];
}

-(void)button2ProperlyActivated:(UIButton*)button
{
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    BOOL e = [(NSNumber*)(ICPref(@"PerPageLayoutsEnabled")) boolValue];
    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        button.layer.sublayers[e ? 0 : 1].opacity = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.04 delay:0.08 options:UIViewAnimationOptionCurveLinear  animations:^{
                button.layer.sublayers[e ? 1 : 0].opacity = 1;
                button.subviews[1].layer.shadowOpacity = e ? 0 : 1;
                button.subviews[1].backgroundColor = e ? [UIColor blackColor] : [UIColor colorWithRed:0.06 green:0.44 blue:0.27 alpha:1.00];
            } completion:^(BOOL finished) {
            }];
        }];
    CFPreferencesAppSynchronize((CFStringRef)@"me.kritanta.iconoclast");
    CFPreferencesSetValue((CFStringRef)@"PerPageLayoutsEnabled", (CFPropertyListRef)([NSNumber numberWithBool:!e]), (CFStringRef)@"me.kritanta.iconoclast", CFSTR("mobile"), kCFPreferencesAnyHost);
  [[self _viewControllerForAncestor] setPreferenceValue:@"Enabled" specifier:[[self _viewControllerForAncestor] specifierForID:@"Enabled"]];
}

-(void)button1Pressed:(UIButton*)button 
{
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    BOOL e = [(NSNumber*)(ICPref(@"Enable")) boolValue];
    if (e) return;
    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        button.layer.sublayers[e ? 0 : 1].opacity = 0;
        button.layer.sublayers[!e ? 0 : 1].opacity = 1;
        } completion:^(BOOL finished) {
            [pressGenerator impactOccurred];
            [pressGenerator prepare];
        }];
}
-(void)button2Pressed:(UIButton*)button 
{
    [pressGenerator impactOccurred];
    [pressGenerator prepare];
    BOOL e = [(NSNumber*)(ICPref(@"PerPageLayoutsEnabled")) boolValue];
    if (e) return;
    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        button.layer.sublayers[e ? 0 : 1].opacity = 0;
        button.layer.sublayers[!e ? 0 : 1].opacity = 1;
        } completion:^(BOOL finished) {
            [pressGenerator impactOccurred];
            [pressGenerator prepare];
        }];
}
-(void)buttonDraggedOutside:(UIButton*)button 
{
    //AudioServicesPlaySystemSound(1102);
}
-(void)buttonDraggedInside:(UIButton*)button 
{
    //AudioServicesPlaySystemSound(1519);
}
@end