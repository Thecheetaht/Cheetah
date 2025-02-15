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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cheetah.h"
#include "render.h"
#include "cmacros.h"
#include "cvertex.h"
#include "test.h"

const char *std_vertex_shader = "varying vec2 TexCoord;"
                                "void main()"
                                "{"
                                "gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
                                "gl_FrontColor = gl_Color;"
                                "TexCoord = gl_MultiTexCoord0.xy;"
                                "}";

Shader *initShader(void)
{
	Shader *ptr = NULL;
	new(ptr, Shader, 1);
	return ptr;
}

static bool compile(GLuint shader, const char *name)
{
	GLint compiled;
	GLint blen = 0;
	GLsizei slen = 0;
	GLchar *compiler_log = NULL;
	glCompileShader_(shader);
	glGetShaderiv_(shader, GL_COMPILE_STATUS, &compiled);
	if(!compiled)
	{
		glGetShaderiv_(shader, GL_INFO_LOG_LENGTH , &blen);
		if(blen > 1)
		{
			new(compiler_log, GLchar, blen);
			glGetInfoLog_(shader, blen, &slen, compiler_log);
			myError("Error while compiling shader %s: %s\n", name, compiler_log);
			delete(compiler_log);
		}
		return FALSE;
	}
	return TRUE;
}

CHEETAH_EXPORT void newFragmentVertexShader(Shader *ptr, const char *pix, const char *ver)
{
	GLuint v, f, p;
	GLint linked;
	const GLsizei count = 1;
	NEEDED_INIT_VOID;
	ptr->id = 0;
	if(!supported.GLSL)
	{
		dbg("Trying to create shader, but system doesn't support shaders");
		return;
	}
	v = glCreateShaderObject_(GL_VERTEX_SHADER);
	f = glCreateShaderObject_(GL_FRAGMENT_SHADER);
	glShaderSource_(v, count, &ver, NULL);
	glShaderSource_(f, count, &pix, NULL);
	if(FALSE == compile(v, "string_shader"))
	{
		return;
	}
	if(FALSE == compile(f, "string_shader"))
	{
		glDeleteObject_(v);
		return;
	}
	p = glCreateProgramObject_();
	glAttachObject_(p, v);
	glAttachObject_(p, f);
	glLinkProgram_(p);

	glGetProgramiv_(p, GL_LINK_STATUS, &linked);
	glDeleteObject_(v);
	glDeleteObject_(f);
	if(0 == linked)
	{
		dbg("Error while linking shader");
		return;
	}
	ptr->id = p;
}

CHEETAH_EXPORT void newFragmentShader(Shader *ptr, const char *frag)
{
	newFragmentVertexShader(ptr, frag, std_vertex_shader);
}

CHEETAH_EXPORT bool shaderCheck(Shader *ptr)
{
	return (bool)ptr->id;
}

CHEETAH_EXPORT void deleteShader(Shader *ptr)
{
	if(ptr)
	{
		if(supported.GLSL && ptr->id)
		{
			glDeleteObject_(ptr->id);
		}
	}
	else
	{
		dbg("Trying to free a null-shader. Maybe, you did it manually?");
	}
}

CHEETAH_EXPORT void shaderBind(Shader *ptr)
{
	if(supported.GLSL && ptr->id)
	{
		FLUSH_BUFFER();
		glUseProgramObject_(ptr->id);
	}
}

CHEETAH_EXPORT void shaderUnbind(Shader *ptr)
{
	if(supported.GLSL)
	{
		FLUSH_BUFFER();
		glUseProgramObject_(0);
	}
}

CHEETAH_EXPORT int GetUniformLocation(unsigned program, const char *name)
{
	return glGetUniformLocation_(program, name);
}
CHEETAH_EXPORT void Uniform1i(int location, int var)
{
	glUniform1i_(location, var);
}
CHEETAH_EXPORT void Uniform1f(int location, float var)
{
	glUniform1f_(location, var);
}
CHEETAH_EXPORT void Uniform2f(int location, float var, float var1)
{
	glUniform2f_(location, var, var1);
}
CHEETAH_EXPORT void Uniform3f(int location, float var, float var1, float var2)
{
	glUniform3f_(location, var, var1, var2);
}
CHEETAH_EXPORT void Uniform4f(int location, float var, float var1, float var2, float var3)
{
	glUniform4f_(location, var, var1, var2, var3);
}
