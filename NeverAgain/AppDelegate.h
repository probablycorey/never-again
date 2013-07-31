#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *mirrorItem;
@property (weak) IBOutlet NSMenuItem *unmirrorItem;
@property (strong, nonatomic) NSStatusItem *statusBar;

- (IBAction)mirror:(id)sender;
- (IBAction)unmirror:(id)sender;


@end
