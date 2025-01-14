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

/* TODO: rich text */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <SDL.h>

#include "cheetah.h"
#include "cmacros.h"
#include "render.h"
#include "cvertex.h"
#include "chashtable.h"
#include "test.h"

bool fontShaderFailed = FALSE;
Shader *df_shader = NULL;
const char *fontShaderNormalSource = "#version 120\n\
uniform sampler2D texture;\n\
uniform float sharpness;\n\
uniform float gamma;\n\
varying vec2 TexCoord;\n\
void main() {\n\
	float color = texture2D(texture, TexCoord).a;\n\
	gl_FragColor = vec4(gl_Color.rgb, gl_Color.a * smoothstep(gamma - sharpness, gamma + sharpness, color));\n\
}";

const char *fontShaderFastSource = "#version 120\n\
uniform sampler2D texture;\n\
uniform float sharpness;\n\
uniform float gamma;\n\
varying vec2 TexCoord;\n\
void main() {\n\
	float color = texture2D(texture, TexCoord).a;\n\
	gl_FragColor = vec4(gl_Color.rgb, gl_Color.a * clamp((color - 0.5) * sharpness + 0.5, 0., 1.));\n\
}";

bool shaderCheck(Shader *ptr);
Shader *initShader();
void newFragmentShader(Shader *ptr, const char *frag);
void getWindowSize(int *w, int *h);
void imageBind(Image *image);
CHEETAH_EXPORT void newImageOpt(Image *ptr, const char *name, const char *options);

static inline unsigned fontHashFunc(unsigned key)
{
	return key ^ (key << 7) ^ (key >> 5);
}

static inline unsigned fontCmpFunc(unsigned a, unsigned b)
{
	return a == b;
}

HASH_TEMPLATE_FREE_VALUE(FontHash, unsigned, FontChar *, fontHashFunc, fontCmpFunc)

static void FontHashFreeFunc(FontHashNode *node)
{
	free(node->value);
}

typedef struct KerningPair
{
	unsigned first;
	unsigned second;
} KerningPair;

static inline unsigned kerningHashFunc(KerningPair key)
{
	return key.first * key.second;
}

static inline unsigned kerningCmpFunc(KerningPair a, KerningPair b)
{
	return a.second == b.second && a.first == b.first;
}

HASH_TEMPLATE(KernHash, KerningPair, float, kerningHashFunc, kerningCmpFunc)

CHEETAH_INLINE unsigned fontUnicodeToUint(const char *a, unsigned *ii)
{
	unsigned c;
	unsigned i = *ii;
	if((a[i] & 0b10000000) == 0)
	{
		c  =  (unsigned)a[i++];
	}
	else if (((unsigned)a[i]   & 0b11100000) == 0b11000000)
	{
		c  = ((unsigned)a[i++] & 0b00011111) << 6;
		c |=  (unsigned)a[i++] & 0b00111111;
	}
	else if (((unsigned)a[i]   & 0b11110000) == 0b11100000)
	{
		c  = ((unsigned)a[i++] & 0b00001111) << 12;
		c |= ((unsigned)a[i++] & 0b00111111) << 6;
		c |=  (unsigned)a[i++] & 0b00111111;
	}
	else if (((unsigned)a[i]   & 0b11111000) == 0b11110000)
	{
		c  = ((unsigned)a[i++] & 0b00000111) << 18;
		c |= ((unsigned)a[i++] & 0b00111111) << 12;
		c |= ((unsigned)a[i++] & 0b00111111) << 6;
		c |=  (unsigned)a[i++] & 0b00111111;
	} else {
		c = 0;
	}
	*ii = i;
	return c;
}

CHEETAH_EXPORT void fontEnableSDF(Font *f)
{
	f->SDF = TRUE;
}

CHEETAH_EXPORT void fontDisableSDF(Font *f)
{
	f->SDF = FALSE;
}

