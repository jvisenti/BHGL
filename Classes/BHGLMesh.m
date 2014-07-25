//
//  BHGLMesh.m
//
//  Created by John Visentin on 10/11/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#import "BHGLMesh.h"
#import "BHGLCUtils.h"

@implementation BHGLMesh

- (id)init
{
    if ((self = [super init]))
    {
        self.primitiveMode = GL_TRIANGLES;

        self.depthTestEnabled = GL_TRUE;
        self.cullFaces = GL_BACK;
    }
    return self;
}

- (id)initWithVertexData:(const GLvoid *)vertexData vertexDataSize:(GLsizeiptr)vertexDataSize vertexType:(BHGLVertexType *)vertexType indexData:(const GLvoid *)indexData indexDataSize:(GLsizeiptr)indexDataSize indexType:(GLenum)indexType
{
    if ((self = [self initWithVertexData:vertexData vertexDataSize:vertexDataSize vertexType:vertexType]))
    {
        BHGLSaveIndexBuffer();
        
        _bufferSet.indexBuffer = BHGLGenerateIndexBuffer(indexDataSize, (GLuint *)indexData, GL_STATIC_DRAW);
        
        BHGLRestoreIndexBuffer();
        
        size_t indexSize;
        
        switch (indexType)
        {
            case GL_UNSIGNED_BYTE:
                indexSize = sizeof(GLubyte);
                break;
                
            case GL_UNSIGNED_SHORT:
                indexSize = sizeof(GLushort);
                break;
                
            default:
                indexSize = sizeof(GLuint);
                break;
        }
        
        _indexType = indexType;
        _indexCount = (GLuint)indexDataSize / indexSize;
        _indexData = indexData;
    }
    return self;
}

- (id)initWithVertexData:(const GLvoid *)vertexData vertexDataSize:(GLsizeiptr)vertexDataSize vertexType:(BHGLVertexType *)vertexType
{
    if ((self = [self init]))
    {        
        BHGLSaveVertexArray();
        BHGLSaveVertexBuffer();
        
        _vertexArray = BHGLGenerateVertexArray();

        _bufferSet.vertexBuffer = BHGLGenerateVertexBuffer(vertexDataSize, (GLvoid *)vertexData, GL_STATIC_DRAW);

        BHGLVertexAttribInfo *attribs = BHGLVertexAttributesForVertexType(vertexType);
        for (int i = 0; i < vertexType->numAttribs; i++)
        {
            BHGLVertexAttribInfo info = attribs[i];
            glEnableVertexAttribArray(info.index);
            glVertexAttribPointer(info.index, info.length, info.type, info.normalized, info.stride, info.ptr);
        }
        free(attribs);
        
        BHGLRestoreVertexArray();
        BHGLRestoreVertexBuffer();
        
        BHGLVertexTypeDeepCopy(&_vertexType, vertexType);
        
        _vertexCount = (GLuint)vertexDataSize / vertexType->stride;
        _vertexData = vertexData;
    }
    return self;
}

- (void)dealloc
{
    BHGLVertexTypeFree(_vertexType);
    
    BHGLBufferSet bs = self.bufferSet;
    GLuint vao = _vertexArray;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        glDeleteBuffers(2, &bs.vertexBuffer);
        BHGLDeleteVertexArrays(1, &vao);
    });
}

#pragma mark - BHGLRenderedObject

- (void)render
{
    BHGLBindVertexArray(self.vertexArray);
    BHGLBindBufferSet(self.bufferSet);
    
    BHGLSetDepthTestEnabled(self.isDepthTestEnabled);
    
    if (self.cullFaces == GL_NONE)
    {
        BHGLSetCullFaceEnabled(GL_FALSE);
    }
    else
    {
        BHGLSetCullFaceEnabled(GL_TRUE);
        glCullFace(self.cullFaces);
    }
    
    if (self.indexCount == 0)
    {
        glDrawArrays(self.primitiveMode, 0, self.vertexCount);
    }
    else
    {
        glDrawElements(self.primitiveMode, self.indexCount, self.indexType, 0);
    }
    
    BHGLBindVertexArray(0);
    BHGLBindBuffers(0, 0);
}

- (void)renderWithProgram:(BHGLProgram *)program
{
    [program prepareToDraw];
    
    [self render];
}

- (void)update:(NSTimeInterval)dt {}

@end
