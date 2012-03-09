//
//  ANTrackBar.m
//  TrackBar
//
//  Created by Alex Nichol on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANTrackBar.h"

@interface ANTrackBar (Private)

- (float)valueForPoint:(NSPoint)viewPoint;

- (CGPathRef)pathForUncovered;
- (CGPathRef)pathForCovered;
- (CGPathRef)pathForPositionMarker;
- (CGPathRef)pathForBorder;

- (CGGradientRef)uncoveredGradient;
- (CGGradientRef)coveredGradient;

- (void)drawUncovered:(CGContextRef)context;
- (void)drawCovered:(CGContextRef)context;
- (void)drawPositionMarker:(CGContextRef)context;
- (void)drawLightBorder:(CGContextRef)context;
- (void)drawBorder:(CGContextRef)context;

@end

@implementation ANTrackBar

- (id)initWithFrame:(NSRect)frame {
    frame.size.height = kTrackBarHeight;
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (NSCell *)cell {
    return nil;
}

- (float)value {
    double dv = [self doubleValue];
    dv -= [self minValue];
    dv /= [self maxValue] - [self minValue];
    return (float)dv;
}

- (void)setValue:(float)aValue {
    double dv = (aValue * ([self maxValue] - [self minValue])) + [self minValue];
    [self setDoubleValue:dv];
}

#pragma mark - Mouse Events -

- (void)mouseDown:(NSEvent *)theEvent {
    isPressed = YES;
    NSPoint location = [theEvent locationInWindow];
    [self setValue:[self valueForPoint:location]];
    
    id obj = self;
    
    NSMethodSignature * sig = [self.target methodSignatureForSelector:self.action];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self.target];
    [invocation setSelector:self.action];
    [invocation setArgument:&obj atIndex:2];
    [invocation invoke];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint location = [theEvent locationInWindow];
    [self setValue:[self valueForPoint:location]];

    id obj = self;

    NSMethodSignature * sig = [self.target methodSignatureForSelector:self.action];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self.target];
    [invocation setSelector:self.action];
    [invocation setArgument:&obj atIndex:2];
    [invocation invoke];
}

- (void)mouseUp:(NSEvent *)theEvent {
    isPressed = NO;
    [self setNeedsDisplay:YES];
}

#pragma mark Private

- (float)valueForPoint:(NSPoint)location {
    NSView * view = self;
    do {
        location.x -= view.frame.origin.x;
        location.y -= view.frame.origin.y;
    } while ((view = [view superview]));
    
    CGFloat usableWidth = self.frame.size.width - kTrackBarButtonSize - 2 - 0.5;
    CGFloat newValue = (location.x - (CGFloat)(kTrackBarButtonSize / 2.0));
    newValue /= usableWidth;
    
    if (newValue < 0) newValue = 0;
    else if (newValue > 1) newValue = 1;
    
    return (float)newValue;
}

#pragma mark - Drawing -

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    [self drawLightBorder:context];
    [self drawUncovered:context];
    [self drawCovered:context];
    [self drawPositionMarker:context];
    [self drawBorder:context];
}

#pragma mark Private

- (void)drawUncovered:(CGContextRef)context {
    CGPathRef uncoveredPath = [self pathForUncovered];
    CGGradientRef uncoveredGrad = [self uncoveredGradient];
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, uncoveredPath);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(0, 1);
    CGPoint endPoint = CGPointMake(0, self.frame.size.height - 2);    
    CGContextDrawLinearGradient(context, uncoveredGrad, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(uncoveredPath);
    CGGradientRelease(uncoveredGrad);
}

- (void)drawCovered:(CGContextRef)context {
    CGPathRef coveredPath = [self pathForCovered];
    CGGradientRef coveredGrad = [self coveredGradient];
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, coveredPath);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(0, 2);
    CGPoint endPoint = CGPointMake(0, self.frame.size.height - 2);    
    CGContextDrawLinearGradient(context, coveredGrad, startPoint, endPoint, 0);
    
    CGContextSetGrayStrokeColor(context, 0.949, 1.0f);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 1.5);
    CGContextAddLineToPoint(context, self.frame.size.width, 1.5);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(coveredPath);
    CGGradientRelease(coveredGrad);
}

- (void)drawPositionMarker:(CGContextRef)context {
    [[NSGraphicsContext currentContext] saveGraphicsState];
    CGPathRef diamondPath = [self pathForPositionMarker];    
    
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:NSMakeSize(0, 0)];
    [shadow setShadowBlurRadius:3];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow set];
    
    CGContextSetGrayFillColor(context, (isPressed ? 0.5 : 1), 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, diamondPath);
    CGContextFillPath(context);
    
#if !__has_feature(objc_arc)
    [shadow release];
