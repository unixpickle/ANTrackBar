//
//  ANTrackBar.h
//  TrackBar
//
//  Created by Alex Nichol on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kTrackBarHeight 14
#define kTrackBarButtonSize 11

@interface ANTrackBar : NSSlider {
    BOOL isPressed;
}

@property (readwrite) float value;

@end
