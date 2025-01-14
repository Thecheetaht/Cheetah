#version 120

uniform vec2 resolution;
uniform float time;
varying vec2 TexCoord;

//Object A (tunnel)
float oa(vec3 q)
{
	return cos(q.x)+cos(q.y*1.5)+sin(q.z);
}

//Object B (ribbon)
float ob(vec3 q)
{
	return length(max(abs(q-vec3(cos(q.z*1.5)*.3,-.5+cos(q.z)*.2,.0))-vec3(.125,.02,time+3.),vec3(.0)));
}

//Scene
float o(vec3 q)
{
	return oa(q);
}

//Get Normal
vec3 gn(vec3 q)
{
	vec3 f=vec3(.01,0,0);
	return normalize(vec3(o(q+f.xyy),o(q+f.yxy),o(q+f.yyx)));
}

//MainLoop
void main(void)
{
	vec2 p = -1.0 + 2.0 * TexCoord;
	p.x *= resolution.x/resolution.y;

	vec4 c=vec4(1.0);
	vec3 org=vec3(sin(time)*.5,cos(time*.5)*.25+.25,time),dir=normalize(vec3(p.x*1.6,p.y,1.0)),q=org,pp;
	float d=.0;
	int i;
	//First raymarching
	q+=dir;
	#pragma unroll
	for(i = 0; i < 12; i++)
	{ 
		d=o(q);
		q+=d*dir;
	}
	pp=q;
	float f=length(q-org)*0.02;

	//Second raymarching (reflection)
	dir=reflect(dir,gn(q));
	q+=dir;
	#pragma unroll
	for(i = 0; i < 12; i++)
	{ 
		d=o(q);
		q+=d*dir;
	}
	c=+vec4(.3,.5,.5,1.)*min(length(q-org)*.04,1.);

	//Final Color
	vec4 fcolor = ((c+vec4(f))+(1.-min(pp.y+1.9,1.))*vec4(1.,.8,.7,1.))*min(time*.5,1.);
	gl_FragColor=vec4(c.xyz,1.0);
}