/* Calculate width of text block */
CHEETAH_EXPORT float fontWidth(Font *f, const char *str)
{
	float		width = 0;
	float		maxwidth = 0;
	unsigned	c = 0;
	unsigned	i = 0;
	FontChar	*fch;
	unsigned	prevChar = 0;
	while(str[i])
	{
		c = fontUnicodeToUint(str, &i);
		switch(c)
		{
		case ' ':
			width += f->_spacewidth;
			continue;
		case '\n':
			if(width > maxwidth)
			{
				maxwidth = width;
			}
			width = 0;
			continue;
		case '\t':
			width += f->_spacewidth * 8;
			continue;
		}
		if(unlikely(c == 0))
		{
			continue;
		}
		fch = FontHashGet(f->hash, c);
		if(fch)
		{
			width += fch->w;
		}
		if(NULL != f->kerningHash && prevChar > 0)
		{
			KerningPair kp = {prevChar, c};
			float kerning = KernHashGet(f->kerningHash, kp);
			width += kerning;
		}
	}
	if(width > maxwidth)
	{
		maxwidth = width;
	}
	return maxwidth * f->_scale;
}

/* Calculate height of text block */
CHEETAH_EXPORT float fontHeight(Font *currentFont, const char *str, float maxw)
{
	FontChar *ch           = NULL;
	unsigned  i            = 0;
	unsigned  j            = 0;
	unsigned  last_space   = 0;
	unsigned  c            = 0;
	float     width        = 0.0f;
	float     spacew       = currentFont->_spacewidth;
	float     height       = currentFont->height * currentFont->_interval * currentFont->_scale;
	float     y;
	Hash     *hash         = (Hash *)currentFont->hash;
	if(NULL == hash)
	{
		return 0.f;
	}
	maxw /= currentFont->_scale;
	if(FALSE == currentFont->scalable)
	{
		maxw = maxw * screenScale.scaleX;
	}

	y = height;

	if(likely(maxw > 0.0f))
	{
		while(TRUE)
		{
			j = i;
			c = fontUnicodeToUint(str, &i);
			if(unlikely(c == '\0'))
			{
				y += height;
				goto out;
			}
			else if(unlikely(c == '\t'))
			{
				width += spacew * 8;
				last_space = j;
			}
			else if(unlikely(c == ' '))
			{
				last_space = j;
				width += spacew;
			}
			else
			{
				ch = FontHashGet(hash, c);
				if(unlikely(NULL == ch))
				{
					continue;
				}
				width += ch->w;
			}
			if(unlikely(width > maxw || '\n' == c))
			{
				if(0 == last_space || '\n' == c)
				{
					last_space = j;
				}
				y += height;
				if(unlikely(str[last_space] == '\n' || str[last_space] == '\t' || str[last_space] == ' '))
				{
					i = last_space + 1;
				}
				else
				{
					i = last_space;
				}
				last_space = 0;
				width = 0;
			}

		}
	}
	else
	{
		while(str[i])
		{
			c = fontUnicodeToUint(str, &i);
			if(unlikely(c == '\0'))
			{
				goto out;
			}
			else
				if(unlikely(c == '\n'))
				{
					y += height;
				}
		}
	}
out:
	return y;
}

/* Get font one line height */
CHEETAH_EXPORT float fontLineHeight(Font *currentFont)
{
	return currentFont->height * currentFont->_interval * currentFont->_scale;
}
CHEETAH_INLINE float fontCeil(Font *font, float x)
{
	return (font->scalable || font->SDF) ? (x) : ceilf(x);
}

CHEETAH_INLINE void fontDrawChar(Font *currentFont, FontChar *ch, float *x, float h)
{
	float width = fontCeil(currentFont, *x);
	FLUSH_BUFFER_IF_OVERFLOW();
	texCoord[vertexCounter]   = texCoord[vertexCounter+2] = ch->t[0];
	texCoord[vertexCounter+1] = texCoord[vertexCounter+7] = ch->t[1];
	texCoord[vertexCounter+3] = texCoord[vertexCounter+5] = ch->t[3];
	texCoord[vertexCounter+4] = texCoord[vertexCounter+6] = ch->t[2];
	vertexCoord[vertexCounter] = vertexCoord[vertexCounter+2] = ch->v[0]+width;
	vertexCoord[vertexCounter+1] = vertexCoord[vertexCounter+7] = ch->v[1] + h;
	vertexCoord[vertexCounter+3] = vertexCoord[vertexCounter+5] = ch->v[3] + h;
	vertexCoord[vertexCounter+4] = vertexCoord[vertexCounter+6]=ch->v[2]+width;
	_DO_COLOR
	vertexCounter += 8;
	*x += ch->w;
}

