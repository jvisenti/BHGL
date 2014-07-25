//
//  BHGLTexture.h
//
//  Created by John Visentin on 10/16/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//
// NOTE: currently no support for mipmaps or cubemaps

#import <Foundation/Foundation.h>
#import <GLKit/GLKTextureLoader.h>
#import "BHGLTypes.h"

OBJC_EXTERN NSString* const kBHGLTextureMinFilterKey; /** Default GL_NEAREST if not specified */
OBJC_EXTERN NSString* const kBHGLTextureMagFilterKey; /** Default GL_LINEAR if not specified */
OBJC_EXTERN NSString* const KBHGLTextureSWrapKey;     /** Default GL_REPEAT if not specified */
OBJC_EXTERN NSString* const kBHGLTextureTWrapKey;     /** Default GL_REPEAT if not specified */

@interface BHGLTexture : NSObject

/** An identifier for use by your application. */
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, readonly) GLuint name;

@property (nonatomic, readonly) GLsizei width;
@property (nonatomic, readonly) GLsizei height;

/** Stores the values of an existing texture. Do not call this method unless you have created a GL texture object
 elsewhere with the given name. */
- (id)initWithName:(GLuint)name width:(GLsizei)width heght:(GLsizei)height;

/** Captures the values stored in an existing texture object. */
- (id)initWithTextureInfo:(GLKTextureInfo *)textureInfo;

/** Captures the values stored in an existing texture object, and then applies the given options.
 @param options a dictionary whose keys are kBHGLTextureMinFilterKey, kBHGLTextureMagFilterKey, kBHGLTextureSWrapKey, kBHGLTextureTWrapKey, and whose values are NSNumbers containing the appropriate GLints. Pass nil to use the default options. */
- (id)initWithTextureInfo:(GLKTextureInfo *)textureInfo options:(NSDictionary *)options;

/** Returns a new texture using the given options, or nil if an error occurred. 
    @param imageName the name to be passed to the imageNamed method.
    @param options a dictionary whose keys are kBHGLTextureMinFilterKey, kBHGLTextureMagFilterKey, kBHGLTextureSWrapKey, kBHGLTextureTWrapKey, and whose values are NSNumbers containing the appropriate GLints. Pass nil to use the default options. */
- (id)initWithImageNamed:(NSString *)imageName options:(NSDictionary *)options error:(NSError **)outError;

/** Returns a new texture using the given options, or nil if an error occurred.
    @param file the file path to be passed to the imageWithContentsOfFile method.
    @param options a dictionary whose keys are kBHGLTextureMinFilterKey, kBHGLTextureMagFilterKey, kBHGLTextureSWrapKey, kBHGLTextureTWrapKey, and whose values are NSNumbers containing the appropriate GLints. Pass nil to use the default options. */
- (id)initWithContentsOfFile:(NSString *)file options:(NSDictionary *)options error:(NSError **)outError;

#if TARGET_OS_IPHONE
- (id)initWithImage:(UIImage *)image options:(NSDictionary *)options error:(NSError **)outError;
#else
- (id)initWithImage:(NSImage *)image options:(NSDictionary *)options error:(NSError **)outError;
#endif

/** Applies the given options to the texture. Because this method saves, changes, and then resets OpenGL state, it should be called infrequently.
    @param options a dictionary whose keys are kBHGLTextureMinFilterKey, kBHGLTextureMagFilterKey, kBHGLTextureSWrapKey, kBHGLTextureTWrapKey, and whose values are NSNumbers containing the appropriate GLints. Pass nil to use the default options. */
- (void)applyOptions:(NSDictionary *)options;

@end

@interface BHGLAsyncTextureLoader : NSObject

#if TARGET_OS_IPHONE
/** The sharegroup to perform loads into. */
@property (nonatomic, strong) EAGLSharegroup *sharegroup;
#else
/** The openGL context to perform loads into. */
@property (nonatomic, strong) NSOpenGLContext *context;
#endif

/* The queue on which load completion blocks are called. If nil, compeltion blocks are called on the main thread. */
@property (nonatomic, assign) dispatch_queue_t completionQueue;

/** Loads a new texture from an image asynchronously and then calls the given completion block on the dispatch queue specified by the completionQueue property. */
- (void)loadTextureWithCGImage:(CGImageRef)cgImage withCompletion:(void (^)(BHGLTexture *texture, NSError *outError))completion;

/** Loads a new texture from a file asynchronously and then calls the given completion block on the dispatch queue specified by the completionQueue property. */
- (void)loadTextureFromFile:(NSString *)fileName withCompletion:(void (^)(BHGLTexture *texture, NSError *outError))completion;

@end
