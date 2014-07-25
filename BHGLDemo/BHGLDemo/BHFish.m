//
//  BHFish.m
//  BHGLDemo
//
//  Created by John Visentin on 10/13/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHFish.h"
#import "BHGLCUtils.h"

const BHGLTextureVertex Vertices2[] = {
    {{0.5, -0.5, 0.01}, {1, 1}},
    {{0.5, 0.5, 0.01}, {1, 0}},
    {{-0.5, 0.5, 0.01}, {0, 0}},
    {{-0.5, -0.5, 0.01}, {0, 1}},
};

const GLushort Indices2[] = {
    0, 1, 2, 2, 3, 0
};

@implementation BHFish

- (id)init
{
    if ((self = [super init]))
    {
        self.material = [[BHGLMaterial alloc] init];
        self.material.texture = [[BHGLTexture alloc] initWithImageNamed:@"item_powerup_fish.png" options:nil error:nil];
        
        BHGLVertexType vType = BHGLVertexTypeCreateWithType(BHGL_TEXTURE_VERTEX);
        self.mesh = [[BHGLMesh alloc] initWithVertexData:(const GLvoid *)Vertices2 vertexDataSize:sizeof(Vertices2) vertexType:&vType indexData:Indices2 indexDataSize:sizeof(Indices2) indexType:GL_UNSIGNED_SHORT];
        BHGLVertexTypeFree(vType);
        
        /* enable blending */
        self.material.blendEnabled = GL_TRUE;
        self.material.blendSrcRGB = GL_ONE;
        self.material.blendDestRGB = GL_ONE_MINUS_SRC_ALPHA;
    }
    return self;
}

@end
