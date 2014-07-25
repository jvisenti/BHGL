//
//  BHGLTexture.m
//
//  Created by John Visentin on 10/16/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLTexture.h"
#import "BHGLCUtils.h"

NSString* const kBHGLTextureMinFilterKey    = @"BHGLTextureMinFilterKey";
NSString* const kBHGLTextureMagFilterKey    = @"BHGLTextureMagFilterKey";
NSString* const KBHGLTextureSWrapKey        = @"BHGLTextureSWrapKey";
NSString* const kBHGLTextureTWrapKey        = @"BHGLTextureTWrapKey";

@interface BHGLTexture ()

- (id)initWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError **)outError;

@end

@implementation BHGLTexture

- (id)initWithTextureInfo:(GLKTextureInfo *)textureInfo options:(NSDictionary *)options
{
    if ((self = [self initWithTextureInfo:textureInfo]))
    {
        NSMutableDictionary *mutableOptions = [NSMutableDictionary dictionaryWithCapacity:[options count]];
        
        NSNumber *minFilter = [options objectForKey:kBHGLTextureMinFilterKey] ? [options objectForKey:kBHGLTextureMinFilterKey] : @(GL_NEAREST);
        NSNumber *magFilter = [options objectForKey:kBHGLTextureMagFilterKey] ? [options objectForKey:kBHGLTextureMagFilterKey] : @(GL_LINEAR);
        NSNumber *sWrap = [options objectForKey:KBHGLTextureSWrapKey] ? [options objectForKey:KBHGLTextureSWrapKey] : @(GL_REPEAT);
        NSNumber *tWrap = [options objectForKey:kBHGLTextureTWrapKey] ? [options objectForKey:kBHGLTextureTWrapKey] : @(GL_REPEAT);
        
        [mutableOptions setObject:minFilter forKey:kBHGLTextureMinFilterKey];
        [mutableOptions setObject:magFilter forKey:kBHGLTextureMagFilterKey];
        [mutableOptions setObject:sWrap forKey:KBHGLTextureSWrapKey];
        [mutableOptions setObject:tWrap forKey:kBHGLTextureTWrapKey];
        
        [self applyOptions:mutableOptions];
    }
    return self;
}

- (id)initWithTextureInfo:(GLKTextureInfo *)textureInfo
{
    return [self initWithName:textureInfo.name width:textureInfo.width heght:textureInfo.height];
}

- (id)initWithName:(GLuint)name width:(GLsizei)width heght:(GLsizei)height
{
    if ((self = [super init]))
    {
        _name = name;
        _width = width;
        _height = height;
    }
    return self;
}

- (void)dealloc
{
    GLuint n = _name;
    dispatch_async(dispatch_get_main_queue(), ^{
        glDeleteTextures(1, &n);
    });
}

- (id)initWithImageNamed:(NSString *)imageName options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
#if TARGET_OS_IPHONE
    return [self initWithImage:[UIImage imageNamed:imageName] options:options error:outError];
#else
    return [self initWithImage:[NSImage imageNamed:imageName] options:options error:outError];
#endif
}

- (id)initWithContentsOfFile:(NSString *)file options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
#if TARGET_OS_IPHONE
    return [self initWithImage:[UIImage imageWithContentsOfFile:file] options:options error:outError];
#else
    return [self initWithImage:[[NSImage alloc] initWithContentsOfFile:file] options:options error:outError];
#endif
}

#if TARGET_OS_IPHONE

- (id)initWithImage:(UIImage *)image options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
    CGImageRef cgImage = image.CGImage;
    return [self initWithCGImage:cgImage options:options error:outError];
}

#else

- (id)initWithImage:(NSImage *)image options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
    CGImageRef cgImage = [image CGImageForProposedRect:NULL context:nil hints:nil];
    return [self initWithCGImage:cgImage options:options error:outError];
}
#endif

- (void)applyOptions:(NSDictionary *)options
{
    if (self.name != 0)
    {
        BHGLSaveTexture2D();
        
        BHGLBindTexture2D(self.name);
        
        GLint minFilter = [[options objectForKey:kBHGLTextureMinFilterKey] intValue];
        GLint magFilter = [[options objectForKey:kBHGLTextureMagFilterKey] intValue];
        GLint sWrap = [[options objectForKey:KBHGLTextureSWrapKey] intValue];
        GLint tWrap = [[options objectForKey:kBHGLTextureTWrapKey] intValue];
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, sWrap);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, tWrap);
        
        BHGLRestoreTexture2D();
    }
}

#pragma mark - private interface

- (id)initWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
    if (cgImage)
    {
        GLKTextureInfo *texInfo = [GLKTextureLoader textureWithCGImage:cgImage options:nil error:outError];
        
        if (outError == nil)
        {
            return [self initWithTextureInfo:texInfo options:options];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return [self initWithTextureInfo:nil options:nil];
    }
}

@end

@implementation BHGLAsyncTextureLoader

- (void)loadTextureWithCGImage:(CGImageRef)cgImage withCompletion:(void (^)(BHGLTexture *, NSError *))completion
{
    CGImageRetain(cgImage);
    
#if TARGET_OS_IPHONE
    GLKTextureLoader *texLoader = [[GLKTextureLoader alloc] initWithSharegroup:self.sharegroup];
#else
    GLKTextureLoader *texLoader = [[GLKTextureLoader alloc] initWithShareContext:self.context];
#endif
    
    [texLoader textureWithCGImage:cgImage options:nil queue:self.completionQueue completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError) {
        BHGLTexture *texture = nil;
        
        if (outError == nil)
        {
            texture = [[BHGLTexture alloc] initWithTextureInfo:textureInfo];
        }
        
        if (completion != nil)
        {
            completion(texture, outError);
        }
        
        CGImageRelease(cgImage);
    }];
}

- (void)loadTextureFromFile:(NSString *)fileName withCompletion:(void (^)(BHGLTexture *, NSError *))completion
{
#if TARGET_OS_IPHONE
    GLKTextureLoader *texLoader = [[GLKTextureLoader alloc] initWithSharegroup:self.sharegroup];
#else
    GLKTextureLoader *texLoader = [[GLKTextureLoader alloc] initWithShareContext:self.context];
#endif
    
    [texLoader textureWithContentsOfFile:fileName options:nil queue:self.completionQueue completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError) {
        BHGLTexture *texture = nil;
        
        if (outError == nil)
        {
            texture = [[BHGLTexture alloc] initWithTextureInfo:textureInfo];
        }
        
        if (completion != nil)
        {
            completion(texture, outError);
        }
    }];
}

@end