// #define KERNING_CONDITION (TRUE == currentFont->_kerning && NULL != currentFont->kerningHash && prevChar > 0 && fontPrevChar && fontPrevChar->kerning)
#define KERNING_CONDITION (NULL != currentFont->kerningHash && fontPrevChar && fontPrevChar->kerning)

static void fontCheckSDF(Font *currentFont, float x, float y, float *maxw)
{
	if(TRUE == currentFont->SDF)
	{
		if(unlikely(NULL == df_shader && FALSE == fontShaderFailed))
		{
			if(FALSE == supported.GLSL)
			{
				fontShaderFailed = TRUE;
			}
			else
			{
				df_shader = initShader();
				newFragmentShader(df_shader, fontShaderFastSource);
				if(FALSE == shaderCheck(df_shader))
				{
					fontShaderFailed = TRUE;
				}
			}
		}
		if(unlikely(TRUE == fontShaderFailed))
		{
			glEnable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, currentFont->dfGamma);
		}
		else
		{
			GLuint gamma_location = glGetUniformLocation_(df_shader->id, "gamma");
			glUseProgramObject_(df_shader->id);
			glUniform1f_(gamma_location, currentFont->dfGamma);
			glUniform1f_(glGetUniformLocation_(df_shader->id, "sharpness"), 4.18f * currentFont->dfSharpness * currentFont->_scale * screenScale.scaleY);
		}
		glScalef(currentFont->_scale, currentFont->_scale, 1);
		glTranslatef(x / currentFont->_scale, y / currentFont->_scale, 0);
	}
	else
	{
		if(FALSE == currentFont->scalable)
		{
			glScalef(currentFont->_scale / screenScale.scaleX, currentFont->_scale / screenScale.scaleY, 1);
			glTranslatef(floorf(x * screenScale.scaleX), floorf(y * screenScale.scaleY), 0);
			*maxw *= screenScale.scaleX;
		}
		else
		{
			glTranslatef(x, y, 0);
			glScalef(currentFont->_scale, currentFont->_scale, 1);
		}
	}
}

static void fontDrawLine(Font *currentFont, const char *str, int align, float h, unsigned c, int spaces, bool end, unsigned *buf, float maxw, float lastw, unsigned  last_space)
{
	float     justifyWidth = currentFont->_spacewidth;
	unsigned  prevChar     = 0;
	float     spacew       = currentFont->_spacewidth;
	FontChar *fontPrevChar = NULL;
	FontChar *ch;
	float x;
	switch(align)
	{
		case alignCenter:
			x = (maxw - lastw) * 0.5f;
			break;
		case alignRight:
			x = maxw - lastw;
			break;
		case alignJustify:
			if(unlikely('\n' == c || TRUE == end))
			{
				justifyWidth = spacew;
			}
			else
			{
				justifyWidth = (maxw + spacew * ((float)spaces) - lastw) / (float)(spaces);
			}
			x = 0;
			break;
		default:
			x = 0;
	}
	float kerningAccumulator = 0.0;
	while(*buf < last_space)
	{
		c = fontUnicodeToUint(str, buf);
		if(unlikely(KERNING_CONDITION))
		{
			KerningPair kp = {prevChar, c};
			float kerning = KernHashGet(currentFont->kerningHash, kp);
			x += kerning;
			if(align == alignJustify)
			{
				kerningAccumulator -= kerning;
			}
		}
		ch = NULL;
		if(unlikely(c == '\t'))
		{
			x += spacew * 8;
		}
		else
			if(unlikely(c == ' '))
			{
				x += justifyWidth + kerningAccumulator;
				kerningAccumulator = 0.0;
			}
			else
			{
				ch = FontHashGet(currentFont->hash, c);
				if(unlikely(NULL == ch))
				{
					continue;
				}
				fontDrawChar(currentFont, ch, &x, h);
			}
		prevChar = c;
		fontPrevChar = ch;
	}
}

