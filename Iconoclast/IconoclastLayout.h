typedef enum IconoclastLayoutType : NSUInteger {
    IconoclastLayoutTypeNone,
    IconoclastLayoutTypeEasyGrid,
    IconoclastLayoutTypeFreeform
} IconoclastLayoutType;

@interface IconoclastLayout : NSObject 

- (instancetype)initWithOrigins:(NSArray*)origins 
                           type:(IconoclastLayoutType)type 
                          scale:(CGSize)scale 
                       maxIcons:(int)maxicons 
                        maxRows:(int)rows 
                        maxCols:(int)cols 
                     hideLabels:(BOOL)labels;

@property (nonatomic, assign) IconoclastLayoutType type;
@property (nonatomic, assign) CGSize scale;
@property (nonatomic, retain) NSArray *origins;
@property (nonatomic, assign) NSUInteger maxIcons;
@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) NSUInteger cols;
@property (nonatomic, assign) BOOL hideLabels;

- (CGPoint)originForIconAtIndex:(NSUInteger)index;

@end
