#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform vec3 u_camera;

const float PI = 3.14159265;
const float PI2 = 6.28318531;

const float sphereSize = 1.0; // 球の半径
const vec3 lightDir = vec3(-0.577, 0.577, 0.577); // ライトの位置

const float angle = 60.0;
const float fov = angle * 0.5 * PI / 180.0;

int sphereNo = 0;
bool bFlg = false;

// fog
const float fogMax = 15.0;
const float fogMin = 1.0;
const vec3 fogColor = vec3(0.5, 0.5, 0.5);    // 背景色にすると効果的

// リピート表示
vec3 trans(vec3 p) {
    return (mod(p, 4.0) - 2.0);
}

vec3 rotate(vec3 p, float angle, vec3 axis){
    vec3 n = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float r = 1.0 - c;
    mat3 m = mat3( // ロドリゲスの回転公式
        n.x * n.x * r + c      , n.y * n.x * r - n.z * s, n.z * n.x * r + n.y * s,
        n.x * n.y * r + n.z * s, n.y * n.y * r + c      , n.z * n.y * r - n.x * s,
        n.x * n.z * r - n.y * s, n.y * n.z * r + n.x * s, n.z * n.z * r + c
    );
    return m * p;
}

float smoothMin(float d1, float d2, float k) {
    float h = exp(-k * d1) + exp(-k * d2);
    return (-log(h) / k);
}

float distanceTorus(vec3 p) {
    // vec2 t = vec2(0.75, 0.25);
    // vec2 r = vec2(length(p.xz) - t.x, p.y);
    vec2 t = vec2(1.5, 0.25);
    vec2 r = vec2(length(p.xy) - t.x, p.z);
    return (length(r) - t.y);
}

float distanceFloor(vec3 p) {
    return (dot(p, vec3(0.0, 1.0, 0.0)) + 1.0);
}

float distanceSphere(vec3 p) {
    // return (length(trans(p)) - sphereSize);
    return (length(p) - sphereSize);
}

float distanceBox(vec3 p) {
    // 箱(vec3: 箱の大きさ, 0.05: 角の丸み)
    // return (length(max(abs(trans(p)) - vec3(0.5, 0.25, 0.5), 0.0)) - 0.05);
    return (length(max(abs(p) - vec3(2.0, 0.1, 0.5), 0.0)) - 0.1);
}

// r.x: 円柱の太さ(半径)
// r.y: 円柱の長さ
float distanceCylinder(vec3 p, vec2 r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - r;
    return (clamp(d.x, d.y, 0.0) + length(max(d, 0.0)) - 0.1);
}

float distanceFunc(vec3 p) {
    vec3 q1 = rotate(p, radians(u_time * 50.0), vec3(0.0, 1.0, 0.0));
    vec3 q2 = rotate(p + vec3(0.0, -1.5, 0.0), radians(u_time * 50.0), vec3(1.0, 0.0, -1.0));

    float d[6];
    float dmin = 1.0;
    int sno[6];

    d[0] = distanceTorus(q2);
    d[1] = distanceFloor(p);
    d[2] = distanceBox(q2);
    d[3] = distanceSphere(q1 + vec3(3.0, -0.5, 0.0));
    d[4] = distanceCylinder(q2, vec2(0.2, 2.25));
    d[5] = distanceSphere(q1 + vec3(-3.0, -0.5, 0.0));

    sno[0] = sno[1] = sno[2] = sno[4] = 0;
    sno[3] = 1;
    sno[5] = 2;

    for (int i = 0; i < 6; i++) {
        if (d[i] < dmin) {
            dmin = d[i];
            if (bFlg) sphereNo = sno[i];
        }
    }

    return dmin;
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

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);
    vec2 cur = (u_mouse * 2.0 - u_resolution) / min(u_resolution.x, u_resolution.y);

    // camera
    vec3 cPos = vec3(u_camera.x - 0.0, u_camera.y + 4.0, u_camera.z + 10.0);

    // ray
#if 1
    vec3 ray = normalize(vec3(sin(fov) * pos.x, sin(fov) * pos.y, -cos(fov)));
#else
    const vec3 cDir = vec3(0.577, -0.577, -0.577);
    const vec3 cUp  = vec3(0.577, 0.577, -0.577);

    vec3 cSide = cross(cDir, cUp);
    float targetDepth = 1.0;
    vec3 ray = normalize(cSide * pos.x + cUp * pos.y + cDir * targetDepth);
#endif

    // marching loop
    float dist = 0.0;   // レイとオブジェクト間の最短距離
    float rLen = 0.0;   // レイに継ぎ足す長さ
    vec3  rPos = cPos;  // レイの先端位置

    bFlg = true;
    for (int i = 0; i < 64; i++) {
        dist = distanceFunc(rPos);
        if (dist < 0.001) break;
        rLen += dist;
        rPos = cPos + ray * rLen;
    }
    bFlg = false;

    // light offset
    vec3 lp = lightDir;
    lp.x = cos(u_time) * 1.0;
    lp.z = sin(u_time) * 1.0;
    lp = normalize(lp);

    // hit check
    vec3 color = vec3(1.0);
    float shadow = 1.0;

    if (abs(dist) < 0.001) {
        vec3 normal = getNormal(rPos);

        // light
        vec3 hl = normalize(lp - ray);
        float diff = clamp(dot(lp, normal), 0.1, 1.0);
        float spec = pow(clamp(dot(hl, normal), 0.0, 1.0), 50.0);

        // shadow
        // TODO: 影の重なりに対応(重なった部分は影なしで計算されている)
        shadow = genShadow(rPos + normal * 0.001, lp);

        // UV or color
        if (sphereNo > 0) {
            color = sphereNo == 1 ? vec3(0.1, 0.3, 0.7) : vec3(0.7, 0.2, 0.1);
        } else {
            float u = 1.0 - floor(mod(rPos.x , 2.0));
            float v = 1.0 - floor(mod(rPos.z , 2.0));
            if ((u == 1.0 && v < 1.0) || (u < 1.0 && v == 1.0)) {
                diff *= 0.3;
            }
        }

        color = color * diff + vec3(spec);
    }

    // fog
    float fogFactor = (fogMax - rLen) / (fogMax - fogMin);
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    gl_FragColor = vec4(mix(fogColor, color * max(0.5, shadow), fogFactor), 1.0);
}
