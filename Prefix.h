#ifndef PREFIX_H
#define PREFIX_H

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface UIScreen (Private)
-(CGFloat)_displayCornerRadius;
@end

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

@interface SBIconModel 
- (void)layout;
@end

@interface SBIconListModel 

@property (nonatomic, retain) NSArray *icons;
@property (nonatomic, assign) NSUInteger iconoclast_pageIndex;
@property (nonatomic, retain) NSString *iconoclast_iconLocation;
@property (nonatomic, retain) NSString *uniqueIdentifier;
@property (nonatomic, assign) NSUInteger numberOfIcons;
@property (nonatomic, assign, readonly) NSUInteger maxNumberOfIcons;

@end

@interface SBIconListFlowLayout 

@property (nonatomic, assign) NSInteger iconoclast_pageIndex;
@property (nonatomic, retain) NSString *iconoclast_iconLocation;
@property (nonatomic, retain) id layoutConfiguration;
- (instancetype)initWithLayoutConfiguration:(id)thing;

@end

@interface SBIconListView : UIView

- (NSUInteger)indexForCoordinate:(SBIconCoordinate)c forOrientation:(NSUInteger)o;
- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)coord metrics:(SBIconListLayoutMetrics)arg2;

- (NSUInteger)layoutOrientation;
@property (nonatomic, strong) SBIconListFlowLayout *iconoclast_perPageLayout;
@property (nonatomic, assign) NSInteger iconoclast_pageIndex;
@property (nonatomic, retain) NSString *iconLocation;
@property (nonatomic, assign) NSUInteger iconsInRowForSpacingCalculation;
@property (nonatomic, retain) SBIconListModel *model;
-(void)setVisibleColumnRange:(NSRange)a;

@end


@interface SBIconView 

@property (nonatomic, retain) SBIconListFlowLayout *listLayout;

@end

#include "Iconoclast.h"

#endif