

@interface IconoclastLayoutEngine : NSObject

+(instancetype)sharedInstance;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL perPageOn;
@property (nonatomic, retain) NSDictionary *preferences;
@property (nonatomic, retain, getter = _layout) IconoclastLayout *layout;
@property (nonatomic, retain) NSArray *perPageLayouts;

- (NSUInteger)maxIconsForPageIndex:(NSUInteger)index;
- (NSUInteger)rowsForPageIndex:(NSUInteger)index;
- (NSUInteger)columnsForPageIndex:(NSUInteger)index;
- (void)updateWithPreferences;
- (CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)coord inIconList:(SBIconListView *)list;

- (BOOL)hideLabelsForPageIndex:(NSUInteger)index;
@end 
