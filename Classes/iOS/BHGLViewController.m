//
//  BHGLViewController.m
//
//  Created by John Visentin on 10/12/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLViewController.h"

@interface BHGLViewController ()

@property (nonatomic, strong) EAGLContext *mainContext;
@property (nonatomic, strong) EAGLContext *backgroundContext;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end

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

#pragma mark - public methods

- (GLKView *)glView
{
    return (GLKView *)self.view;
}

- (void)setupGL
{
    self.glView.context = self.mainContext;
    
    if ([EAGLContext currentContext] != self.mainContext)
    {
        glFlush();
        [EAGLContext setCurrentContext:self.mainContext];
    }
}

- (void)teardownGL
{
    EAGLContext *mainContext = self.mainContext;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([EAGLContext currentContext] == mainContext)
        {
            [EAGLContext setCurrentContext:nil];
        }
    });
    
    dispatch_async(self.backgroundQueue, ^{
        [EAGLContext setCurrentContext:nil];
    });
}

- (void)update
{
    [self.scene updateRecursive:self.timeSinceLastUpdate];
}

- (void)performOnBackgroundContext:(void (^)(void))block completion:(void (^)(void))completion
{
    if (block != nil)
    {
        dispatch_async(self.backgroundQueue, ^{
            if ([EAGLContext currentContext] != self.backgroundContext)
            {
                [EAGLContext setCurrentContext:self.backgroundContext];
            }
            
            block();
            glFlush();
            
            if (completion != nil)
            {
                [self performOnMainContext:nil completion:completion];
            }
        });
    }
    else if (completion != nil)
    {
        [self performOnMainContext:nil completion:completion];
    }
}

- (void)performOnMainContext:(void (^)(void))block completion:(void (^)(void))completion
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([EAGLContext currentContext] != self.mainContext)
        {
            [EAGLContext setCurrentContext:self.mainContext];
        }
        
        if (block != nil)
        {
            block();
            glFlush();
        }
        
        if (completion != nil)
        {
            completion();
        }
    }];
}

#pragma mark - private methods

- (EAGLContext *)mainContext
{
    if (_mainContext == nil)
    {
        _mainContext = [BHGLViewController bestContext];
    }
    return _mainContext;
}

- (EAGLContext *)backgroundContext
{
    if (_backgroundContext == nil)
    {
        _backgroundContext = [[EAGLContext alloc] initWithAPI:self.mainContext.API sharegroup:self.mainContext.sharegroup];
    }
    return _backgroundContext;
}

- (dispatch_queue_t)backgroundQueue
{
    if (_backgroundQueue == nil)
    {
        _backgroundQueue = dispatch_queue_create("com.brockenhaus-studio.bhgl", DISPATCH_QUEUE_CONCURRENT);
    }
    return _backgroundQueue;
}

+ (EAGLContext *)bestContext
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!context)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}

@end
