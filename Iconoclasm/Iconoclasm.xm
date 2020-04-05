
#include "Iconoclasm.h"
#include <objc/runtime.h>

static NSDictionary *layout;
static NSMutableDictionary *modelUUIDToIndex;
static BOOL perPageOn;
static NSArray *perPageLayouts;

#define IconListLayout (perPageOn && self.iconoclasm_pageIndex ? perPageLayouts[self.iconoclasm_pageIndex] : layout)

typedef struct SBIconListLayoutMetrics {
    unsigned long long _field1;
    unsigned long long _field2;
    struct CGSize _field3;
    struct CGSize _field4;
    double _field5;
    struct UIEdgeInsets _field6;
    _Bool _field7;
    _Bool _field8;
} SBIconListLayoutMetrics;

typedef struct SBIconCoordinate {
  NSUInteger row;
  NSUInteger col;
} SBIconCoordinate;
@interface SBIconListModel 

@property (nonatomic, assign) NSUInteger iconoclasm_pageIndex;
@property (nonatomic, retain) NSString *iconoclasm_iconLocation;
@property (nonatomic, assign) NSUInteger numberOfIcons;
@property (nonatomic, assign, readonly) NSUInteger maxNumberOfIcons;
@end
@interface SBIconListFlowLayout 

@property (nonatomic, assign) NSInteger iconoclasm_pageIndex;
@property (nonatomic, retain) NSString *iconoclasm_iconLocation;
@end
@interface SBIconListView : UIView

-(NSUInteger)indexForCoordinate:(SBIconCoordinate)c forOrientation:(NSUInteger)o;

-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)coord metrics:(SBIconListLayoutMetrics)arg2;
@property (nonatomic, strong) SBIconListFlowLayout *iconoclasm_perPageLayout;
@property (nonatomic, assign) NSInteger iconoclasm_pageIndex;
@property (nonatomic, retain) NSString *iconLocation;
@property (nonatomic, retain) SBIconListModel *model;
@end

@interface IconoclasmLayoutServer : NSObject
+(CGFloat)topOffset;
+(CGFloat)leftOffset;
@end
@implementation IconoclasmLayoutServer
+(CGFloat)topOffset
{
    return 0;
}
+(CGFloat)leftOffset
{
    return 0;
}
@end

%hook SBIconListView 

%property (nonatomic, assign) NSInteger iconoclasm_pageIndex;
%property (nonatomic, strong) SBIconListFlowLayout *iconoclasm_perPageLayout;

-(CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)coord metrics:(struct SBIconListLayoutMetrics)arg2
{
    //int page = indexOfList([self model]);
    if ( ![self.iconLocation isEqualToString:@"SBIconLocationRoot"]) return %orig;

    int x = coord.col-1;
    int y = coord.row-1;

    NSUInteger index = [self indexForCoordinate:coord forOrientation:1];
    if (index > [[IconListLayout objectForKey:@"Origins"] count]-1) return %orig;
    CGPoint point;
    @try{
        if ([IconListLayout objectForKey:@"Origins"])
        {
            point = CGPointMake([[[IconListLayout objectForKey:@"Origins"][index] valueForKey:@"x"] floatValue], [[[IconListLayout objectForKey:@"Origins"][index] valueForKey:@"y"] floatValue]);
        }
        else 
            point = CGPointMake([(NSNumber*)(((NSArray*)[IconListLayout objectForKey:@"Cols"])[x]) floatValue],[(NSNumber*)(((NSArray*)[IconListLayout objectForKey:@"Rows"])[y]) floatValue]);
    
        point.x *= (self.frame.size.height / 640);
        point.y *= (self.frame.size.width / 378);
        //point.y += 40;
        point.x += 10;
        point.x += [IconoclasmLayoutServer leftOffset];
        point.y += [IconoclasmLayoutServer topOffset];
    }
    @catch (NSException *ex){
        point = %orig;
    }

    return point;
}

- (id)layout 
{
    if (!perPageOn 
        || self.iconoclasm_pageIndex > 30 
        || ![self.iconLocation isEqualToString:@"SBIconLocationRoot"]) 
        return %orig;

    SBIconListFlowLayout *o = %orig;
    SBIconListFlowLayout *layout = [[%c(SBIconListFlowLayout) alloc] initWithLayoutConfiguration:[o layoutConfiguration]];
    layout.iconoclasm_pageIndex = self.iconoclasm_pageIndex;
    layout.iconoclasm_iconLocation = self.iconLocation;
    self.model.iconoclasm_pageIndex = self.iconoclasm_pageIndex;
    self.model.iconoclasm_iconLocation = self.iconLocation;

    return layout;
}

%end

%hook SBIconView 
-(BOOL)allowsLabelArea
{
    return NO;
}
%end
%hook SBIconListFlowLayout

%property (nonatomic, assign) NSUInteger iconoclasm_pageIndex;
%property (nonatomic, retain) NSString *iconoclasm_iconLocation;