static void fontDrawTail(Font *currentFont, const char *str, float oldy)
{
	FontChar *fontPrevChar = NULL;
	FontChar *ch;
	unsigned  prevChar     = 0;
	unsigned c;
	unsigned i = 0;
	float y = 0.0f;
	float x = 0.0f;
	float height = currentFont->height * currentFont->_interval;
	float spacew = currentFont->_spacewidth;
	float screenH;
	int sw, sh;
	getWindowSize(&sw, &sh);
	screenH = sh;
	while(str[i])
	{
		c = fontUnicodeToUint(str, &i);
		ch = NULL;
		switch(c)
		{
		case ' ':
			x += spacew;
			break;
		case '\n':
			x = 0;
			y += height;
			if((y + oldy) * currentFont->_scale > screenH)
			{
				break;
			}
			break;
		case '\t':
			x += spacew * 8;
			break;
		default:
			ch = FontHashGet(currentFont->hash, c);
			if(unlikely(NULL == ch))
			{
				continue;
			}
			if(unlikely(KERNING_CONDITION))
			{
				KerningPair kp = {prevChar, c};
				float kerning = KernHashGet(currentFont->kerningHash, kp);
				x += kerning;
			}
			fontDrawChar(currentFont, ch, &x, fontCeil(currentFont, y));
		}
		prevChar = c;
		fontPrevChar = ch;
	}
}

CHEETAH_EXPORT void __attribute__((optimize("-O3"))) fontPrintf(Font *currentFont, const char *str, float x, float y, float maxw, int align)
{
	
	float     oldy         = y / currentFont->_scale;
	Hash     *hash         = currentFont->hash;
	
	if(unlikely(NULL == hash))
	{
		return;
	}
	// if(maxw > 0.0f)
	{
		maxw /= currentFont->_scale;
		// if(maxw == 0.0f) maxw = 0.0001f;
	}
	FLUSH_BUFFER();
	glPushMatrix();
	fontCheckSDF(currentFont, x, y, &maxw);

	imageBind(currentFont->image);
	if(likely(maxw > 0.0f))
	{
		float     height       = currentFont->height * currentFont->_interval;
		float     spacew       = currentFont->_spacewidth;
		float     h            = 0.0f;
		float     lastw        = 0.0f;
		float     width        = 0.0f;
		unsigned  i            = 0;
		unsigned  j            = 0;
		unsigned  c            = 0;
		unsigned  buf          = 0;
		unsigned  prevChar     = 0;
		unsigned  last_space   = 0;
		int       spaces       = -1;
		FontChar *ch           = NULL;
		FontChar *fontPrevChar = NULL;
		bool      end          = FALSE;
		bool      yOutScreen   = FALSE;
		float     screenH;
		int sw, sh;
		getWindowSize(&sw, &sh);
		screenH = sh;
		y = 0.0;
		while(TRUE)
		{
			j = i;
			c = fontUnicodeToUint(str, &i);
			if(unlikely(c == '\0'))
			{
				end = TRUE;
			}
			else if(unlikely(c == '\t'))
			{
				width += spacew * 8;
				last_space = j;
				lastw = width;
			}
			else if(unlikely(c == ' '))
			{
				last_space = j;
				lastw = width;
				spaces++;
				width += spacew;
			}
			else
			{
				ch = FontHashGet(hash, c);
				if(unlikely(NULL == ch))
				{
					continue;
				}
				width += ch->w;
			}
			/* drop invisible lines - great performance improvement for long texts */
			yOutScreen = (y + oldy + height) * currentFont->_scale > 0.0f;
			/* drop kerning computation for invisible lines - speed +15% */
			if(unlikely(yOutScreen))
				if(unlikely(KERNING_CONDITION))
				{
					KerningPair kp = {prevChar, c};
					width += KernHashGet(currentFont->kerningHash, kp);
				}
			prevChar = c;
			fontPrevChar = ch;
			if(unlikely(width > maxw || '\n' == c || TRUE == end))
			{
				prevChar = 0;
				fontPrevChar = NULL;
				if(0 == last_space || '\n' == c || TRUE == end)
				{
					last_space = j;
					lastw = width;
				}
				if(buf == last_space)
				{
					last_space++;
				}
				/* dropping invisible lines from top */
				if(unlikely(yOutScreen))
				{
					fontDrawLine(currentFont, str, align, h, c, spaces, end, &buf, maxw, lastw, last_space);
				}
				else
				{
					buf = last_space;
				}
				if(unlikely(TRUE == end))
				{
					break;
				}
				y += height;
				/* dropping invisible lines from buttom */
				if(unlikely((y + oldy) * currentFont->_scale > screenH))
				{
					break;
				}
				h = fontCeil(currentFont, y);
				if(unlikely(str[buf] == '\n' || str[buf] == '\t' || str[buf] == ' '))
				{
					i = buf = last_space + 1;
				}
				else
				{
					i = buf = last_space;
				}
				last_space = 0;
				width = 0;
				spaces = -1;
				// prevChar = 0;
				// fontPrevChar = NULL;
			}

		}
	}
	else
	{
		fontDrawTail(currentFont, str, oldy);
	}
	FLUSH_BUFFER();
	glPopMatrix();
	if(TRUE == currentFont->SDF)
	{
		if(unlikely(TRUE == fontShaderFailed))
		{
			glDisable(GL_ALPHA_TEST);
		}
		else
		{
			glUseProgramObject_(0);
		}
	}
}

