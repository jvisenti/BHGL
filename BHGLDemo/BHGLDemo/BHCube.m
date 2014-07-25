//
//  BHCube.m
//  BHGLDemo
//
//  Created by John Visentin on 10/13/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHCube.h"
#import "BHGLCUtils.h"
#import "BHGLBasicAnimation.h"

#define TEX_COORD_MAX   4

const BHGLTextureVertex Vertices[] = {
    // Front
    {{1, -1, 0}, {TEX_COORD_MAX, 0}},
    {{1, 1, 0}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0}},
    // Back
    {{1, -1, -2}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 0}},
    // Left
    {{-1, -1, 0}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 0}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0}},
    // Right
    {{1, -1, -2}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 0}, {0, TEX_COORD_MAX}},
    {{1, -1, 0}, {0, 0}},
    // Top
    {{1, 1, 0}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0}},
    // Bottom
    {{1, -1, -2}, {TEX_COORD_MAX, 0}},
    {{1, -1, 0}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0}}
};

const GLushort Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    6, 7, 4,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

@implementation BHCube

- (id)init
{
    if ((self = [super init]))
    {
        self.material.texture = [[BHGLTexture alloc] initWithImageNamed:@"tile_floor.png" options:nil error:nil];
        
        BHGLVertexType vType = BHGLVertexTypeCreateWithType(BHGL_TEXTURE_VERTEX);
        self.mesh = [[BHGLMesh alloc] initWithVertexData:(const GLvoid *)Vertices vertexDataSize:sizeof(Vertices) vertexType:&vType indexData:Indices indexDataSize:sizeof(Indices) indexType:GL_UNSIGNED_SHORT];
        BHGLVertexTypeFree(vType);
        
        __weak BHCube *wself = self;
        BHGLBasicAnimation *anim = [BHGLBasicAnimation transformWithBlock:^(BHGLAnimatedObject *node, NSTimeInterval currentTime, NSTimeInterval totalTime) {
            node.position = GLKVector3Make(sin(CACurrentMediaTime()), 0.0f, -8.0f);
            node.rotation = GLKQuaternionMakeWithAngleAndAxis(wself.currentRotation, 1.0f, 1.0f, 0.0f);
        } duration:0.0f];
        anim.repeats = YES;
        [self runAnimation:anim];
    }
    return self;
}

- (void)update:(NSTimeInterval)dt
{
    [super update:dt];
    
    self.currentRotation += dt * M_PI_4;
}

@end
