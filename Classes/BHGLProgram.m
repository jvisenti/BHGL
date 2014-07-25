//
//  BHGLProgram.m
//
//  Created by John Visentin on 10/12/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLProgram.h"
#import "BHGLCUtils.h"
#import "BHGLTexture.h"
#import "BHGLMaterial.h"
#import "BHGLLight.h"

NSString* const kBHGLBasicVertexShader       = @"BHGL_BasicVSHKey";
NSString* const kBHGLBasicFragmentShader     = @"BHGL_BasicFSHKey";

NSString* const kBHGLMVPUniformName          = @"u_MVPMatrix";
NSString* const kBHGLMVUniformName           = @"u_MVMatrix";
NSString* const kBHGLNormalMatrixUniformName = @"u_NormalMatrix";
NSString* const kBHGLPositionAttributeName   = @"a_position";
NSString* const kBHGLNormalAttributeName     = @"a_normal";
NSString* const kBHGLColorAttributeName      = @"a_color";
NSString* const kBHGLTexCoord0AttributeName  = @"a_texCoord0";
NSString* const kBHGLTexCoord1AttributeName  = @"a_texCoord1";

#if TARGET_OS_IPHONE

static NSString* const kBHGLBasicVertexShaderSrc = @"\
attribute vec4 a_position;\
attribute vec2 a_texCoord0;\
uniform mat4 u_MVPMatrix;\
varying vec2 v_texCoord0;\
void main(void)\
{ \
    gl_Position = u_MVPMatrix * a_position;\
    v_texCoord0 = a_texCoord0;\
}";

static NSString* const kBHGLBasicFragmentShaderSrc = @"\
uniform sampler2D u_texture;\
varying mediump vec2 v_texCoord0;\
void main(void)\
{\
    gl_FragColor = texture2D(u_texture, v_texCoord0);\
}\
";

#else

static NSString* const kBHGLBasicVertexShaderSrc = @"\
#version 150 core\n\
in vec4 a_position;\
in vec2 a_texCoord0;\
uniform mat4 u_MVPMatrix;\
out vec2 v_texCoord0;\
void main(void)\
{ \
gl_Position = u_MVPMatrix * a_position; \
v_texCoord0 = a_texCoord0;\
}";

static NSString* const kBHGLBasicFragmentShaderSrc = @"\
#version 150 core\n\
uniform sampler2D u_texture;\
in vec2 v_texCoord0;\
out vec4 o_frag_color;\
void main(void)\
{\
o_frag_color = texture(u_texture, v_texCoord0);\
}\
";

#endif

static NSSet *BHGLShaders;

@interface BHGLProgram ()
{
    GLint _mvpMatrixIndex;
    GLint _mvMatrixIndex;
    GLint _normalMatrixIndex;
    
    GLint _maxTextures;
    GLint *_texUniforms;
}

@property (nonatomic, strong) NSMutableDictionary *attibutes;
@property (nonatomic, strong) NSMutableDictionary *textures;
@property (nonatomic, strong) NSCache *uniforms;

+ (GLuint)defaultShaderNamed:(NSString *)name;

- (void)setUniform:(NSString *)uniformName withMaterialInfo:(BHGLMaterialInfo)materialInfo index:(int)index;
- (void)setUniform:(NSString *)uniformName withLightInfo:(BHGLLightInfo)lightInfo index:(int)index;

@end

@implementation BHGLProgram

+ (void)initialize
{
    [super initialize];
    
    BHGLShaders = [NSSet setWithObjects:kBHGLBasicVertexShader, kBHGLBasicFragmentShader, nil];
}

+ (GLuint)defaultShaderNamed:(NSString *)name
{
    if ([name isEqualToString:kBHGLBasicVertexShader])
    {
        static GLuint BHGLBasicVertexShaderName;
        
        if (!glIsShader(BHGLBasicVertexShaderName))
        {
            BHGLBasicVertexShaderName = BHGLCompileShader([kBHGLBasicVertexShaderSrc UTF8String], GL_VERTEX_SHADER);
        };
        
        return BHGLBasicVertexShaderName;
    }
    else if ([name isEqualToString:kBHGLBasicFragmentShader])
    {
        static GLuint BHGLBasicFragmentShaderName;
        
        if (!glIsShader(BHGLBasicFragmentShaderName))
        {
            BHGLBasicFragmentShaderName = BHGLCompileShader([kBHGLBasicFragmentShaderSrc UTF8String], GL_FRAGMENT_SHADER);
        }
        
        return BHGLBasicFragmentShaderName;
    }
    
    return 0;
}

- (id)init
{
    if ((self = [super init]))
    {
        _mvpMatrixIndex = -1;
        _mvMatrixIndex = -1;
        _normalMatrixIndex = -1;
    }
    return self;
}

