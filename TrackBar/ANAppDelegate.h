//
//  ANAppDelegate.h
//  TrackBar
//
//  Created by Alex Nichol on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANTrackBar.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate> {
    ANTrackBar * trackBar;
    NSTextField * valueLabel;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)barValueChanged:(id)sender;

@end