CHEETAH_EXPORT void fontScale(Font *font, float scale)
{
	font->scalable = TRUE;
	font->_scale = scale;
}

CHEETAH_EXPORT void fontInterval(Font *font, float interval)
{
	font->_interval = interval;
}

CHEETAH_EXPORT float fontGetScale(Font *font)
{
	return font->_scale;
}

CHEETAH_EXPORT float fontGetInterval(Font *font)
{
	return font->_interval;
}

static bool fontSetGlyph(Font *ptr, const char *line)
{
	float cx2 = 0.0;
	float cy2 = 0.0;
	float x1  = 0.0;
	float y1  = 0.0;
	float x2  = 0.0;
	float y2  = 0.0;
	float cx1 = 0.0;
	float cy1 = 0.0;
	float w   = 0.0;
	float h   = 0.0;
	unsigned ch = 0;
	FontChar *fch = NULL;
	if(sscanf(line, "%11u %10f %10f %10f %10f %10f %10f %10f %10f", &ch, &x1, &y1, &x2, &y2, &cx1, &cy1, &w, &h) != 9)
	{
		return FALSE;
	}
	if(NULL == ptr->hash)
	{
		ptr->hash = FontHashNew();
		new0(fch, FontChar, 1);
		FontHashSet(ptr->hash, '\0', fch);
		fch = NULL;
		new0(fch, FontChar, 1);
		FontHashSet(ptr->hash, '\n', fch);
		fch = NULL;
		ptr->mem += (unsigned)sizeof(Hash)
		            + (unsigned)sizeof(Font) + (unsigned)sizeof(FontChar) * 2
		            + hashSize(ptr->hash) * (unsigned)sizeof(FontHashNode);
	}
	new0(fch, FontChar, 1);
	x1 = x1 / (float)ptr->image->w;
	y1 = y1 / (float)ptr->image->h;
	cx2 = cx1 + x2;
	cy2 = cy1 + y2;
	x2 = x1 + x2 / (float)ptr->image->w;
	y2 = y1 + y2 / (float)ptr->image->h;
	float ver[] = {cx1, cy1, cx2, cy2};
	float tex[] = {x1,  y1,  x2,  y2};
	memcpy(fch->v, ver, sizeof(ver));
	memcpy(fch->t, tex, sizeof(tex));
	fch->w = w;
	FontHashSet(ptr->hash, ch, fch);
	ptr->mem += (unsigned)sizeof(FontChar);
	if(' ' == ch)
	{
		ptr->_spacewidth = w;
		fch = NULL;
		new0(fch, FontChar, 1);
		fch->w = w * 8;
		FontHashSet(ptr->hash, '\t', fch);
		ptr->mem += (unsigned)sizeof(FontChar);
	}
	ptr->height = h;
	return TRUE;
}

