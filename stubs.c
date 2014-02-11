#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "misc.h"
#include "mpconfig.h"
#include "qstr.h"
#include "lexer.h"
#include "lexerfatfs.h"
#include "gc.h"

/*
// from stm\lexerfatfs.c
mp_import_stat_t mp_import_stat(const char *path) {
    // TODO implement me!
    return MP_IMPORT_STAT_NO_EXIST;
}
*/

// TODO: move this here, but currently getting undefined reference to `sqrtf' when linking to libm
/*
machine_float_t machine_sqrt(machine_float_t x) {
	// TODO
	// return x;
	return sqrtf((float)x);
}
*/

void *malloc(size_t n) {
    return gc_alloc(n);
}

void free(void *ptr) {
    gc_free(ptr);
}


#ifdef HAVE_INITFINI_ARRAY

/* These magic symbols are provided by the linker.  */
extern void (*__preinit_array_start []) (void) __attribute__((weak));
extern void (*__preinit_array_end []) (void) __attribute__((weak));
extern void (*__init_array_start []) (void) __attribute__((weak));
extern void (*__init_array_end []) (void) __attribute__((weak));
extern void (*__fini_array_start []) (void) __attribute__((weak));
extern void (*__fini_array_end []) (void) __attribute__((weak));

extern void _init (void);
extern void _fini (void);

// Need these if using nostdlib
// Don't need these if using nodefaultlib
#if 0
void _init (void)
{
}

void _fini (void)
{
}
#endif

/* Iterate over all the init routines.  */
void
__libc_init_array (void)
{
	size_t count;
	size_t i;

	count = __preinit_array_end - __preinit_array_start;
	for (i = 0; i < count; i++)
	__preinit_array_start[i] ();

	_init ();

	count = __init_array_end - __init_array_start;
	for (i = 0; i < count; i++)
	__init_array_start[i] ();
}

/* Run all the cleanup routines.  */
void
__libc_fini_array (void)
{
size_t count;
size_t i;
  
count = __fini_array_end - __fini_array_start;
for (i = count; i > 0; i--)
__fini_array_start[i-1] ();

_fini ();
}
#endif

/* Register a function to be called by exit or when a shared library
is unloaded.  This routine is like __cxa_atexit, but uses the
calling sequence required by the ARM EABI.  */
int __aeabi_atexit (void *arg, void (*func) (void *), void *d)
{
// AP: erm... no shared libraries and program doesn't exit
// return __cxa_atexit (func, arg, d);
	return 0;
}


/*
char * ultoa(unsigned long val, char *buf, int radix) 	
{
	unsigned digit;
	int i=0, j;
	char t;

	while (1) {
		digit = val % radix;
		buf[i] = ((digit < 10) ? '0' + digit : 'A' + digit - 10);
		val /= radix;
		if (val == 0) break;
		i++;
	}
	buf[i + 1] = 0;
	for (j=0; j < i; j++, i--) {
		t = buf[j];
		buf[j] = buf[i];
		buf[i] = t;
	}
	return buf;
}
*/

int __errno = 0;



//////////////////////////////////////////////////////////////////////////////

void *memcpy(void *dest, const void *src, size_t n) {
    // TODO align and copy 32 bits at a time
    uint8_t *d = dest;
    const uint8_t *s = src;
    for (; n > 0; n--) {
        *d++ = *s++;
    }
    return dest;
}

void *memmove(void *dest, const void *src, size_t n) {
    if (src < dest && dest < src + n) {
        // need to copy backwards
        uint8_t *d = dest + n - 1;
        const uint8_t *s = src + n - 1;
        for (; n > 0; n--) {
            *d-- = *s--;
        }
        return dest;
    } else {
        // can use normal memcpy
        return memcpy(dest, src, n);
    }
}

void *memset(void *s, int c, size_t n) {
    uint8_t *s2 = s;
    for (; n > 0; n--) {
        *s2++ = c;
    }
    return s;
}

// int memcmp(const char *s1, const char *s2, size_t n) {
int memcmp(const void *s1, const void *s2, size_t n) {
    while (n--) {
        char c1 = *(char*)s1++;
        char c2 = *(char*)s2++;
        if (c1 < c2) return -1;
        else if (c1 > c2) return 1;
    }
    return 0;
}

int strcmp(const char *s1, const char *s2) {
    while (*s1 && *s2) {
        char c1 = *s1++; // XXX UTF8 get char, next char
        char c2 = *s2++; // XXX UTF8 get char, next char
        if (c1 < c2) return -1;
        else if (c1 > c2) return 1;
    }
    if (*s2) return -1;
    else if (*s1) return 1;
    else return 0;
}

int strncmp(const char *s1, const char *s2, size_t n) {
    while (*s1 && *s2 && n > 0) {
        char c1 = *s1++; // XXX UTF8 get char, next char
        char c2 = *s2++; // XXX UTF8 get char, next char
        n--;
        if (c1 < c2) return -1;
        else if (c1 > c2) return 1;
    }
    if (n == 0) return 0;
    else if (*s2) return -1;
    else if (*s1) return 1;
    else return 0;
}

// hacked from...
// C:\devt\arduino\ARM-Toolchain\sources\newlib-2012.09\newlib\libc\string
char *
_DEFUN (strncpy, (dst0, src0),
	char *dst0 _AND
	_CONST char *src0 _AND
	size_t count)
{
  char *dscan;
  _CONST char *sscan;

  dscan = dst0;
  sscan = src0;
  while (count > 0)
    {
      --count;
      if ((*dscan++ = *sscan++) == '\0')
	break;
    }
  while (count-- > 0)
    *dscan++ = '\0';

  return dst0;
}

char *
_DEFUN (strchr, (s1, i),
	_CONST char *s1 _AND
	int i)
{
  _CONST unsigned char *s = (_CONST unsigned char *)s1;
  unsigned char c = i;

  while (*s && *s != c)
    s++;
  if (*s == c)
    return (char *)s;
  return NULL;
}
