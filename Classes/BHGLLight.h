//
//  BHGLLight.h
//
//  Created by John Visentin on 2/15/14.
//  Copyright (c) 2014 Brockenhaus Studio. All rights reserved.
//

#import "BHGLAnimatedObject.h"
#import <GLKit/GLKMath.h>
#import "BHGLTypes.h"

@interface BHGLLight : BHGLAnimatedObject

/** An identifier for use by your application. This could, for instance, be
 an index into a light array. */
@property (nonatomic, assign) GLuint identifier;

/** A descriptive name for use by your application. */
@property (nonatomic, copy) NSString *name;

/** The type of light. Default is BHGLLightTypeDirectional. */
@property (nonatomic, assign) BHGLLightType type;

/** Whether the light is enabled. Default is YES. */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/** The light's contribution to ambient light. Default is BHGLColorBlack. */
@property (nonatomic, assign) BHGLColor ambientColor;

/** Diffuse portion of the light. Default is BHGLColorWhite. */
@property (nonatomic, assign) BHGLColor diffuseColor;

/** Specular portion of the light. Default is BHGLColorWhite. */
@property (nonatomic, assign) BHGLColor specularColor;

/** The constant coefficient of attentuation. Unused by directional lights. Default 1.0. */
@property (nonatomic, assign) float constantAttenuation;

/** The linear coefficient of attentuation. Unused by directional lights. Default 0.0. */
@property (nonatomic, assign) float linearAttenuation;

/** The quadratic coefficient of attentuation. Unused by directional lights. Default 0.0. */
@property (nonatomic, assign) float quadraticAttenuation;

/** The cone direction for spot lights. Default is (0.0, 0.0, -1.0). */
@property (nonatomic, assign) GLKVector3 spotDirection;

/** The higher the exponent, the tighter the focus of the spotlight. 
    Only used by spot lights. Default is 0.0. */
@property (nonatomic, assign) float spotExponent;

/** The cosine cutoff value. Only used by spot lights. Default is M_PI. */
@property (nonatomic, assign) float spotCutoff;

/** The pre-computed direction of highlights. Only used by directional lights. */
@property (nonatomic, assign) GLKVector3 halfVector;

/** The spotDirection property rotated by the light's current rotation. */
- (GLKVector3)rotatedSpotDirection;

/** Extract properties into a light info struct. */
- (BHGLLightInfo)lightInfo;

@end
