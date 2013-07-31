#import "AppDelegate.h"
#import "Keynote.h"
#import <ApplicationServices/ApplicationServices.h>
#import <ScriptingBridge/ScriptingBridge.h>


@implementation AppDelegate {
  bool previouslyHadMultipleDisplays;
}

@synthesize statusBar=_statusBar;
@synthesize statusMenu = _statusMenu;
@synthesize mirrorItem = _mirrorItem;

- (void) awakeFromNib {
  self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  self.statusBar.menu = self.statusMenu;
  self.statusBar.highlightMode = YES;
  self.statusBar.title = @"◎";
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [self setKeynoteDefaults];
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(displayChanged:)
                 name:NSApplicationDidChangeScreenParametersNotification
               object:nil];
}

- (void)setKeynoteDefaults {
 KeynoteApplication *Keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
 SBElementArray *slides = [[Keynote slideshows][0] slides];
 [slides[0] jumpTo];
  
 system("defaults write com.apple.iWork.Keynote PresenterShowNotes YES");
 system("defaults write com.apple.iWork.Keynote PresentationModeUseSecondary 1");
}

- (void)displayChanged:(id)something {
  bool hasMultipleDisplays = [self hasMultipleDisplays];
  if (previouslyHadMultipleDisplays == hasMultipleDisplays) return;
  
  previouslyHadMultipleDisplays = hasMultipleDisplays;
  if (self.mirrorItem.state == NSOnState) {
    [self mirror:self];
  }
  else {
    [self unmirror:self];
  }
}

- (void)mirror:(id)sender {
  self.mirrorItem.state = NSOnState;
  self.unmirrorItem.state = NSOffState;
  [self secondDisplayMaster:CGMainDisplayID()];
}

- (void)unmirror:(id)sender {
  self.mirrorItem.state = NSOffState;
  self.unmirrorItem.state = NSOnState;
  [self secondDisplayMaster:kCGNullDirectDisplay];
}

- (void)secondDisplayMaster:(CGDirectDisplayID)masterDisplay {
  if (![self hasMultipleDisplays]) return;
  
  CGDisplayConfigRef configRef;
  CGDisplayErr err;

  err = CGBeginDisplayConfiguration(&configRef);
  if (err) NSLog(@"Error with CGBeginDisplayConfiguration: %d\n", err);

  err = CGConfigureDisplayMirrorOfDisplay(configRef, [self secondaryDisplay], masterDisplay);
  if (err) NSLog(@"Mirroring failed: %d\n", err);
  
  err = CGCompleteDisplayConfiguration (configRef, kCGConfigurePermanently);
  if (err) NSLog(@"Error with CGCompleteDisplayConfiguration: %d\n",err);
}

- (CGDirectDisplayID)secondaryDisplay {
  CGDirectDisplayID displays[] = {0,0};
  CGDirectDisplayID activeDisplays[] = {0,0};
  CGDisplayCount numberOfDisplays;
  CGDisplayCount numberOfActiveDisplays;
  CGDisplayErr err;
  
  err = CGGetOnlineDisplayList(2, displays, &numberOfDisplays);
  if (err) NSLog(@"Failed to access online displays: %d\n", err);
  
  err = CGGetActiveDisplayList(2, activeDisplays, &numberOfActiveDisplays);
  if (err) NSLog(@"Failed to access active displays: %d\n", err);

  return (displays[0] == CGMainDisplayID()) ? displays[1] : displays[0];
}

- (bool)hasMultipleDisplays {
  CGDisplayCount numberOfDisplays;
  CGDisplayErr err;
  
  err = CGGetOnlineDisplayList(2, nil, &numberOfDisplays);
  if (err) NSLog(@"Failed to access online displays: %d\n", err);
  
  return numberOfDisplays == 2;
}

- (bool)isMirrored {
  CGDisplayCount numberOfActiveDisplays;
  CGDisplayErr err;
  
  err = CGGetActiveDisplayList(2, nil, &numberOfActiveDisplays);
  if (err) NSLog(@"Failed to access active displays: %d\n", err);

  return [self hasMultipleDisplays] && numberOfActiveDisplays == 1;
}


@end
