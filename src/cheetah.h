/*******************************************************************************

Copyright (c) 2012-2014 Pavel Roschin (aka RPG) <rpg89@post.ru>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:  The above
copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

*******************************************************************************/

#ifndef CHEETAH_H_
#define CHEETAH_H_

#define CHEETAH_EXPORT __attribute__((__visibility__("default")))
#define CHEETAH_INLINE static inline __attribute__((always_inline optimize("-O3")))

#include <stdbool.h>

unsigned char *loadfile(const char *filename, long *length);


void myError(const char *fmt, ...);


#if 0
typedef struct SDL_Rect
{
	short		x, y;
	unsigned short	w, h;
} SDL_Rect;


struct
{
	unsigned int	flags;
	void		*format;
	int		w, h;
	unsigned short	pitch;
	void		*pixels;
	int		offset;
	struct private_hwdata *hwdata;
	SDL_Rect	clip_rect;
	unsigned int	unused1;
	unsigned int	locked;
	struct SDL_BlitMap *map;
	unsigned int	ormat_version;
	int		refcount;
} screen;

typedef struct __dirstream
{
} DIR;

#endif

struct
{
	bool		GLSL;
	bool		BE;
	bool		FBO;
	bool		VBO;
	bool		MT;
	bool		PS;
} supported;

typedef struct Color
{
	unsigned char	r, g, b, a;
} Color;

/*=================================points=====================================*/
typedef struct Point
{
	float x, y;
} Point;

typedef struct Size
{
	short w, h;
} Size;

typedef struct Point3
{
	float x, y, z;
} Point3;

/*=================================images=====================================*/
typedef struct Image
{
	char		*name;
	char		*options;
	/* OpenGL texture id */
	unsigned	id;
	/* width and height */
	float		w, h;
	int		channels;
	int		queued;
} Image;

typedef struct ImageData
{
	int		w, h, channels;
	char		*data;
} ImageData;

typedef struct BorderImage
{
	Image		*image;
	/* image borders */
	float		top;
	float		right;
	float		bottom;
	float		left;
	/* draw border only, without central part */
	bool		borderOnly;
} BorderImage;

typedef struct Multitexture
{
	float		w, h;
	int		size;
	Image 		**images;
} Multitexture;

/*================================particles===================================*/
typedef struct ParticleForce
{
	float		particeStartTime;
	float		particleDuration;
	float		systemStartTime;
	float		systemDuration;
	void	(*function)(void *);
	struct ParticleForce	*next;
	union
	{
		void    *ptrData;
		int      intData;
		long     longData;
		unsigned uintData;
		float    floatData;
		double   doubleData;
		Color    colorData;
		Point    pointData;
	} data;
} ParticleForce;

typedef struct Particle
{
	Point		position;
	Point		speed;
	float		scale;
	float		angle;
	float		age;
	Color		color;
} Particle;

typedef struct ParticleSystem
{
	ParticleForce	*forces;
	Particle	*particles;
	Image		*image;
	Point		emitterPosition;
	unsigned	maxParticles;
	float		emissionRate;
	float		direction;
	float		directionVariation;
	float		startSpeed;
	float		startSpeedVariation;
	float		scale;
	float		scaleVariation;
	float		particleLife;
	float		particleLifeVariation;
	double		lifeTime;
	Color		color;
	Color		colorVariation;
	float		_particlesNeeded;
	double		_lasttime;
	double		_startTime;
	unsigned	_aliveParticles;
} ParticleSystem;

/*=================================atlas======================================*/
typedef struct Atlas
{
	Image		*image;
	/* original width and height */
	float		w, h;
	/* atlas width and height */
	float		aw, ah;
	/* offset on atlas*/
	float		x, y;
	/*texture coordinates*/
	float		tex[8];
} Atlas;

/*==============================framebuffers==================================*/
typedef struct Framebuffer
{
	unsigned	id;
	Image		*image;
} Framebuffer;

/*=================================fonts======================================*/
typedef struct FontChar
{
	/* Width of char */
	float		w;
	float		v[4];
	float		t[4];
	bool kerning;
} FontChar;

typedef struct Font
{
	char		*name;
	unsigned	_size;
	bool		_bold;
	bool		_italic;
	Image		*image;
	void		*hash;
	void		*kerningHash;
	float		 height;
	float		_spacewidth;
	float		_interval;
	float		_scale;
	float		 dfGamma;
	float		 dfSharpness;
	unsigned	 mem;
	bool		 scalable;
	bool		 SDF;
	bool		_kerning;
} Font;

/*================================shaders=====================================*/
typedef struct Shader
{
	unsigned	id;
} Shader;

/*================================tilemap=====================================*/
typedef struct _Tilemap
{
	int		w, h;            /* size in tiles */
	int		tw, th;          /* single tile size */
	float		**index;         /* texture coords index */
	unsigned char	**map;           /* tile indexes map */
	int		scalable;        /* should tilemap be scaled to screen size or drawed per-pixel */
	Image		*img;
} Tilemap;

/*==================================VBO=======================================*/

typedef struct Vbo
{
	unsigned	id, count, tex;
	Point		*data;
} Vbo;

enum
{
        blend_alpha,
        blend_additive,
        blend_multiplicative,
        blend_screen,
        blend_detail,
        blend_substractive,
        blend_difference,
        blend_mask,
        blendAlpha = 0,
        blendAdditive,
        blendMultiplicative,
        blendScreen,
        blendDetail,
        blendSubstractive,
        blendDifference,
        blendMask
};

enum
{
        alignLeft = 1,
        alignCenter,
        alignRight,
        alignJustify,
        align_left = 1,
        align_center,
        align_right,
        align_justify
};

enum
{
        EVENT_QUIT = 1,
        EVENT_KEYUP,
        EVENT_KEYDOWN,
        EVENT_MOUSEUP,
        EVENT_MOUSEDOWN,
        EVENT_MOUSEWHEEL,
        EVENT_RESIZED,
        EVENT_EXPOSED,
        EVENT_SHOWN,
        EVENT_HIDDEN,
        EVENT_MOVED,
        EVENT_MINIMIZED,
        EVENT_MAXIMIZED,
        EVENT_RESTORED,
        EVENT_ENTER,
        EVENT_LEAVE,
        EVENT_FOCUS_GAINED,
        EVENT_FOCUS_LOST,
        EVENT_CLOSE,
        EVENT_ACTIVE,
        EVENT_JOY
};

CHEETAH_EXPORT struct
{
	float		scaleX;
	float		scaleY;
	float		offsetX;
	float		offsetY;
	/* original (first-time defined) width and height, if auto-scale enabled */
	float		origWidth;
	float		origHeight;
	float		aspect;
	bool		autoScale;
	bool		autoScaleFont;
} screenScale;

CHEETAH_EXPORT struct
{
	/* Used to check window resizing */
	unsigned	rescaleTime;
	/* System timers: usigned (milliseconds) and double (seconds) */
	unsigned	time;
	double		timed;
	/* Game time: may be stopped/run faster/run slower than system time */
	double		gameTimed;
	double		timeOffsetd;
	double		gameSpeed;
	unsigned	resizeDelay;
} globalTimers;


#ifndef TRUE
#define TRUE	(bool) 1
#endif
#ifndef FALSE
#define FALSE	(bool) 0
#endif

#endif /* CHEETAH_H_ */
