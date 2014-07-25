varying lowp vec2 v_texCoord;
uniform sampler2D u_texture;

void main(void)
{
    gl_FragColor = texture2D(u_texture, v_texCoord);
}