//
//  ANAppDelegate.m
//  TrackBar
//
//  Created by Alex Nichol on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CGFloat height = [self.window.contentView frame].size.height;
    CGFloat width = [self.window.contentView frame].size.width;
    
    valueLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(width - 50, height - 26, 40, 18)];
    [valueLabel setBackgroundColor:[NSColor clearColor]];
    [valueLabel setSelectable:NO];
    [valueLabel setEditable:NO];
    [valueLabel setBordered:NO];
    [valueLabel setStringValue:@"0.5"];
    
    trackBar = [[ANTrackBar alloc] initWithFrame:NSMakeRect(10, height - 10 - kTrackBarHeight,
                                                            width - 65, kTrackBarHeight)];
    [trackBar setValue:0.5];
    [trackBar setTarget:self];
    [trackBar setAction:@selector(barValueChanged:)];
    
    [self.window.contentView addSubview:trackBar];
    [self.window.contentView addSubview:valueLabel];
}

- (IBAction)barValueChanged:(id)sender {
    NSString * value = [NSString stringWithFormat:@"%.2f", [trackBar value]];
    [valueLabel setStringValue:value];
}

@end
