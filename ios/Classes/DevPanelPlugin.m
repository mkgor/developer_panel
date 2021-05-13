#import "DevPanelPlugin.h"
#if __has_include(<dev_panel/dev_panel-Swift.h>)
#import <dev_panel/dev_panel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dev_panel-Swift.h"
#endif

@implementation DevPanelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDevPanelPlugin registerWithRegistrar:registrar];
}
@end
