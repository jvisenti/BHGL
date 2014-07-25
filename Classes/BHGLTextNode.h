//
//  BHGLTextNode.h
//
//  Created by John Visentin on 3/6/14.
//  Copyright (c) 2014 Brockenhaus Studio. All rights reserved.
//

#import "BHGLNode.h"

/** @warning This class is a work in progress, with limited support. */
@interface BHGLTextNode : BHGLNode

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, copy) NSString *text;

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
#else
@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic, strong) NSFont *font;
#endif

/** Adjusts the scale of the text node to fit the text it contains. */
- (void)sizeToFit;

@end