- (id)initWithVertexShaderNamed:(NSString *)vShaderName fragmentShaderNamed:(NSString *)fShaderName
{
    if ((self = [self init]))
    {
        glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &_maxTextures);
        _texUniforms = calloc(_maxTextures, sizeof(GLint));
        
        if ([BHGLShaders containsObject:vShaderName])
        {
            _vertexShader = [BHGLProgram defaultShaderNamed:vShaderName];
        }
        else
        {
            _vertexShader = [BHGLProgram compileShaderNamed:vShaderName type:GL_VERTEX_SHADER];
        }
        
        if ([BHGLShaders containsObject:fShaderName])
        {
            _fragmentShader = [BHGLProgram defaultShaderNamed:fShaderName];
        }
        else
        {
            _fragmentShader = [BHGLProgram compileShaderNamed:fShaderName type:GL_FRAGMENT_SHADER];
        }
        
        _name = BHGLGenerateProgram(_vertexShader, _fragmentShader);
        
        self.modelViewMatrix = GLKMatrix4Identity;
        self.projectionMatrix = GLKMatrix4Identity;
    }
    return self;
}

- (void)dealloc
{
    free(_texUniforms);
    
    GLuint vs = self.vertexShader;
    GLuint fs = self.fragmentShader;
    GLuint n = self.name;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        glDeleteShader(vs);
        glDeleteShader(fs);
        glDeleteProgram(n);
    });
}

#pragma mark - public interface

- (NSArray *)boundAttributes
{
    return self.attibutes.allKeys;
}

- (void)setVertexAttribute:(BHGLVertexAttrib)attribute forName:(NSString *)attributeName
{
    glBindAttribLocation(self.name, attribute, [attributeName UTF8String]);

    [self.attibutes setObject:attributeName forKey:@(attribute)];
}

- (NSString *)nameForVertexAttribute:(BHGLVertexAttrib)attribute
{
    return [self.attibutes objectForKey:@(attribute)];
}

- (void)use
{
    BHGLUseProgram(self.name);
}

- (BOOL)link
{
    _linked = (BHGLLinkProgram(self.name) == GL_TRUE) ? YES : NO;
    
    // clear uniform position cache
    [self.uniforms removeAllObjects];

    if (self.isLinked && self.mvpUniformName)
    {
        _mvpMatrixIndex = glGetUniformLocation(self.name, [self.mvpUniformName UTF8String]);
    }
    
    if (self.isLinked && self.mvUniformName)
    {
        _mvMatrixIndex = glGetUniformLocation(self.name, [self.mvUniformName UTF8String]);
    }
    
    if (self.isLinked && self.normalMatrixUniformName)
    {
        _normalMatrixIndex = glGetUniformLocation(self.name, [self.normalMatrixUniformName UTF8String]);
    }
    
    return self.isLinked;
}

- (void)setTexture:(BHGLTexture *)texture forTextureSlot:(GLubyte)texSlot uniformName:(NSString *)uniformName
{
    if (texSlot > _maxTextures)
    {
#ifdef DEBUG
        NSLog(@"%@ cannot set texture for slot %d. Max is %i.", [self class], texSlot, _maxTextures-1);
#endif
        return;
    }
    
    _texUniforms[texSlot] = glGetUniformLocation(self.name, [uniformName UTF8String]);
    
    [self.textures setObject:texture forKey:@(texSlot)];
}

- (void)setUniform:(NSString *)uniformName withMaterial:(BHGLMaterial *)material
{
    [self setUniform:uniformName withMaterialInfo:[material materialInfo]];
}

- (void)setUniform:(NSString *)uniformName withMaterials:(NSArray *)materials
{
    NSUInteger n = [materials count];
    for (int i = 0; i < n; i++)
    {
        [self setUniform:uniformName withMaterialInfo:[materials[i] materialInfo] index:i];
    }
}

- (void)setUniform:(NSString *)uniformName withMaterialInfo:(BHGLMaterialInfo)materialInfo
{
    [self setUniform:uniformName withMaterialInfo:materialInfo index:-1];
}

- (void)setUniform:(NSString *)uniformName withMaterialInfo:(BHGLMaterialInfo *)materialInfo num:(int)n
{
    for (int i = 0; i < n; i++)
    {
        [self setUniform:uniformName withMaterialInfo:materialInfo[i] index:i];
    }
}

- (void)setUniform:(NSString *)uniformName withLight:(BHGLLight *)light
{
    [self setUniform:uniformName withLightInfo:[light lightInfo]];
}

- (void)setUniform:(NSString *)uniformName withLights:(NSArray *)lights
{
    NSUInteger n = [lights count];
    for (int i = 0; i < n; i++)
    {
        [self setUniform:uniformName withLightInfo:[lights[i] lightInfo] index:i];
    }
}

- (void)setUniform:(NSString *)uniformName withLightInfo:(BHGLLightInfo)lightInfo
{
    [self setUniform:uniformName withLightInfo:lightInfo index:-1];
}

