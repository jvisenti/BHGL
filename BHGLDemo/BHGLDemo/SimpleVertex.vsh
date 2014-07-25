attribute vec4 a_position;

uniform mat4 u_MVPMatrix;

attribute vec2 a_texCoord;
varying vec2 v_texCoord;

void main(void)
{
    gl_Position = u_MVPMatrix * a_position;
    v_texCoord = a_texCoord;
}