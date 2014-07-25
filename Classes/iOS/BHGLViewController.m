//
//  BHGLViewController.m
//
//  Created by John Visentin on 10/12/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLViewController.h"

@implementation BHGLViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupGL];
}

- (void)dealloc
{
    [self teardownGL];
}

#pragma mark - public interface

+ (EAGLContext *)bestContext
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!context)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}

- (GLKView *)glView
{
    return (GLKView *)self.view;
}

- (void)setupGL
{
    self.glView.context = [BHGLViewController bestContext];
    [EAGLContext setCurrentContext:self.glView.context];
}

- (void)teardownGL
{
    [EAGLContext setCurrentContext:nil];
}

- (void)update
{
    [self.scene updateRecursive:self.timeSinceLastUpdate];
}

@end
