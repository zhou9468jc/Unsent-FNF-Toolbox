#pragma header

uniform float iTime;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 0.00001)), d / (q.x + 0.00001), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    float t = iTime;

    // Screen Distortion
    uv.x += sin(uv.y * 12.0 + t * 1.8) * 0.03;
    uv.y += sin(uv.x * 10.0 - t * 1.4) * 0.02;
    uv = clamp(uv, vec2(0.001), vec2(0.999));

    // RGB Glitch
    float offset = 0.015 * sin(t * 3.0);
    vec2 uvR = clamp(uv + vec2(offset, 0.0), vec2(0.001), vec2(0.999));
    vec2 uvB = clamp(uv - vec2(offset, 0.0), vec2(0.001), vec2(0.999));

    vec4 color;
    color.r = flixel_texture2D(bitmap, uvR).r;
    color.g = flixel_texture2D(bitmap, uv).g;
    color.b = flixel_texture2D(bitmap, uvB).b;
    color.a = flixel_texture2D(bitmap, uv).a;

    // Rainbow Hue
    vec3 hsv = rgb2hsv(color.rgb);
    hsv.x = fract(hsv.x + t * 0.64);

    // Color Flash
    hsv.x = fract(hsv.x + 0.08 * sin(t * 2.0));
    hsv.y = min(1.0, hsv.y * 1.35);

    color.rgb = hsv2rgb(hsv);
    gl_FragColor = color;
}