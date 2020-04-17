#include <objc/runtime.h>

static BOOL go = NO;
static BOOL go2 = NO;

static void writeBackground(UIImage *background)
{
    NSString *filePath = @"/Library/Application Support/Iconoclast.bundle/Website/DeviceBackground.png";
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (background.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * background.scale,
                          rect.origin.y * background.scale,
                          rect.size.width * background.scale,
                          rect.size.height * background.scale);
    }

    CGImageRef imageRef = CGImageCreateWithImageInRect(background.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:background.scale orientation:background.imageOrientation];
    CGImageRelease(imageRef);
    // Save image.
    [UIImagePNGRepresentation(result) writeToFile:filePath atomically:YES];
}



%hook SBFStaticWallpaperImageView

- (void)setImage:(UIImage *)img 
{
    %orig(img);
    writeBackground(img);
}

%end


%hook SBIconListView 

- (void)setVisibleColumnRange:(NSRange)range
{
    // We need to wait until icons have been initially loaded, at least, to do this. 
    // Otherwise it will completely screw up icon labels (wtf apple??)
    if (go2 && range.length !=0) range.length = self.iconsInRowForSpacingCalculation;
    %orig(range);
}

// Hook both setter and getter in case they aren't called consecutively
- (NSRange)visibleColumnRange 
{
    NSRange range = %orig;
    if (go2 && range.length !=0) range.length = self.iconsInRowForSpacingCalculation;
    return range;
}

%property (nonatomic, assign) NSInteger iconoclast_pageIndex;
%property (nonatomic, strong) SBIconListFlowLayout *iconoclast_perPageLayout;

- (CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)coord metrics:(struct SBIconListLayoutMetrics)arg2
{
    if (![self.iconLocation isEqualToString:@"SBIconLocationRoot"]) 
        return %orig;

    CGPoint point;

    @try
    {
        point = [[IconoclastLayoutEngine sharedInstance] originForIconAtCoordinate:coord inIconList:self];
    }
    @catch (NSException *ex)
    {
        point = %orig;
    }

    if (point.x == CGFLOAT_MIN)
        return %orig;

    return point;
}

- (id)layout 
{
    SBIconListFlowLayout *o = %orig;
    SBIconListFlowLayout *layout = [[%c(SBIconListFlowLayout) alloc] initWithLayoutConfiguration:[o layoutConfiguration]];

    layout.iconoclast_pageIndex = self.iconoclast_pageIndex;
    layout.iconoclast_iconLocation = self.iconLocation;

    self.model.iconoclast_pageIndex = self.iconoclast_pageIndex;
    self.model.iconoclast_iconLocation = self.iconLocation;

    return layout;
}

%end


%hook SBIconView 

- (BOOL)allowsLabelArea
{
    if (!go) return %orig;
    if ([[IconoclastLayoutEngine sharedInstance] hideLabelsForPageIndex:self.listLayout.iconoclast_pageIndex])
        return NO;
        
    return %orig;
}

%end


%hook SBIconListFlowLayout

%property (nonatomic, assign) NSUInteger iconoclast_pageIndex;
%property (nonatomic, assign) NSString *iconoclast_iconLocation;

- (NSUInteger)maximumIconCount 
{
    @try
    {
        return (([self.iconoclast_iconLocation isEqualToString:@"SBIconLocationRoot"]
                    && [[IconoclastLayoutEngine sharedInstance] maxIconsForPageIndex:self.iconoclast_pageIndex] > 0 ) 
                        ? [[IconoclastLayoutEngine sharedInstance] maxIconsForPageIndex:self.iconoclast_pageIndex]
                        : %orig);
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}

- (NSUInteger)numberOfRowsForOrientation:(NSInteger)ori 
{
    @try
    {
        return (([self.iconoclast_iconLocation isEqualToString:@"SBIconLocationRoot"]
                    && [[IconoclastLayoutEngine sharedInstance] rowsForPageIndex:self.iconoclast_pageIndex] > 0 )
                        ? [[IconoclastLayoutEngine sharedInstance] rowsForPageIndex:self.iconoclast_pageIndex]
                        : %orig);
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}

- (NSUInteger)numberOfColumnsForOrientation:(NSInteger)ori 
{
    @try
    {
        return (([self.iconoclast_iconLocation isEqualToString:@"SBIconLocationRoot"]
                    && [[IconoclastLayoutEngine sharedInstance] columnsForPageIndex:self.iconoclast_pageIndex] > 0 )
                        ? [[IconoclastLayoutEngine sharedInstance] columnsForPageIndex:self.iconoclast_pageIndex]
                        : %orig);
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}

%end


%hook SBIconListModel 

%property (nonatomic, assign) NSUInteger iconoclast_pageIndex;
%property (nonatomic, retain) NSString *iconoclast_iconLocation;

// This is a read-only property, assigned on init
// For some odd reason, the ivar doesn't want us to modify it at all. 

// So, first we need to hook the selector
- (NSInteger)maxNumberOfIcons
{
    @try
    {
        return (([self.iconoclast_iconLocation isEqualToString:@"SBIconLocationRoot"]
                    && [[IconoclastLayoutEngine sharedInstance] maxIconsForPageIndex:self.iconoclast_pageIndex] > 0 )
                        ? [[IconoclastLayoutEngine sharedInstance] maxIconsForPageIndex:self.iconoclast_pageIndex]
                        : %orig);
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}

// This method uses the ivar that refuses to change
// So, we need to rewrite the entire method to properly use the selector we want to use,
//      instead of the ivars
- (NSUInteger)firstFreeSlotIndex
{
    if ([self numberOfIcons] >= [self maxNumberOfIcons])
        return 0x7FFFFFFFFFFFFFFFLL;

    return [self numberOfIcons];
}

// Same issue as last one, used ivars but we want it to use our selector instead
- (BOOL)isFullIncludingPlaceholders
{
    return ([[self icons] count] >= [self maxNumberOfIcons]);
}

%end


%hook SBRootFolderView 

// Quick hack to assign a page index to an SBIconListView. Always gets called. 
- (id)iconListViewAtIndex:(NSUInteger)index 
{
    SBIconListView *orig = %orig(index);

    orig.iconoclast_pageIndex = index;

    return orig;
}

%end

%hook SBIconModel

- (void)layout 
{
    %orig;
    if (!go) return;
    [[IconoclastLayoutEngine sharedInstance] updateWithPreferences];
    go2 = YES;
}

%end


%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
    %orig;
    go = YES;
}

%end


#define KEY @"IconoclastIconState"

%hook SBDefaultIconModelStore

- (id)loadCurrentIconState:(id*)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:KEY]) {
        return [defaults objectForKey:KEY];
    }

    id orig = %orig;
    [defaults setObject:orig forKey:KEY];
    return orig;
}

- (BOOL)saveCurrentIconState:(id)state error:(id*)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:KEY];
    return %orig;
}

%end

static void *observer;

static void preferencesChanged()
{
    [SBIMINSTANCE layout];
}

%ctor {
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        (CFNotificationCallback)preferencesChanged,
        (CFStringRef)@"me.kritanta.iconoclast/Prefs",
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
}