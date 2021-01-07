#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_camera;

out vec4 FlagColor;

const float sphereSize = 1.0; // 球の半径
const vec3 lightDir = vec3(0.2, 0.65, 0.25); // ライトの位置
// const vec3 lightDir = vec3(-0.577, 0.577, 0.577); // ライトの位置

const vec3 cDir = vec3(0.0, 0.0, -1.0);
const vec3 cUp  = vec3(0.0, 1.0, 0.0);

const vec3 Kd = vec3 (0.3, 0.3, 0.3);     // ディフューズ反射率
const vec3 Ld = vec3(2.0, 3.0, 5.0);          // 光源の強度


float smoothMin(float d1, float d2, float k) {
    float h = exp(-k * d1) + exp(-k * d2);
    return (-log(h) / k);
}

float distanceSphere(vec3 p) {
    return (length(p) - sphereSize);
}

float distanceFloor(vec3 p) {
    return (dot(p, vec3(0.0, 1.0, 0.0)) + 20.0);
}

float distanceFunc(vec3 p) {
    float l = 1.0;
    vec3 q = vec3(0.0);

    for (float i = 0.0; i < 10.0; i++) {
        float j = i + 1.0;
        float t = u_time * 0.35;
        q = p + vec3(vec2(cos(t * j), sin(t * j)) * 10.0, 0.0);
        l = smoothMin(l, distanceSphere(q), 1.5);
    }

    l = min(l, distanceFloor(p));

    return l;
}

vec3 distanceColor(vec3 p) {
    float l = 1.0;
    vec3 q = vec3(0.0);
    vec3 color = vec3(0.6588, 0.6392, 0.9059);

    for (float i = 0.0; i < 10.0; i++) {
        float j = i + 1.0;
        float t = u_time * 0.35;
        q = p + vec3(vec2(cos(t * j), sin(t * j)) * 10.0, 0.0);
        l = smoothMin(l, distanceSphere(q), 1.5);
        color += 0.3 / length(q);
    }

    float m = distanceFloor(p);
    l = min(l, m);

    color = l == m ?  vec3(0.298, 0.5686, 0.3176) : color;

    return color;
}

vec3 getNormal(vec3 p) {
    const float d = 0.0001;
    return normalize(vec3(
        distanceFunc(p + vec3(  d, 0.0, 0.0)) - distanceFunc(p + vec3( -d, 0.0, 0.0)),
        distanceFunc(p + vec3(0.0,   d, 0.0)) - distanceFunc(p + vec3(0.0,  -d, 0.0)),
        distanceFunc(p + vec3(0.0, 0.0,   d)) - distanceFunc(p + vec3(0.0, 0.0,  -d))
    ));
}

float genShadow(vec3 ro, vec3 rd) {
    float h = 0.0;
    float c = 0.001;
    float r = 1.0;
    float shadow = 0.5;

    for (float t = 0.0; t < 32.0; t++) {
        h = distanceFunc(ro + rd * c);
        if (h < 0.001) {
            return shadow;
        }
        r = min(r, h * 16.0 / c);   // 16.0: ぼかし係数
        c += h;
    }
    return 1.0 - shadow + r * shadow;
}

void main(void) {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y); // 正規化
    vec3 destColor = vec3(0.65);

    // camera
    vec3 cPos = vec3(u_camera.x - 0.0, u_camera.y - 8.5, u_camera.z + 15.0);

    // ray
    vec3 cSide = cross(cDir, cUp);
    float targetDepth = 1.0;
    vec3 ray = normalize(cSide * pos.x + cUp * pos.y + cDir * targetDepth);

    // marching loop
    float dist = 0.0;   // レイとオブジェクト間の最短距離
    float rLen = 0.0;   // レイに継ぎ足す長さ
    vec3  rPos = cPos;  // レイの先端位置

    for (int i = 0; i < 64; i++) {
        dist = distanceFunc(rPos);
        if (dist < 0.001) break;
        rLen += dist;
        rPos = cPos + ray * rLen;
    }

    // light offset
    vec3 lp = lightDir;
    lp.x = cos(u_time) * 0.5;
    lp.z = sin(u_time) * 0.3;
    lp = normalize(lp);

    // hit check
    vec3 color = vec3(0);
    float shadow = 1.0;

    if (abs(dist) < 0.001) {
        vec3 normal = getNormal(rPos);

        // ディフューズシェーディング方程式
        vec3 s = normalize(vec3(lp - ray));
        vec3 L = Ld * Kd * max(dot(s, normal), 0.0);

        // shadow(ディフューズは影がない方がきれい)
        // TODO: 影の重なりに対応(重なった部分は影なしで計算されている)
        shadow = genShadow(rPos + normal * 0.001, lp);

        // color
        color = distanceColor(rPos);

        destColor = color * L;
    }

    FlagColor = vec4(destColor * max(0.5, shadow), 1.0);
}
