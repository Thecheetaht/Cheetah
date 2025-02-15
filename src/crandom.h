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

#ifndef RANDOM_H_
#define RANDOM_H_

#include <stdint.h>
#include <string.h>

#include "chashfunc.h"
/**
 * Set of some xorshift RNG's. They are all fast as hell, period differs only.
 * http://en.wikipedia.org/wiki/Xorshift
 **/

typedef struct xor_state
{
	uint32_t x;
	uint32_t y;
	uint32_t z;
	uint32_t w;
	uint32_t v;
	uint32_t d;
} xor_state;

static xor_state _xor_ = {123456789, 362436069, 521288629, 88675123, 5783321, 6615241};

static inline xor_state *random_get_state(void)
{
	return &_xor_;
}

static inline void random_set_state(xor_state *state)
{
	memcpy(&_xor_, state, sizeof(xor_state));
}

static inline void random_seed(uint32_t seed)
{
	_xor_.x = seed;
}

static inline void random_hash_seed(uint32_t seed)
{
	_xor_.x = hash_uint32(seed);
}

static inline void random_seed128(uint32_t x, uint32_t y, uint32_t z, uint32_t w)
{
	_xor_.x = x;
	_xor_.y = y;
	_xor_.z = z;
	_xor_.w = w;
}

static inline void random_hash_seed128(uint32_t x, uint32_t y, uint32_t z, uint32_t w)
{
	_xor_.x = hash_uint32(x);
	_xor_.y = hash_uint32(y);
	_xor_.z = hash_uint32(z);
	_xor_.w = hash_uint32(w);
}

static inline void random_seed192(uint32_t x, uint32_t y, uint32_t z, uint32_t w, uint32_t v, uint32_t d)
{
	_xor_.x = x;
	_xor_.y = y;
	_xor_.z = z;
	_xor_.w = w;
	_xor_.v = v;
	_xor_.d = d;
}

static inline void random_hash_seed192(uint32_t x, uint32_t y, uint32_t z, uint32_t w, uint32_t v, uint32_t d)
{
	_xor_.x = hash_uint32(x);
	_xor_.y = hash_uint32(y);
	_xor_.z = hash_uint32(z);
	_xor_.w = hash_uint32(w);
	_xor_.v = hash_uint32(v);
	_xor_.d = hash_uint32(d);
}

static inline uint32_t random_get_seed(void)
{
	return _xor_.x;
}

/**
 * Period: 2^128-1. Fastest: 646M rn/sec @ Intel Pentium 4 3.0 GHz
 **/
static inline uint32_t rand128(void)
{
	uint32_t t;
	t = _xor_.x ^ (_xor_.x << 11);
	_xor_.x = _xor_.y;
	_xor_.y = _xor_.z;
	_xor_.z = _xor_.w;
	return _xor_.w = _xor_.w ^ (_xor_.w >> 19) ^ (t ^ (t >> 8));
}

/**
 * Period: 2^192-2^32. Fast enough: 555M rn/sec @ Intel Pentium 4 3.0 GHz
 **/
static inline uint32_t rand192(void)
{
	uint32_t t;
	t = (_xor_.x ^ (_xor_.x >> 2));
	_xor_.x = _xor_.y;
	_xor_.y = _xor_.z;
	_xor_.z = _xor_.w;
	_xor_.w = _xor_.v;
	_xor_.v = (_xor_.v ^ (_xor_.v << 4)) ^ (t ^ (t << 1));
	return (_xor_.d += 362437) + _xor_.v;
}

/**
 * Period: 2^88. Known as tauss generator. ~2 times slower than xorshift.
 **/
static inline uint32_t rand_t88(void)
{
	uint32_t s1 = _xor_.x, s2 = _xor_.y, s3 = _xor_.z;
	s1 = (uint32_t)(((int32_t)s1 &  -2) << 12) ^ (((s1 << 13) ^  s1) >> 19);
	s2 = (uint32_t)(((int32_t)s2 &  -8) <<  4) ^ (((s2 <<  2) ^  s2) >> 25);
	s3 = (uint32_t)(((int32_t)s3 & -16) << 17) ^ (((s3 <<  3) ^  s3) >> 11);
	_xor_.x = s1;
	_xor_.y = s2;
	_xor_.z = s3;
	return s1 ^ s2 ^ s3;
}

/**
 * Small period, needs 64bit integer... Without seed!
 * It does not pass all tests, it slow, so I kept it just as example.
 **/
static inline uint32_t rand32(void)
{
	static uint64_t y = 123456789;
	y ^= (y << 13);
	y = (y >> 17);
	return (uint32_t)(y ^= (y << 5));
}


/**
 * Return a float from 0.0 to 0.999...
 **/
static inline float randf(uint32_t random_integer)
{
	union
	{
		uint32_t	i;
		float		f;
	} u;
	u.i = 0x3F800000 | (random_integer >> 9);
	return u.f - 1.f;
}
/**
 * Return a float from -1.0 to 0.999...
 **/
static inline float randf2(uint32_t random_integer)
{
	union
	{
		uint32_t	i;
		float		f;
	} u;
	u.i = 0x40000000 | (random_integer >> 9);
	return u.f - 3.f;
}

#endif /* RANDOM_H_ */
