#import <UIKit/UIDevice.h>

// iPad identification
#define SBIMINSTANCE ((kCFCoreFoundationVersionNumber < 790.00) ? [objc_getClass("SBIconModel") sharedInstance] : [[objc_getClass("SBIconController") sharedInstance] model])
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
//#define isiPad (kCFCoreFoundationVersionNumber == kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
#define isiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// dict is easy grid?
#define isEasyGrid(x) [[x objectForKey:@"EasyGrid"] boolValue]

// which page is this?
#define whichPage_32(iL) (int)[[objc_getClass("SBIconModel") sharedInstance] indexOfIconList:iL]
#define whichPage_model(model) (unsigned)[[[objc_getClass("SBIconModel") sharedInstance] rootFolder] indexOfIconList:model]
#define whichPage_view(iL) whichPage_model([iL model])

// assuring you're not hooking the wrong icon view/model
#define isDock_32(iL) [iL isKindOfClass:NSClassFromString(@"SBButtonBar")]
#define notVirginModel(iM) ([iM class] != objc_getClass("SBIconListModel"))
//#define notVirginView(iL) ([iL class] != objc_getClass("SBIconListView)")
#define notVirginView(iL) ( \
    ([iL class] == objc_getClass("SBFolderIconListView")) || \
    ([iL class] == objc_getClass("SBDockIconListView")) || \
    ([iL class] == objc_getClass("SBNewsstandIconListView")) \
    )

#define maxIconsForPage(pageNum) [[layoutForPage(pageNum) origins] count]

// per-page wrapover stuff
#define getNextPage_view(index) [[objc_getClass("SBIconController") sharedInstance] iconListViewAtIndex:index+1 \
                                                                               inFolder:[SBIMINSTANCE rootFolder] \
                                                                      createIfNecessary:YES]
#define getNextPage_model(index) [getNextPage_view(index) model]

#define easyGridOn [defaultLayout isKindOfClass:[ICGridLayout class]]

#define ICPref(key) CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef) key,(CFStringRef) @"me.kritanta.iconoclast"))

#define Nint(i) [NSNumber numberWithInt:i]
#define Nbool(i) [NSNumber numberWithBool:i]