static bool fontSetKerning(Font *ptr, const char *line)
{
	unsigned	first;
	unsigned	second;
	float		kerning;
	if(sscanf(line, "%10u %10u %10f", &first, &second, &kerning) != 3)
	{
		return FALSE;
	}
	if(NULL == ptr->kerningHash)
	{
		ptr->kerningHash = (void *)KernHashNewSize(64);
		ptr->mem += (unsigned)sizeof(Hash) + hashSize(ptr->kerningHash) * (unsigned)sizeof(KernHashNode);
	}
	KerningPair kp = {first, second};
	KernHashSet(ptr->kerningHash, kp, kerning);
	if(NULL == ptr->hash)
	{
		return FALSE;
	}
	FontChar *fch = FontHashGet(ptr->hash, first);
	/* mark that this char has kerning (much faster kerning access) */
	if(fch)
	{
		fch->kerning = TRUE;
	}
	return TRUE;
}

CHEETAH_EXPORT Font *newFont(const char *filename, bool scalable)
{
	Font *currentFont = NULL;
	FILE *f = NULL;
	Image *image = NULL;
	bool kerning = FALSE;
	char line[256];
	RETURN_NULL_IF_NULL(filename);
	errno = 0;
	f = fopen(filename, "rt");
	ERROR_IF_NULL(f);
	while(fgets(line, sizeof(line), f))
	{
		char *p;
		if(currentFont && strncmp(line, "kerning pairs:", strlen("kerning pairs:")) == 0)
		{
			currentFont->_kerning = kerning = TRUE;
			dbgv("Kerning mode");
			continue;
		}
		if(strncmp(line, "textures: ", strlen("textures: ")) == 0)
		{
			char *imgfile;
			imgfile = p = line + strlen("textures: ");
			while(*p && *p != '\n' && *p != '\r') p++;
			*p = '\0';
			dbgv("Texture: %s", imgfile);
			new0(image, Image, 1);
			newImageOpt(image, imgfile, scalable ? "instant" : "instant nearest");
			continue;
		}
		if(currentFont && currentFont->image)
		{
			if(kerning)
			{
				if(fontSetKerning(currentFont, line))
				{
					continue;
				}
			}
			else
			{
				if(fontSetGlyph(currentFont, line))
				{
					continue;
				}
			}
		}
		p = strstr(line, "pt");
		if(NULL == p)
		{
			p = strstr(line, "px");
		}
		if(NULL != p)
		{
			char *start, *end;
			long size;
			start = p - 1;
			/* scan digits */
			while(start > line && isdigit(*start)) start--;
			size = strtol(start, &end, 10);
			if(end == p)
			{
				/* ok, create new font */
				Font *font = NULL;
				new0(font, Font, 1);
				font->_scale = 1.0f;
				font->_interval = 1.0f;
				font->dfGamma = 0.5f;
				font->dfSharpness = 1.0f;
				font->image = image;
				*start = '\0';
				font->name = strdup(line);
				font->_size = (unsigned)size;
				dbgv("Font: '%s' size: %ld", line, size);
				if(strstr(p + 2, "bold"))
				{
					font->_bold = TRUE;
				}
				if(strstr(p + 2, "italic"))
				{
					font->_italic = TRUE;
				}
				/* reset kerning for this font */
				kerning = FALSE;
				currentFont = font;
			}
		}
	}
	return currentFont;
error:
	printf("Cannot load file %s (%s)", filename, strerror(errno));
	free(image);
	return NULL;
}

CHEETAH_EXPORT void deleteFont(Font *ptr)
{
	if(NULL == ptr)
	{
		dbg("Trying to free a null-font. Maybe, you did it manually?");
		return;
	}
	if(NULL != ptr->hash)
	{
		//FontHash *h = ptr->hash;
		//HASH_FOREACH(i, h, n)
		//{
			//delete(n->value);
		//}
		hashDestroy(ptr->hash);
	}
	if(NULL != ptr->kerningHash)
	{
		hashDestroy(ptr->kerningHash);
	}
}
