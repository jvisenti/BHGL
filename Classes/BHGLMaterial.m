//
//  BHGLMaterial.m
//
//  Created by John Visentin on 12/18/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLMaterial.h"
#import "BHGLCUtils.h"

@implementation BHGLMaterial

- (id)init
{
    if ((self = [super init]))
    {
        self.emissionColor = BHGLColorClear;
        self.surfaceColor = BHGLColorBlack;
        self.ambientColor = BHGLColorBlack;
        self.diffuseColor = BHGLColorBlack;
        self.specularColor = BHGLColorBlack;
        
        self.shininess = 0.0f;
        
        self.blendSrcRGB = GL_ONE;
        self.blendDestRGB = GL_ZERO;
        self.blendSrcAlpha = GL_ONE;
        self.blendDestAlpha = GL_ZERO;        
    }
    return self;
}

- (void)bind
{
    BHGLBindTexture2D(self.texture.name);
    
    if (self.isBlendEnabled == GL_TRUE)
    {
        BHGLSetBlendEnabled(GL_TRUE);
        glBlendFuncSeparate(self.blendSrcRGB, self.blendDestRGB, self.blendSrcAlpha, self.blendDestAlpha);
    }
}

- (void)unbind
{
    BHGLBindTexture2D(0);
    BHGLSetBlendEnabled(GL_FALSE);
}

- (BHGLMaterialInfo)materialInfo
{
    BHGLMaterialInfo info;
    
    info.identifier = self.identifier;
    info.emission = self.emissionColor;
    info.surface = self.surfaceColor;
    info.ambient = self.ambientColor;
    info.diffuse = self.diffuseColor;
    info.specular = self.specularColor;
    info.shininess = self.shininess;
    
    return info;
}

@end
