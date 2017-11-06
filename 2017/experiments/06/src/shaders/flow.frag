precision highp float;
varying vec3 vNormal;
uniform samplerCube texture;

uniform float gamma;
uniform float exposure;

const float A = 0.15;
const float B = 0.50;
const float C = 0.10;
const float D = 0.20;
const float E = 0.02;
const float F = 0.30;

vec3 Uncharted2Tonemap( vec3 x )
{
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 colorCorrection( vec3 color ) {
	color = Uncharted2Tonemap( color * exposure );
	color = color * ( 1.0 / Uncharted2Tonemap( vec3( 20.0 ) ) );
	color = pow( color, vec3( 1.0 / gamma ) );

	return color;
}

void main(void) {
	vec3 color = colorCorrection(textureCube( texture, vNormal ).rgb);
	color *= 1.25;
    gl_FragColor = vec4(color, 1.0);
}