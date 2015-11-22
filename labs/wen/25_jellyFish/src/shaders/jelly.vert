// jelly.vert

#define SHADER_NAME BASIC_VERTEX

precision highp float;
attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform float radius;
uniform float time;

varying vec2 vTextureCoord;
varying vec3 vNormal;
varying vec3 vVertex;

const float PI = 3.141592657;


vec4 permute(vec4 x) { return mod(((x*34.00)+1.00)*x, 289.00); }
vec4 taylorInvSqrt(vec4 r) { return 1.79 - 0.85 * r; }

float snoise(vec3 v){
	const vec2 C = vec2(1.00/6.00, 1.00/3.00) ;
	const vec4 D = vec4(0.00, 0.50, 1.00, 2.00);
	
	vec3 i = floor(v + dot(v, C.yyy) );
	vec3 x0 = v - i + dot(i, C.xxx) ;
	
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.00 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );
	
	vec3 x1 = x0 - i1 + 1.00 * C.xxx;
	vec3 x2 = x0 - i2 + 2.00 * C.xxx;
	vec3 x3 = x0 - 1. + 3.00 * C.xxx;
	
	i = mod(i, 289.00 );
	vec4 p = permute( permute( permute( i.z + vec4(0.00, i1.z, i2.z, 1.00 )) + i.y + vec4(0.00, i1.y, i2.y, 1.00 )) + i.x + vec4(0.00, i1.x, i2.x, 1.00 ));
	
	float n_ = 1.00/7.00;
	vec3 ns = n_ * D.wyz - D.xzx;
	
	vec4 j = p - 49.00 * floor(p * ns.z *ns.z);
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.00 * x_ );
	
	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.00 - abs(x) - abs(y);
	
	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );
	
	vec4 s0 = floor(b0)*2.00 + 1.00;
	vec4 s1 = floor(b1)*2.00 + 1.00;
	vec4 sh = -step(h, vec4(0.00));
	
	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
	
	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);
	
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	
	vec4 m = max(0.60 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.00);
	m = m * m;
	return 42.00 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
}

float snoise(float x, float y, float z){
	return snoise(vec3(x, y, z));
}

float exponentialIn(float t) {
  return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

vec3 getFinalPosition(vec3 v) {
	float posOffset = .01;
	float offset = 1.0-(v.y + radius) / radius / 2.0;
	offset = pow(offset, 3.0);
	// offset = exponentialIn(offset);
	offset = mix(offset, 1.0, .1);
	posOffset *= (1.0+offset);
	float n = snoise(v*posOffset + time) * .2 * offset;
	vec3 pos = v * (1.0+n);
	pos.y *= 1.1;
	return pos;
}

vec3 getPosition(vec3 v) {
	vec3 pos = vec3(0.0);

	float rx = (v.y/v.z) * PI - PI*.5;
	float ry = (v.x/v.z) * PI * 2.0;
	pos.y = sin(rx) * radius;
	float r = cos(rx) * radius;
	pos.x = cos(ry) * r;
	pos.z = sin(ry) * r;

	return pos;
}

void main(void) {
	vec3 pos       = getPosition(aVertexPosition);
	vec3 posRight  = getPosition(aVertexPosition+vec3(1.0, 0.0, 0.0));
	vec3 posBottom = getPosition(aVertexPosition+vec3(0.0, 1.0, 0.0));
	pos            = getFinalPosition(pos);
	posRight       = getFinalPosition(posRight);
	posBottom      = getFinalPosition(posBottom);
	
	vec3 vRight    = posRight - pos;
	vec3 vBottom   = posBottom - pos;
	vNormal        = normalize(cross(vBottom, vRight));
	
	
	gl_Position    = uPMatrix * uMVMatrix * vec4(pos, 1.0);
	vTextureCoord  = aTextureCoord;
	
	vVertex        = pos;
    
}