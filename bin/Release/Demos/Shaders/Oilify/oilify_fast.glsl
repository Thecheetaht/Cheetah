#version 120
#define NUM_INTENSITIES 256
uniform sampler2D tex;
uniform vec2 texel;
uniform int radius;
uniform int radius_sq;
uniform float exponent;
void main() {
	int i, j;
	vec2 tc = gl_TexCoord[0].st;
	vec4 temp_pixel;

	float max_i = 0., intensity;
	vec4 best_color;
	for (i = -radius; i <= radius; i++)
	{
		for (j = -radius; j <= radius; j++)
			{
				if (i*i + j*j <= radius_sq)
					{
						temp_pixel = texture2D(tex, tc + vec2(i, j) * texel);
						intensity = (0.299 * temp_pixel.r
												+0.587 * temp_pixel.g
												+0.114 * temp_pixel.b);
						if(intensity > max_i)
						{
							max_i = intensity;
							best_color = temp_pixel;
						}
					}
			}
	}
  gl_FragColor = best_color;
}