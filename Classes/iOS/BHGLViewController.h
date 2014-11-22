//
//  BHGLViewController.h
//
//  Created by John Visentin on 10/12/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "BHGLScene.h"

@interface BHGLViewController : GLKViewController

@property (nonatomic, readonly) GLKView *glView;
@property (nonatomic, strong) BHGLScene *scene;

/** Initializes context, shaders, VBOs, etc.
    Subclasses should call the super implementation at the start of their implementations.
    @note Default implementation sets the current context. */
- (void)setupGL;

/** Tears down context, shaders, VBOs, etc.
    Subclasses should call the super implementation at the end of their implementations.
    @note Super takes care of clearing contexts. Be careful of deleting any shared resources. */
- (void)teardownGL;

/* This method is documented as part of GLKViewController, but is not declared in the interface */
/** Called before each render call, and used to perform any updates before the frame is rendered. 
    Default implementation recursively updates the scene. */
- (void)update;

- (void)performOnBackgroundContext:(void (^)(void))block completion:(void (^)(void))completion;
- (void)performOnMainContext:(void (^)(void))block completion:(void (^)(void))completion;

@end