- (void)setUniform:(NSString *)uniformName withLightInfo:(BHGLLightInfo *)lightInfo num:(int)n
{
    for (int i = 0; i < n; i++)
    {
        [self setUniform:uniformName withLightInfo:lightInfo[i] index:i];
    }
}

- (GLint)uniformPosition:(NSString *)uniformName
{
    GLuint loc;
    NSNumber *cachedLoc = [self.uniforms objectForKey:uniformName];
    
    if (cachedLoc)
    {
        loc = [cachedLoc intValue];
    }
    else
    {
        loc = glGetUniformLocation(self.name, [uniformName UTF8String]);
        
        if (loc != -1)
        {
            [self.uniforms setObject:@(loc) forKey:uniformName];
        }
    }
    
    return loc;
}

- (void)prepareToDraw
{
    [self use];
    
    if (_mvpMatrixIndex >= 0)
    {
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelViewMatrix);
        glUniformMatrix4fv(_mvpMatrixIndex, 1, GL_FALSE, mvpMatrix.m);
    }
    
    if (_mvMatrixIndex >= 0)
    {
        glUniformMatrix4fv(_mvMatrixIndex, 1, GL_FALSE, self.modelViewMatrix.m);
    }
    
    if (_normalMatrixIndex >= 0)
    {
        glUniformMatrix3fv(_normalMatrixIndex, 1, GL_FALSE, self.normalMatrix.m);
    }
    
    if (self.texture0 != nil)
    {
        glActiveTexture(GL_TEXTURE0);
        BHGLBindTexture2D(self.texture0.name);
    }
    
    [self.textures enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, BHGLTexture *tex, BOOL *stop) {
        GLuint slot = (GLuint)[key unsignedIntegerValue];
                
        glActiveTexture(GL_TEXTURE0 + slot);
        BHGLBindTexture2D(tex.name);
        glUniform1i(_texUniforms[slot], slot);
    }];
}

+ (GLuint)compileShaderNamed:(NSString *)shaderName type:(GLenum)shaderType
{
    NSString *name = [shaderName stringByDeletingPathExtension];
    NSString *ext = [shaderName pathExtension];
    
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    
    if (shaderPath != nil)
    {
        return BHGLCompileShaderf([shaderPath UTF8String], shaderType);
    }
    else
    {
#ifdef DEBUG
        NSLog(@"failed to load shader named %@", shaderName);
#endif
        return 0;
    }
}

#pragma mark - private interface

- (NSMutableDictionary *)attibutes
{
    if (_attibutes == nil)
    {
        _attibutes = [NSMutableDictionary dictionary];
    }
    return _attibutes;
}

- (NSMutableDictionary *)textures
{
    if (_textures == nil)
    {
        _textures = [NSMutableDictionary dictionary];
    }
    return _textures;
}

- (NSCache *)uniforms
{
    if (_uniforms == nil)
    {
        _uniforms = [[NSCache alloc] init];
    }
    return _uniforms;
}

- (void)setUniform:(NSString *)uniformName withMaterialInfo:(BHGLMaterialInfo)materialInfo index:(int)index
{
    if (index >= 0)
    {
        uniformName = [uniformName stringByAppendingFormat:@"[%i]", index];
    }
    
    NSString *format = @"%@.%@";
    
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"emission"]], 1, materialInfo.emission.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"surface"]], 1, materialInfo.surface.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"ambient"]], 1, materialInfo.ambient.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"diffuse"]], 1, materialInfo.diffuse.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"specular"]], 1, materialInfo.specular.c);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"shininess"]], materialInfo.shininess);
}

- (void)setUniform:(NSString *)uniformName withLightInfo:(BHGLLightInfo)lightInfo index:(int)index
{
    if (index >= 0)
    {
        uniformName = [uniformName stringByAppendingFormat:@"[%i]", index];
    }
    
    NSString *format = @"%@.%@";
    
    glUniform1i([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"type"]], lightInfo.type);
    glUniform1i([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"enabled"]], lightInfo.enabled);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"ambientColor"]], 1, lightInfo.ambientColor.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"diffuseColor"]], 1, lightInfo.diffuseColor.c);
    glUniform4fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"specularColor"]], 1, lightInfo.specularColor.c);
    glUniform3fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"position"]], 1, lightInfo.position);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"constantAttenuation"]], lightInfo.constantAttenuation);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"linearAttenuation"]], lightInfo.linearAttenuation);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"quadraticAttenuation"]], lightInfo.quadraticAttentuation);
    glUniform3fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"halfVector"]], 1, lightInfo.halfVector);
    glUniform3fv([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"spotDirection"]], 1, lightInfo.spotDirection);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"spotCutoff"]], lightInfo.spotCutoff);
    glUniform1f([self uniformPosition:[NSString stringWithFormat:format, uniformName, @"spotExponent"]], lightInfo.spotExponent);
}

@end
