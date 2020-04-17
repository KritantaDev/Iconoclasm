@implementation IconoclastLayoutEngine

+(instancetype)sharedInstance
{
    static IconoclastLayoutEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] init];
    });
    return sharedEngine;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.enabled = NO;
        self.perPageOn = NO;
        [self updateWithPreferences];
    }

    return self;
}

- (void)updateWithPreferences
{
    self.enabled = [ICPref(@"Enable") boolValue];
    if (!self.enabled) return;

    self.perPageOn = [(NSNumber*)ICPref(@"PerPageLayoutsEnabled") boolValue];

    if (self.perPageOn)
    {
        self.perPageLayouts = [NSArray array];
        NSArray* perPageLayoutNames = [NSArray array];

        for (int i=0; i<11; i++) 
        {
            NSString* prefKey = [NSString stringWithFormat:@"PerPageLayout-Page%i", i];
            NSString* prefValue = ((NSString*) ICPref(prefKey) ?: @"Checkerboard");
            perPageLayoutNames = [perPageLayoutNames arrayByAddingObject:prefValue];
        }

        NSArray* layouts = [NSArray array];

        for (NSString* name in perPageLayoutNames) 
        {
            NSDictionary *x = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Iconoclast/Layouts/%@.plist", name]];
            if (x) layouts = [layouts arrayByAddingObject:x];
        }
        
        for (NSDictionary *i in layouts)
        {
            self.perPageLayouts = [self.perPageLayouts arrayByAddingObject:[IconoclastLayoutEngine createLayoutFromDictionary:i]];
        }
    }
    else 
    {
        NSString *layoutName = (NSString*)ICPref(@"CurrentLayout") ?: @"CheckerBoard";
        NSDictionary *layout = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Iconoclast/Layouts/%@.plist", layoutName]];
        self.layout = [IconoclastLayoutEngine createLayoutFromDictionary:layout];
    }

}

+ (IconoclastLayout *)createLayoutFromDictionary:(NSDictionary *)layoutDict
{
    IconoclastLayoutType type = ([layoutDict objectForKey:@"Origins"] 
                                    ? IconoclastLayoutTypeFreeform 
                                    : ([layoutDict objectForKey:@"Rows"] 
                                        || [layoutDict objectForKey:@"Cols"]
                                            ? IconoclastLayoutTypeEasyGrid
                                            : IconoclastLayoutTypeNone ));

    CGSize scale = (([layoutDict objectForKey:@"OriginalScale"] 
                        && ((NSDictionary*)[layoutDict objectForKey:@"OriginalScale"])[@"width"] 
                        && ((NSDictionary*)[layoutDict objectForKey:@"OriginalScale"])[@"height"])
                            ? CGSizeMake(
                                [((NSDictionary*)[layoutDict objectForKey:@"OriginalScale"])[@"width"] floatValue],
                                [((NSDictionary*)[layoutDict objectForKey:@"OriginalScale"])[@"height"] floatValue])  
                            : CGSizeMake(
                                375,
                                812
                            ));

    NSMutableArray *origins = [NSMutableArray new];
    
    int rows = 0;
    int cols = 0;
    int index = 0;

    if (type==IconoclastLayoutTypeEasyGrid)
    {
        for (NSNumber *i in (NSArray*)[layoutDict objectForKey:@"Rows"])
        {
            cols=0;
            for (NSNumber *j in (NSArray*)[layoutDict objectForKey:@"Cols"])
            {
                [origins addObject:
                    [NSValue valueWithCGPoint:
                        CGPointMake(
                            [j floatValue],
                            [i floatValue] )]];
                cols++;
                index++;
            }
            rows++;
        }
    }
    else if (type==IconoclastLayoutTypeFreeform)
    {
        for (NSDictionary *i in (NSArray*)[layoutDict objectForKey:@"Origins"])
        {
            [origins addObject:
                [NSValue valueWithCGPoint:
                    CGPointMake([[i valueForKey:@"x"] floatValue], [[i valueForKey:@"y"] floatValue])]];
            index++;
        }
    }
    BOOL hideLabels = NO;
    if ([layoutDict objectForKey:@"HideLabels"])
        hideLabels = [(NSNumber*)[layoutDict objectForKey:@"HideLabels"] boolValue];

    IconoclastLayout *layout = [[IconoclastLayout alloc] initWithOrigins:[origins copy] type:type scale:scale maxIcons:index maxRows:rows maxCols:cols hideLabels:hideLabels];

    return layout;
}

- (CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)coord inIconList:(SBIconListView *)list
{
    NSUInteger iconIndex = [list indexForCoordinate:coord forOrientation:[list layoutOrientation]];

    return (self.perPageOn 
                ? [self.perPageLayouts[[list iconoclast_pageIndex]] originForIconAtIndex:iconIndex]
                : [self.layout originForIconAtIndex:iconIndex] );
}

- (NSUInteger)maxIconsForPageIndex:(NSUInteger)index 
{
    return ( self.perPageOn 
            ? [self.perPageLayouts[MIN(index,10)] maxIcons]
            : [self.layout maxIcons] );
}

- (NSUInteger)rowsForPageIndex:(NSUInteger)index
{
    return ( self.perPageOn 
            ? [self.perPageLayouts[MIN(index,10)] rows]
            : [self.layout rows] );
}

- (NSUInteger)columnsForPageIndex:(NSUInteger)index
{
    return ( self.perPageOn 
            ? [self.perPageLayouts[MIN(index,10)] cols]
            : [self.layout cols] );
}

- (BOOL)hideLabelsForPageIndex:(NSUInteger)index 
{
    return ( self.perPageOn && [self.perPageLayouts count] > 0
        ? [self.perPageLayouts[MIN(index,10)] hideLabels]
        : [self.layout hideLabels] );
}

@end
