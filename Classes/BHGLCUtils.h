//
//  BHGLCUtils.h
//
//  Created by John Visentin on 10/11/13.
//  Copyright (c) 2013 Brockenhaus Studio. All rights reserved.
//

#ifndef BHGLCUtils_h
#define BHGLCUtils_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include <stddef.h>
#include "BHGLTypes.h"
    
/* type helpers */
extern BHGLVertexType BHGLVertexTypeCreate(GLubyte numAttribs);
extern BHGLVertexType BHGLVertexTypeCreateWithType(BHGLEnum vType);
extern void BHGLVertexTypeDeepCopy(BHGLVertexType *dest, const BHGLVertexType *src);
extern void BHGLVertexTypeFree(BHGLVertexType vType);
    
extern BHGLAnimationInfo BHGLAnimationInfoCreate(unsigned int numFrames, unsigned int fps);
extern void BHGLAnimationInfoDeepCopy(BHGLAnimationInfo *dest, const BHGLAnimationInfo *src);
extern void BHGLAnimationInfoFree(BHGLAnimationInfo animInfo);
    
extern BHGLVertexAttribInfo* BHGLVertexAttributesForVertexType(const BHGLVertexType *vType);

/* binding */
extern void BHGLBindBufferSet(BHGLBufferSet set);
extern void BHGLBindBuffers(GLuint vbo, GLuint ibo);
extern void BHGLBindVertexArray(GLuint vao);
extern void BHGLBindTexture2D(GLuint tex2D);

/* state setting for frequently changed states. has no effect if no state change would occur.
    NOTE: assumes all state changes are made via these methods. prefer these over the raw openGL calls. */
extern void BHGLUseProgram(GLuint program);
extern void BHGLSetDepthTestEnabled(GLboolean enabled);
extern void BHGLSetStencilTestEnabled(GLboolean enabled);
extern void BHGLSetScissorTestEnabled(GLboolean enabled);
extern void BHGLSetBlendEnabled(GLboolean enabled);
extern void BHGLSetCullFaceEnabled(GLboolean enabled);

/* state capturing */
extern void BHGLSaveProgram(void);
extern void BHGLRestoreProgram(void);
extern void BHGLSaveVertexBuffer(void);
extern void BHGLRestoreVertexBuffer(void);
extern void BHGLSaveIndexBuffer(void);
extern void BHGLRestoreIndexBuffer(void);
extern void BHGLSaveVertexArray(void);
extern void BHGLRestoreVertexArray(void);
extern void BHGLSaveTexture2D(void);
extern void BHGLRestoreTexture2D(void);

/* NOTE: Names are bound before returning!! */
extern GLuint BHGLGenerateVertexArray(void);
extern GLuint BHGLGenerateVertexBuffer(GLsizeiptr size, GLvoid *vertices, GLenum usage);
extern GLuint BHGLGenerateIndexBuffer(GLsizeiptr size, GLuint *indices, GLenum usage);
extern GLuint BHGLGenerateRGBATextureDefault(GLsizei width, GLsizei height, GLubyte *data);
extern GLuint BHGLGenerateRGBATexture(GLsizei width, GLsizei height, GLubyte *data, GLenum minFilter, GLenum magFilter, GLenum sWrap, GLenum tWrap);

/* creates but does not link or use program */
extern GLuint BHGLGenerateProgram(GLuint vertexShader, GLuint fragmentShader);
extern GLboolean BHGLLinkProgram(GLuint program);

extern void BHGLDeleteVertexArrays(GLsizei n, const GLuint *vertexArrays);

/* shader compiling. Shader string must be null terminated. */
extern GLuint BHGLCompileShader(const GLchar *shaderString, GLenum type);
extern GLuint BHGLCompileShaderf(const char *filePath, GLenum type);

/* print functions */
extern void BHGLprintShaderLog(GLuint shader);
extern void BHGLprintProgramLog(GLuint program);
extern GLenum BHGLError(void);
    
#ifdef __cplusplus
}
#endif

#endif
