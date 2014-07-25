//
//  BHGLTextNode.m
//
//  Created by John Visentin on 3/6/14.
//  Copyright (c) 2014 Brockenhaus Studio. All rights reserved.
//

#import "BHGLTextNode.h"
#import "BHGLCUtils.h"
#import "BHGLMesh.h"
#import "BHGLMaterial.h"

#if TARGET_OS_IPHONE
#define BHGL_COLOR_TYPE UIColor
#define BHGL_FONT_TYPE  UIFont
#else
#define BHGL_COLOR_TYPE NSColor
#define BHGL_FONT_TYPE  NSFont
#endif

@interface BHGLTextNode ()

@property (nonatomic, strong) BHGLMesh *mesh;
@property (nonatomic, strong) BHGLMaterial *material;

- (void)createMesh;
- (void)createMaterial;

- (void)updateTexture;

@end

@implementation BHGLTextNode

- (id)init
{
    if ((self = [super init]))
    {
        _font = [BHGL_FONT_TYPE systemFontOfSize:[BHGL_FONT_TYPE systemFontSize]];
        _textColor = [BHGL_COLOR_TYPE blackColor];
                
        BHGLProgram *program = [[BHGLProgram alloc] initWithVertexShaderNamed:kBHGLBasicVertexShader fragmentShaderNamed:kBHGLBasicFragmentShader];
        program.mvpUniformName = kBHGLMVPUniformName;
        [program setVertexAttribute:BHGLVertexAttribPosition forName:kBHGLPositionAttributeName];
        [program setVertexAttribute:BHGLVertexAttribTexCoord0 forName:kBHGLTexCoord0AttributeName];
        
        if ([program link])
        {
            self.program = program;
        }
        
        [self createMesh];
        [self createMaterial];
    }
    return self;
}

- (void)createMesh
{
    const BHGLTextureVertex vertices[] = {
        {{0.5f, -0.5f, 0.0f}, {1.0f, 1.0f}},
        {{0.5f, 0.5f, 0.0f}, {1.0f, 0.0f}},
        {{-0.5f, 0.5f, 0.0f}, {0.0f, 0.0f}},
        {{-0.5f, -0.5f, 0.0f}, {0.0f, 1.0f}}
    };
    
    const GLubyte indices[] = {
        0, 1, 2,
        2, 3, 0
    };
    
    BHGLVertexType vType = BHGLVertexTypeCreateWithType(BHGL_TEXTURE_VERTEX);
    self.mesh = [[BHGLMesh alloc] initWithVertexData:vertices vertexDataSize:sizeof(vertices) vertexType:&vType indexData:indices indexDataSize:sizeof(indices) indexType:GL_UNSIGNED_BYTE];
    self.mesh.cullFaces = GL_NONE;
    BHGLVertexTypeFree(vType);
}

- (void)createMaterial
{
    self.material = [[BHGLMaterial alloc] init];
    self.material.blendEnabled = GL_TRUE;
    self.material.blendSrcRGB = GL_SRC_ALPHA;
    self.material.blendDestRGB = GL_ONE_MINUS_SRC_ALPHA;
}

#pragma mark - property overrides

- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    [self updateTexture];
    
    [self sizeToFit];
}

- (void)setTextColor:(BHGL_COLOR_TYPE *)textColor
{
    _textColor = textColor;
    
    [self updateTexture];
}

- (void)setFont:(BHGL_FONT_TYPE *)font
{
    _font = font;
    
    [self updateTexture];
}

#pragma mark - public interface

- (void)sizeToFit
{
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    self.scale = GLKVector3Make(self.size.width / viewport[2], self.size.height / viewport[3], 1.0f);
}

#pragma mark - BHGLRenderedObject

- (void)render
{
    [self configureProgram:self.program];
    
    [self.material bind];
    
    [self.mesh renderWithProgram:self.program];
    
    [self.material unbind];
    
    [super render];
}

- (void)renderWithProgram:(BHGLProgram *)program
{    
    [self configureProgram:program];
    
    [self.material bind];
    
    [self.mesh renderWithProgram:program];
    
    [self.material unbind];
    
    [super renderWithProgram:program];
}

#pragma mark - private interface

#if TARGET_OS_IPHONE

- (void)updateTexture
{
    if (self.text && self.font && self.textColor)
    {
        NSDictionary *textAttribs = @{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor};
        
        CGSize textSize = [self.text sizeWithAttributes:textAttribs];
        CGRect textRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, textSize.width, textSize.height));
        
        UIGraphicsBeginImageContext(textSize);
        
        [self.text drawInRect:textRect withAttributes:textAttribs];
        
        UIImage *renderedText = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        NSDictionary *options = @{kBHGLTextureMinFilterKey  : @(GL_LINEAR),
                                  kBHGLTextureMagFilterKey  : @(GL_LINEAR),
                                  KBHGLTextureSWrapKey      : @(GL_CLAMP_TO_EDGE),
                                  kBHGLTextureTWrapKey      : @(GL_CLAMP_TO_EDGE)};
        
        self.material.texture = [[BHGLTexture alloc] initWithImage:renderedText options:options error:nil];
        _size = CGSizeMake(floor(self.material.texture.width), floor(self.material.texture.height));
    }
    else
    {
        self.material.texture = nil;
    }
}

#else

- (void)updateTexture
{
    if (self.text && self.font && self.textColor)
    {
        NSDictionary *textAttribs = @{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor};
        
        CGSize textSize = [self.text sizeWithAttributes:textAttribs];
        CGRect textRect = CGRectMake(0.0f, 0.0f, textSize.width, textSize.height);
        
        NSImage *image = [[NSImage alloc] initWithSize:textSize];
        
        [image lockFocus];
        
        [self.text drawInRect:textRect withAttributes:textAttribs];
        
        [image unlockFocus];
        
        NSDictionary *options = @{kBHGLTextureMinFilterKey  : @(GL_LINEAR),
                                  kBHGLTextureMagFilterKey  : @(GL_LINEAR),
                                  KBHGLTextureSWrapKey      : @(GL_CLAMP_TO_EDGE),
                                  kBHGLTextureTWrapKey      : @(GL_CLAMP_TO_EDGE)};
        
        self.material.texture = [[BHGLTexture alloc] initWithImage:image options:options error:nil];
        _size = CGSizeMake(floor(self.material.texture.width), floor(self.material.texture.height));
    }
    else
    {
        self.material.texture = nil;
    }
}
#endif

@end