#endif
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    CGPathRelease(diamondPath);
}

- (void)drawLightBorder:(CGContextRef)context {
    CGPathRef borderPath = [self pathForBorder];
    CGContextSetLineWidth(context, 1);
    
    CGContextSaveGState(context);
    CGContextSetGrayStrokeColor(context, 0.85, 1);
    CGContextBeginPath(context);
    CGContextTranslateCTM(context, 0, 1);
    CGContextAddPath(context, borderPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGPathRelease(borderPath);
}

- (void)drawBorder:(CGContextRef)context {
    CGPathRef borderPath = [self pathForBorder];
    CGContextSetLineWidth(context, 1);
    
    CGContextSetGrayStrokeColor(context, 0.435, 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, borderPath);
    CGContextStrokePath(context);
    
    CGPathRelease(borderPath);
}

#pragma mark Data Generators

- (CGPathRef)pathForUncovered {
    CGRect frame = self.bounds;
    frame.origin.x += 1;
    frame.origin.y += 1;
    frame.size.width -= 2;
    frame.size.height -= 3;
    CGFloat minX = CGRectGetMinX(frame), maxX = CGRectGetMaxX(frame);
    CGFloat minY = CGRectGetMinY(frame), maxY = CGRectGetMaxY(frame);
    CGFloat radius = kTrackBarRadius;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX + radius, minY);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, maxY - radius, radius);
    CGPathAddArcToPoint(path, NULL, minX, maxY, maxX - radius, maxY, radius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, minY + radius, radius);
    CGPathAddArcToPoint(path, NULL, maxX, minY, minX + radius, minY, radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)pathForCovered {
    CGFloat usableWidth = self.frame.size.width - kTrackBarButtonSize - 2 - 0.5;
    
    CGRect frame = self.bounds;
    frame.origin.x += 1;
    frame.origin.y += 1;
    frame.size.width = round((kTrackBarButtonSize / 2) + (usableWidth * self.value));
    frame.size.height -= 3;
    CGFloat minX = CGRectGetMinX(frame), maxX = CGRectGetMaxX(frame);
    CGFloat minY = CGRectGetMinY(frame), maxY = CGRectGetMaxY(frame);
    CGFloat radius = kTrackBarRadius;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX + radius, minY);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, maxY - radius, radius);
    CGPathAddArcToPoint(path, NULL, minX, maxY, maxX - radius, maxY, radius);
    CGPathAddLineToPoint(path, NULL, maxX, maxY);
    CGPathAddLineToPoint(path, NULL, maxX, minY);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)pathForPositionMarker {
    CGFloat usableWidth = self.frame.size.width - kTrackBarButtonSize - 2 - 0.5;
    CGFloat center = round(((CGFloat)kTrackBarButtonSize / 2.0) + 1 + (usableWidth * self.value));
    CGFloat yspot = floor(self.frame.size.height / 2.0);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center - (CGFloat)kTrackBarButtonSize / 2.0, yspot);
    CGPathAddLineToPoint(path, NULL, center, 1);
    CGPathAddLineToPoint(path, NULL, center + (CGFloat)kTrackBarButtonSize / 2.0, yspot);
    CGPathAddLineToPoint(path, NULL, center, self.frame.size.height - 2);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)pathForBorder {
    CGRect frame = self.bounds;
    frame.size.height -= 2;
    frame.size.width -= 1;
    frame.origin.x += 0.5;
    frame.origin.y += 0.5;
    CGFloat minX = CGRectGetMinX(frame), maxX = CGRectGetMaxX(frame);
    CGFloat minY = CGRectGetMinY(frame), maxY = CGRectGetMaxY(frame);
    CGFloat radius = kTrackBarRadius + 1;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX + radius, minY);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, maxY - radius, radius);
    CGPathAddArcToPoint(path, NULL, minX, maxY, maxX - radius, maxY, radius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, minY + radius, radius);
    CGPathAddArcToPoint(path, NULL, maxX, minY, minX + radius, minY, radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGGradientRef)uncoveredGradient {
    const CGFloat uncoveredGradient[] = {0.5176f, 1.0f, 0.592, 1.0f, 0.647f, 1.0f};
    const CGFloat locations[] = {0, 0.5, 1};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(gray, uncoveredGradient, locations, 3);
    CGColorSpaceRelease(gray);
    return gradient;
}

- (CGGradientRef)coveredGradient {
    const CGFloat coveredGradient[] = {0.86666, 1.0f, 0.803, 1.0f, 0.741f, 1.0f};
    const CGFloat locations[] = {0, 0.5, 1};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(gray, coveredGradient, locations, 3);
    CGColorSpaceRelease(gray);
    return gradient;
}

@end
