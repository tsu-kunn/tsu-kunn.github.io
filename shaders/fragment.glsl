#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_position;
varying vec4 v_normal;
varying vec2 v_texcoord;
varying vec4 v_color;

uniform mat4 u_projectionMatrix;
uniform mat4 u_modelViewMatrix;
uniform mat4 u_normalMatrix;
uniform vec2 u_resolution;
uniform float u_time;

#if defined(VERTEX)

attribute vec4 a_position;
attribute vec4 a_normal;
attribute vec2 a_texcoord;
attribute vec4 a_color;

void main(void) {
    v_position = u_projectionMatrix * u_modelViewMatrix * a_position;
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
    v_color = a_color;
    gl_Position = v_position;
}

#else // fragment shader

uniform vec2 u_mouse;
uniform vec3 u_camera;
uniform sampler2D u_texture_0;
// uniform vec2 u_textureResolution;

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // Get texture color
    vec4 tcolor = texture2D(u_texture_0, v_texcoord);

    // Convert RGB->YCbCr
//    float y  = tcolor.r *  0.29900 + tcolor.g * 0.58700 + tcolor.b * 0.11400;
    float y  = dot(tcolor.rgb, vec3(0.29900, 0.58700, 0.11400));
    float cb = -0.091;
    float cr = 0.056;

    // Convert sepia
    vec4 scolor;
    float ratio = abs(sin(u_time));
    scolor.r = y + 1.40200 * cr * ratio;
    scolor.g = y - 0.34414 * cb - 0.71414 * cr * ratio;
    scolor.b = y + 1.77200 * cb * ratio;
    scolor.a = tcolor.a;

    gl_FragColor = mix(tcolor, scolor, ratio) * v_color;
}

#endif

// Add texture information to setting.json
// {
//     "glsl-canvas.textures": {
//         "0": "./GitHub/projects/GLSL/tex/amiya.png"
//     }
// }
