// based on the following Shader Toy entry
//
// [SH17A] Matrix rain. Created by Reinder Nijhoff 2017
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// @reindernijhoff
//
// https://www.shadertoy.com/view/ldjBW1
//
#define SPEED_MULTIPLIER 1.
#define GREEN_ALPHA 0.33
#define BLACK_BLEND_THRESHOLD .1
#define COLOR_CYCLE_SPEED 0.7  // Speed of color cycling (lower = slower)
#define R fract(1e2 * sin(p.x * 8. + p.y))

vec3 getColorForTime(float time) {
    // Your custom colors
    vec3 colors[5];
    colors[0] = vec3(0.020, 0.827, 0.953);  // #05D3F3 - Bright cyan
    colors[1] = vec3(0.004, 0.278, 0.329);  // #014754 - Dark teal
    colors[2] = vec3(0.000, 0.031, 0.035);  // #000809 - Very dark blue
    colors[3] = vec3(0.467, 0.949, 1.000);  // #77F2FF - Light cyan
    colors[4] = vec3(0.000, 0.035, 0.039);  // #00090A - Almost black

    // Calculate which color to use
    float colorIndex = mod(time * COLOR_CYCLE_SPEED, 5.0);
    int index1 = int(floor(colorIndex));
    int index2 = int(mod(floor(colorIndex) + 1.0, 5.0));
    float blend = fract(colorIndex);

    // Smooth transition between colors
    return mix(colors[index1], colors[index2], smoothstep(0.0, 1.0, blend));
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec3 v = vec3(fragCoord, 1) / iResolution - .5;
    vec3 s = .9 / abs(v);
    s.z = min(s.y, s.x);
    vec3 i = ceil( 8e2 * s.z * ( s.y < s.x ? v.xzz : v.zyz ) ) * .1;
    vec3 j = fract(i);
    i -= j;
    vec3 p = vec3(9, int(iTime * SPEED_MULTIPLIER * (9. + 8. * sin(i).x)), 0) + i;

    // Get current color based on time
    vec3 currentColor = getColorForTime(iTime);
    vec3 col = currentColor * (R / s.z);

    p *= j;
    col *= (R >.5 && j.x < .6 && j.y < .8) ? GREEN_ALPHA : 0.;

    // Sample the terminal screen texture including alpha channel
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 terminalColor = texture(iChannel0, uv);
    float alpha = step(length(terminalColor.rgb), BLACK_BLEND_THRESHOLD);
    // vec3 blendedColor = mix(terminalColor.rgb * 1.2, col, alpha);
    vec3 boostedTerminal = terminalColor.rgb * mix(1.0, 1.2, alpha);
    vec3 blendedColor = mix(boostedTerminal, col, alpha);
    fragColor = vec4(blendedColor, terminalColor.a);
}
