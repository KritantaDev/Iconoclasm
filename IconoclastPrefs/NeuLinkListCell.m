#include <Preferences/PSTableCell.h>
#include <Preferences/PSSpecifier.h>
#include  <objc/runtime.h>

#define kMainColor [UIColor colorWithWhite:0.05 alpha:1.00]
#define kDarkerColor [UIColor colorWithWhite:0.02 alpha:1.00]
#define kBrighterColor [UIColor colorWithWhite:0.07 alpha:1.00]
#define kCornerRadius 14
#define kSideInset 15
#define kBufferSize kSideInset
#define kDeviceWidth [[UIScreen mainScreen] bounds].size.width
#define kToggleSize kDeviceWidth-60/3

@interface KRNeuLinkListCell : PSTableCell 
-(UIView*)valueLabel;
@end

@implementation KRNeuLinkListCell
- (UITableViewCellAccessoryType)accessoryType
{
    return UITableViewCellAccessoryNone;
}
-(BOOL)_accessoryViewsHidden
{
    return YES;
}
-(BOOL)forceHideDisclosureIndicator
{return YES;}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier 
{
	self = [super initWithStyle:style reuseIdentifier:nil specifier:specifier];
	CGFloat height = [specifier.properties[@"height"] floatValue];
	if (self) {
        self.frame = CGRectInset(self.frame, 15, 0);
        self.accessoryType = 0;
        self.backgroundColor = kMainColor;
        UIView *barContainer = [[UIView alloc] initWithFrame:CGRectMake(15,height-50,kDeviceWidth-(2*kSideInset),50)];
        UIView *backgroundView = [[UIView alloc] initWithFrame:(CGRectMake(0,0,kDeviceWidth,height))];
        backgroundView.backgroundColor = kMainColor;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake(0,0,kDeviceWidth,height);

        CAShapeLayer* shadowLayer = [CAShapeLayer layer];
        [shadowLayer setFrame:[barContainer bounds]];

        // Standard shadow stuff
        [shadowLayer setFillColor:[kMainColor CGColor]];
        [shadowLayer setShadowColor:[kBrighterColor CGColor]];
        [shadowLayer setShadowOffset:CGSizeMake(-5.0f, height!=60?.0f:-5.0f)];
        [shadowLayer setShadowOpacity:1.0f];
        [shadowLayer setShadowRadius:5];

        // Causes the inner region in this example to NOT be filled.
        //[shadowLayer setFillRule:kCAFillRuleEvenOdd];

        // Create the larger rectangle path.
        CGPathRef path = CGPathCreateWithRoundedRect(CGRectInset(barContainer.bounds, 0, height==60?0:-5), kCornerRadius, kCornerRadius, nil);

        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        //CGPathRef innerPath = CGPathCreateWithRoundedRect(CGRectInset(barContainer.bounds, -20, -20), kCornerRadius, kCornerRadius, nil);
        //CGPathAddPath(path, NULL, innerPath);
        //CGPathCloseSubpath(path);

        [shadowLayer setPath:path];
        CGPathRelease(path);


        CAShapeLayer* shadowLayer2 = [CAShapeLayer layer];
        [shadowLayer2 setFrame:[barContainer bounds]];
        [shadowLayer2 setFillColor:[kMainColor CGColor]];

        // Standard shadow stuff
        [shadowLayer2 setShadowColor:[kDarkerColor CGColor]];
        [shadowLayer2 setShadowOffset:CGSizeMake(5.0f, height!=60?.0f:5.0f)];
        [shadowLayer2 setShadowOpacity:1.0f];
        [shadowLayer2 setShadowRadius:5];

        // Causes the inner region in this example to NOT be filled.
        //[shadowLayer2 setFillRule:kCAFillRuleEvenOdd];

        // Create the larger rectangle path.
        path = CGPathCreateWithRoundedRect(CGRectInset(barContainer.bounds, 0, height==60?0:5), kCornerRadius, kCornerRadius, nil);

        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        //innerPath = CGPathCreateWithRoundedRect(CGRectInset(barContainer.bounds, -20, -20), kCornerRadius, kCornerRadius, nil);
        //CGPathAddPath(path, NULL, innerPath);
        //CGPathCloseSubpath(path);

        [shadowLayer2 setPath:path];

        CGPathRelease(path);



        shadowLayer.cornerRadius = kCornerRadius;
        shadowLayer2.cornerRadius = kCornerRadius;
        [[barContainer layer] addSublayer:shadowLayer];
        [[barContainer layer] addSublayer:shadowLayer2];

        //CAShapeLayer* maskLayer = [CAShapeLayer layer];
        //[maskLayer setPath:someInnerPath];
        //[shadowLayer setMask:maskLayer];
        barContainer.layer.cornerRadius = kCornerRadius;
        barContainer.layer.masksToBounds = NO;

        [self addSubview:barContainer];
        [self sendSubviewToBack:barContainer];
        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
    }

    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *i in self.subviews)
    {
        if ([i class] == objc_getClass("_UITableCellAccessoryButton"))
            [i removeFromSuperview];
    }
    self.contentView.frame = self.frame.size.height != 50 ? CGRectMake(15,5,kDeviceWidth,55) : CGRectMake(15,0,kDeviceWidth,50);
    self.valueLabel.frame = (CGRectOffset(self.valueLabel.frame, -15,0));
}
@end