-(NSUInteger)maximumIconCount 
{
    @try
    {
        if (!layout || ![self.iconoclasm_iconLocation isEqualToString:@"SBIconLocationRoot"]) 
            return %orig;

        if ([IconListLayout objectForKey:@"Origins"])
            return [[IconListLayout objectForKey:@"Origins"] count];
        
        return %orig;
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}
-(NSUInteger)numberOfRowsForOrientation:(NSInteger)ori 
{
    @try
    {
        if (!layout 
            || ![self.iconoclasm_iconLocation isEqualToString:@"SBIconLocationRoot"]) 
            return %orig;

        return [((NSArray*)[IconListLayout objectForKey:@"Rows"]) count] > 0 ?[((NSArray*)[IconListLayout objectForKey:@"Rows"]) count]: %orig;
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}
-(NSUInteger)numberOfColumnsForOrientation:(NSInteger)ori 
{
    @try
    {
        if (!layout 
            || ![self.iconoclasm_iconLocation isEqualToString:@"SBIconLocationRoot"]) 
            return %orig;
        return [((NSArray*)[IconListLayout objectForKey:@"Cols"]) count] > 0 ?[((NSArray*)[IconListLayout objectForKey:@"Cols"]) count]: %orig;
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}

%end

%hook SBIconListModel 

%property (nonatomic, assign) NSUInteger iconoclasm_pageIndex;
%property (nonatomic, retain) NSString *iconoclasm_iconLocation;

-(NSInteger)maxNumberOfIcons
{
    @try
    {
        if (!layout || ![self.iconoclasm_iconLocation isEqualToString:@"SBIconLocationRoot"]) 
            return %orig;

        if ([IconListLayout objectForKey:@"Origins"])
            return [[IconListLayout objectForKey:@"Origins"] count];
        
        else if ([((NSArray*)[IconListLayout objectForKey:@"Cols"]) count] > 0 
                    && [((NSArray*)[IconListLayout objectForKey:@"Rows"]) count] > 0 )
            return [((NSArray*)[IconListLayout objectForKey:@"Cols"]) count] * [((NSArray*)[IconListLayout objectForKey:@"Rows"]) count];
        
        return %orig;
    }
    @catch (NSException *ex)
    {
        return %orig;
    }
}
-(NSUInteger)firstFreeSlotIndex
{
    if ([self numberOfIcons] >= [self maxNumberOfIcons])
        return 0x7FFFFFFFFFFFFFFFLL;
    return [self numberOfIcons];
}
-(BOOL)isFullIncludingPlaceholders
{
    return ([[self icons] count] >= [self maxNumberOfIcons]);
}
%end

%hook SBRootFolderView 

-(id)iconListViewAtIndex:(NSUInteger)index 
{
    SBIconListView *orig = %orig(index);
    orig.iconoclasm_pageIndex = index;
    modelUUIDToIndex[[orig.model uniqueIdentifier]] = [NSNumber numberWithInteger:index];
    return orig;
}

%end
%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{
    %orig;

    NSNumber* perPageOnNum = (NSNumber*) ICPref(@"PerPageLayoutsEnabled");
    perPageOn = [perPageOnNum boolValue];
    if (perPageOn) {
        NSArray* _perPageLayoutNames = [NSArray array];

        for (int i=0; i<11; i++) 
        {
            NSString* prefKey = [NSString stringWithFormat:@"PerPageLayout-Page%i", i];
            NSString* prefValue = ((NSString*) ICPref(prefKey) ?: @"Five-Column SB (5x4)");
            _perPageLayoutNames = [_perPageLayoutNames arrayByAddingObject:prefValue];
        }

        NSArray *perPageLayoutNames = [_perPageLayoutNames retain];

        NSInteger perPageMaxIcons = INT_MIN;

        NSArray* _layouts = [NSArray array];
        for (NSString* name in perPageLayoutNames) {
            NSDictionary *x = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Iconoclasm/Layouts/%@.plist", name]];
            if (x) _layouts = [_layouts arrayByAddingObject:x];
        }
        perPageLayouts = [_layouts retain];
    }
}
%end

#define KEY @"IconoclasmIconState"

%hook SBDefaultIconModelStore

-(id)loadCurrentIconState:(id*)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:KEY]) {
        return [defaults objectForKey:KEY];
    }

    id orig = %orig;
    [defaults setObject:orig forKey:KEY];
    return orig;
}

-(BOOL)saveCurrentIconState:(id)state error:(id*)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:KEY];
    return %orig;
}

%end

%ctor {
    NSString *defLayoutName = [(NSString*)ICPref(@"CurrentLayout") retain] ?: @"Five-Column SB (5x4)";
    layout = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Iconoclasm/Layouts/%@.plist", defLayoutName]];
    modelUUIDToIndex = [NSMutableDictionary new];
}