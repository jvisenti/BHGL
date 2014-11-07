//
//  BHViewController.m
//  BHGLDemo
//
//  Created by John Visentin on 10/10/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHViewController.h"
#import "BHGL.h"
#import "BHCube.h"
#import "BHFish.h"

@interface BHViewController ()

@property (nonatomic, strong) BHCube *cube;
@property (nonatomic, strong) BHFish *fish;

- (void)createShaders;

@end

@implementation BHViewController

- (void)setupGL
{
    [super setupGL];
    
    self.glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.scene = [[BHGLScene alloc] init];
    
    self.cube = [[BHCube alloc] init];
    self.fish = [[BHFish alloc] init];
    
    BHGLCamera *camera = [[BHGLCamera alloc] initWithFieldOfView:GLKMathDegreesToRadians(65.0f) aspectRatio:self.view.bounds.size.width/self.view.bounds.size.height nearClippingPlane:4.0f farClippingPlane:15.0f];
    
    [self.scene addCamera:camera];
    self.scene.activeCamera = camera;
    
    /** Note the node heirarchy here **/
    [self.scene addChild:self.cube];
    [self.cube addChild:self.fish];
    
    [self createShaders];
    
    glClearColor(0.0f, 0.5f, 0.25f, 1.0f);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.scene render];
    
    const GLenum discards[]  = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 2, discards);
}

#pragma mark - private interface

- (void)createShaders
{
     BHGLProgram *program = [[BHGLProgram alloc] initWithVertexShaderNamed:@"SimpleVertex.vsh" fragmentShaderNamed:@"SimpleFragment.fsh"];
    
    program.mvpUniformName = @"u_MVPMatrix";
    [program setVertexAttribute:BHGLVertexAttribPosition forName:@"a_position"];
    [program setVertexAttribute:BHGLVertexAttribTexCoord0 forName:@"a_texCoord"];
    
/** NOTE: Can alternatively use built-in basic shaders by uncommenting the following code,
    which has the same effect as the code above. **/
/*
    BHGLProgram *program = [[BHGLProgram alloc] initWithVertexShaderNamed:kBHGLBasicVertexShader fragmentShaderNamed:kBHGLBasicFragmentShader];
    
    program.mvpUniformName = kBHGLMVPUniformName;
    [program setVertexAttribute:BHGLVertexAttribPosition forName:kBHGLPositionAttributeName];
    [program setVertexAttribute:BHGLVertexAttribTexCoord0 forName:kBHGLTexCoord0AttributeName];
*/
    
    if ([program link])
    {
        self.scene.program = program;
    }
}

@end
