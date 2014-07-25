//
//  BHGLLight.m
//
//  Created by John Visentin on 2/15/14.
//  Copyright (c) 2014 Brockenhaus Studio. All rights reserved.
//

#import "BHGLLight.h"

@implementation BHGLLight

- (id)init
{
    if ((self = [super init]))
    {
        self.type = BHGLLightTypeDirectional;
        self.enabled = YES;
        self.ambientColor = BHGLColorBlack;
        self.diffuseColor = BHGLColorWhite;
        self.specularColor = BHGLColorWhite;
        self.constantAttenuation = 1.0f;
        self.spotDirection = GLKVector3Make(0.0f, 0.0f, -1.0f);
        self.spotCutoff = M_PI;
    }
    return self;
}
- (GLKVector3)rotatedSpotDirection
{
    return GLKQuaternionRotateVector3(self.rotation, self.spotDirection);
}

- (BHGLLightInfo)lightInfo
{
    BHGLLightInfo lightInfo;
    
    lightInfo.identifier = self.identifier;
    lightInfo.type = self.type;
    lightInfo.enabled = self.isEnabled;
    lightInfo.ambientColor = self.ambientColor;
    lightInfo.diffuseColor = self.diffuseColor;
    lightInfo.specularColor = self.specularColor;
    lightInfo.constantAttenuation = self.constantAttenuation;
    lightInfo.linearAttenuation = self.linearAttenuation;
    lightInfo.quadraticAttentuation = self.quadraticAttenuation;
    lightInfo.spotCutoff = self.spotCutoff;
    lightInfo.spotExponent = self.spotExponent;
    
    memcpy(lightInfo.position, self.position.v, 3*sizeof(GLfloat));
    
    memcpy(lightInfo.halfVector, self.halfVector.v, 3*sizeof(GLfloat));
    
    GLKVector3 coneDir = [self rotatedSpotDirection];
    memcpy(lightInfo.spotDirection, coneDir.v, 3*sizeof(GLfloat));
    
    return lightInfo;
}

@end
