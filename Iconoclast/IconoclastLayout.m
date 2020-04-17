@implementation IconoclastLayout 

- (instancetype)initWithOrigins:(NSArray*)origins 
                           type:(IconoclastLayoutType)type 
                          scale:(CGSize)scale 
                       maxIcons:(int)maxicons 
                        maxRows:(int)rows 
                        maxCols:(int)cols
                     hideLabels:(BOOL)hide;
{
    self = [super init];

    if (self)
    {
        self.origins = origins;
        self.type = type;
        self.scale = scale;
        self.maxIcons = maxicons;
        self.rows = rows;
        self.cols = cols;
        self.hideLabels = hide;
    }

    return self;
}

- (CGPoint)originForIconAtIndex:(NSUInteger)index
{
    if (self.type = IconoclastLayoutTypeNone) 
        return CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);

    CGFloat x = [self.origins[index] CGPointValue].x / self.scale.width * [[UIScreen mainScreen] bounds].size.width;
    CGFloat y = [self.origins[index] CGPointValue].y / self.scale.height * [[UIScreen mainScreen] bounds].size.height;
    y+=[[UIScreen mainScreen] _displayCornerRadius]/2;
    return CGPointMake(x,y);
}

@end
