#import "GCDWebServer.h"
#include <CoreGraphics/CoreGraphics.h>
#include <UIKit/UIKit.h>
#import "GCDWebServerDataResponse.h"
#include "GCDWebServerURLEncodedFormRequest.h"
#include <sys/utsname.h>

int main(void)
{
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    // Add a default handler to serve static files (i.e. anything other than HTML files)
    GCDWebServer* webServer = [[GCDWebServer alloc] init];
    [webServer addGETHandlerForBasePath:@"/" directoryPath:[[NSBundle bundleWithPath:@"/Library/Application Support/Iconoclast.bundle"] pathForResource:@"Website" ofType:nil] indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:YES];
    [webServer startWithPort:80 bonjourName:nil];
    NSLog(@"%@ - Visit %@ in your web browser", code, webServer.serverURL);

    [webServer addHandlerForMethod:@"POST"
                          path:@"/index.html"
                  requestClass:[GCDWebServerURLEncodedFormRequest class]
                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        NSLog(@"%@", [(GCDWebServerURLEncodedFormRequest*)request arguments]);
        NSString* name = [[(GCDWebServerURLEncodedFormRequest*)request arguments] objectForKey:@"name"];
        NSString* redirect = [[(GCDWebServerURLEncodedFormRequest*)request arguments] objectForKey:@"redirect"];
        NSString* html = [NSString stringWithFormat:@"<meta http-equiv=\"Refresh\" content=\"0; url=%@?name=%@&code=%@\" />", redirect, name, code];
        return [GCDWebServerDataResponse responseWithHTML:html];
    }];

        [webServer addHandlerForMethod:@"POST"
                          path:@"/layout"
                  requestClass:[GCDWebServerURLEncodedFormRequest class]
                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        NSLog(@"%@", [(GCDWebServerURLEncodedFormRequest*)request arguments]);
        NSString* data = [[(GCDWebServerURLEncodedFormRequest*)request arguments] objectForKey:[[(GCDWebServerURLEncodedFormRequest*)request arguments] allKeys][0]];
        NSString *name = [[(GCDWebServerURLEncodedFormRequest*)request arguments] allKeys][0];
        NSLog(@"%@", data);

        NSError *jsonError;
        NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *originArray = [NSJSONSerialization JSONObjectWithData:objectData
                                            options:NSJSONReadingMutableContainers 
                                                error:&jsonError];

        CGSize abounds = [[UIScreen mainScreen] bounds].size;
        NSMutableDictionary *layoutPlist = [NSMutableDictionary new];
        layoutPlist[@"OriginalScale"] = @{@"width":@(abounds.width), @"height":@(abounds.height)};
        layoutPlist[@"Origins"] = originArray;
        [layoutPlist writeToFile:[NSString stringWithFormat:@"/Library/Iconoclast/Layouts/%@.plist", name] atomically: YES];
        NSString* html = @"<meta http-equiv=\"Refresh\" content=\"0; url=index.html\" />";
        return [GCDWebServerDataResponse responseWithHTML:html];
    }];

    while (1){}
}
