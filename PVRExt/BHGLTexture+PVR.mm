//
//  BHGLTexture+PVR.m
//
//  Created by John Visentin on 10/16/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLTexture+PVR.h"
#import "PVRTTextureAPI.h"
#import "PVRTTexture.h"

@implementation BHGLTexture (PVR)

- (id)initWithPVRFileNamed:(NSString *)pvrFileName
{
    GLuint texName;
    PVRTextureHeaderV3 textureHeader;
    
    pvrFileName = [pvrFileName stringByDeletingPathExtension];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:pvrFileName ofType:@"pvr"];
    
    PVRTTextureLoadFromPVR([filePath UTF8String], &texName, &textureHeader);
    
    return [self initWithName:texName width:textureHeader.u32Width heght:textureHeader.u32Height];
}

@end
