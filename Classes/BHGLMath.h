//
//  BHGLMath.h
//
//  Created by John Visentin on 10/19/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#ifndef BHGLMath_h
#define BHGLMath_h

#include <GLKit/GLKMath.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Computes the view matrix with eye at "from" looking at "to" with right hand coordinates.
    @param up The unit vector representing the "up" direction.
    @note To compute the matrix with left hand coordinates, swap the from and to parameters. */
static inline GLKMatrix4 BHGLMatrix4LookAt(GLKVector3 from, GLKVector3 to, GLKVector3 up)
{
    GLKVector3 zAxis = GLKVector3Normalize(GLKVector3Subtract(from, to));
    GLKVector3 xAxis = GLKVector3Normalize(GLKVector3CrossProduct(up, zAxis));
    GLKVector3 yAxis = GLKVector3Normalize(GLKVector3CrossProduct(zAxis, xAxis));
    
    float tx = -GLKVector3DotProduct(xAxis, from);
    float ty = -GLKVector3DotProduct(yAxis, from);
    float tz = -GLKVector3DotProduct(zAxis, from);
    
    GLKMatrix4 m;
    
    m.m00 = xAxis.x;    m.m01 = yAxis.x;    m.m02 = zAxis.x;    m.m03 = 0;
    m.m10 = xAxis.y;    m.m11 = yAxis.y;    m.m12 = zAxis.y;    m.m13 = 0;
    m.m20 = xAxis.z;    m.m21 = yAxis.z;    m.m22 = zAxis.z;    m.m23 = 0;
    m.m30 = tx;         m.m31 = ty;         m.m32 = tz;         m.m33 = 1;
    
    return m;
}
    

/** Returns the translation of a given transform. */
static inline GLKVector3 BHGLMatrix4Translation(GLKMatrix4 mat)
{
    return GLKVector3Make(mat.m[12], mat.m[13], mat.m[14]);
}
 
    
static inline GLKVector3 BHGLTransformVector3(GLKMatrix4 m, GLKVector3 v)
{
    GLKVector3 mv;
    
    mv.v[0] = m.m00 * v.v[0] + m.m10 * v.v[1] + m.m20 * v.v[2] + m.m30;
    mv.v[1] = m.m01 * v.v[0] + m.m11 * v.v[1] + m.m21 * v.v[2] + m.m31;
    mv.v[2] = m.m02 * v.v[0] + m.m12 * v.v[1] + m.m22 * v.v[2] + m.m32;
    
    return mv;
}

static inline BOOL BHGLUnProject(GLKVector3 winPos, GLKMatrix4 mvMat, GLKMatrix4 projMat, GLKVector4 viewPort, GLKVector3 *worldPos)
{
    GLKMatrix4 mvp = GLKMatrix4Multiply(projMat, mvMat);
    
    bool invertible;
    GLKMatrix4 mvpInv = GLKMatrix4Invert(mvp, &invertible);
    
    if (!invertible)
    {
        return NO;
    }
    
    GLKVector4 winVec = GLKVector4MakeWithVector3(winPos, 1.0f);
    
    winVec.x = (winVec.x - viewPort.x) / viewPort.v[2];
    winVec.y = (winVec.y - viewPort.y) / viewPort.v[3];
    
    winVec.x = 2.0f * winVec.x - 1.0f;
    winVec.y = 2.0f * winVec.y - 1.0f;
    winVec.z = 2.0f * winVec.z - 1.0f;

    winVec = GLKMatrix4MultiplyVector4(mvMat, winVec);
    
    GLKVector4 worldVec = GLKMatrix4MultiplyVector4(mvpInv, winVec);
    
    if (worldVec.w == 0.0f)
    {
        return NO;
    }
    
    worldVec = GLKVector4MultiplyScalar(worldVec, 1.0f / worldVec.w);
    
    if (worldPos != NULL)
    {
        *worldPos = GLKVector3MakeWithArray(worldVec.v);
    }
    
    return YES;
}
    

/** Decomposes the given transform into translation, rotation, and scale.
    @param translation Contains the translation values of the transform after computation.
    @param rotation Represents the rotation of the transform after computation.
    @param scale Contains the scale values of the transform after computation.
    @note Due to isomorphism between certain scale and rotation transformations, the results may be inexact.
    @warning NOT YET IMPLEMENTED! */
static inline void BHGLMatrix4Decompose(GLKMatrix4 mat, GLKVector3 *translation, GLKQuaternion *rotation, GLKVector3 *scale)
{
    return;
}
    
#ifdef __cplusplus
}
#endif

#endif
