/*******************************************************************************

Copyright (c) 2012-2013 Pavel Roschin (aka RPG) <rpg89@post.ru>

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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>




#ifdef __ANDROID_API__
#define GL_GLEXT_PROTOTYPES
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#else
#include <SDL.h>
#include <SDL_opengl.h>
#include <search.h>
#endif

#include "macros.h"

#ifndef __CHEETAH_H__
#define __CHEETAH_H__

typedef unsigned char bool;
unsigned char * loadfile(const char * filename, unsigned int * length);

#ifdef _SDL_H
extern SDL_Surface *screen;
#endif

void myError(const char *fmt, ...);


#if 0
typedef struct SDL_Rect {
	short x, y;
	unsigned short w, h;
} SDL_Rect;


struct {
	unsigned int flags;
	void *format;
	int w, h;
	unsigned short pitch;
	void *pixels;
	int offset;
	struct private_hwdata *hwdata;
	SDL_Rect clip_rect;
	unsigned int unused1;
	unsigned int locked;
	struct SDL_BlitMap *map;
	unsigned int format_version;
	int refcount;
} screen;

typedef struct __dirstream {
} DIR;

#endif

struct {
	char GLSL, BE, FBO, VBO, MT, PS;
} supported;

typedef struct Color {
	unsigned char r, g, b, a;
} Color;

/*=================================points=====================================*/
typedef struct Point {
	float x, y;
} Point;

typedef struct Point3 {
	float x, y, z;
} Point3;

/*=================================images=====================================*/
typedef struct Image {
	char *name;
	char *options;
	/* OpenGL texture id */
	unsigned id;
	/* width and height */
	float w, h;
	int channels;
	int queued;
} Image;

typedef Image *pImage;

typedef struct ImageData {
	int w, h, channels;
	char *data;
} ImageData;

typedef struct BorderImage {
	Image * image;
	/* image borders */
	float top, right, bottom, left;
	/* draw border only, without center */
	bool borderOnly;
} BorderImage;

typedef struct Multitexture {
	float w, h;
	int size;
	Image **images;
} Multitexture;

/*================================particles===================================*/
typedef struct ParticleForce {
	unsigned maxParticles;
} ParticleForce;

typedef struct ParticleSystem {
	ParticleForce *forces;
	Point *position;
	Point *speed;
	Point emitterPosition;
	unsigned maxParticles;
	float direction;
	float directionVariation;
	float scale;
	float scaleVariation;
	unsigned emissionRate;
	float gravity;
	unsigned lifeTime;
	Color color;
	Color colorVariation;
} ParticleSystem;

/*=================================atlas======================================*/
typedef struct Atlas {
	Image *image;
	/* original width and height */
	float w, h;
	/* atlas width and height */
	float aw, ah;
	/* offset on atlas*/
	float x, y;
	/*texture coordinates*/
	float tex[8];
} Atlas;

/*==============================framebuffers==================================*/
typedef struct Framebuffer {
	unsigned id;
	Image *image;
} Framebuffer;

/*=================================fonts======================================*/
typedef struct FontChar
{
	/* Width of char */
	float w;
	float v[4], t[4];
} FontChar;

typedef struct Font {
	Image *image;
	float _scale, height, _interval, spacew;
	FontChar ***chars;
	int allocated;
	int mem;
	bool scalable, unicode;
} Font;


/*================================shaders=====================================*/
typedef struct Shader {
	unsigned int id;
} Shader;

/*================================tilemap=====================================*/
typedef struct _Tilemap {
	int w, h;            // size in tiles
	int tw, th;          // single tile size
	float **index;       // texture coords index
	unsigned char **map; // tile indexes map
	int scalable;        // should tilemap be scaled to screen size or drawed per-pixel
	Image *img;
} Tilemap;

/*==================================VBO=======================================*/

typedef struct Vbo {
	unsigned int id, count, tex;
	Point *data;
} Vbo;

enum {
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
	blendMask,
};

enum {
	alignLeft = 1,
	alignCenter,
	alignRight,
	alignJustify,
	align_left = 1,
	align_center,
	align_right,
	align_justify
};

struct {
	double scaleX, scaleY, offsetX, offsetY;
	/*оригинальные ширина и высота, относительно которых считаются все координаты*/
	double origWidth, origHeight;
	double aspect;
	bool autoScale, autoScaleFont;
} screenScale;

typedef struct Resource {
	Image *image;
	unsigned char *data;
	char *name;
	char *options;
	int len;
} Resource;

/*queue*/
#ifdef _SDL_H
SDL_mutex *resQueueMutex;
#endif

#define QDATA Resource
	typedef struct node_t node_t, *node, *queue;
	struct node_t {QDATA val; node prev, next;};
#define QHEAD(q) q->prev
#define QTAIL(q) q->next
#define QEMPTY(q) !QHEAD(q)
queue newQueue();
queue resLoaderQueue;

Resource *resShared;

void imageBind(Image * image);
void initRenderer();

void resetView(int w, int h);

#ifdef _SDL_H
SDL_Event event;
#endif

extern unsigned rescaleTime;
extern unsigned globalTime;
extern double globalTimed;
extern double globalTimeOffsetd;
extern double globalGameSpeed;
extern int resizeDelay;

#ifndef TRUE
#define TRUE (bool) 1
#endif
#ifndef FALSE
#define FALSE (bool) 0
#endif
#endif //__CHEETAH_H__
