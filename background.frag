uniform sampler2D Texture;
varying vec2 TexCoord;

void main() {
    vec3 col = texture2D(Texture, TexCoord).rgb;
    float foo = (col.r + col.g + col.b) * 0.33;
    foo = 0.4 + foo * 0.2;
    col.r = foo;
    col.g = foo;
    col.b = foo;
    gl_FragColor = vec4(col, 0.6);
}
