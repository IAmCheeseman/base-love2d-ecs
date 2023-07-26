extern float isOn;

vec4 effect(vec4 color, Image tex, vec2 textureCoords, vec2 screenCoords)
{
    vec4 textureColor = Texel(tex, textureCoords);
    return mix(textureColor * color, vec4(1, 1, 1, textureColor.a), isOn);
}