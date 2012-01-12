/**
* dis.h
* Basic Header File for C Code Generation
*/
#ifndef __DIS_H__
#define __DIS_H__

#include <stdbool.h>

//TODO Add platform specific configurations

typedef void dis_void;
typedef bool dis_bool;
typedef signed char dis_byte;
typedef unsigned char dis_ubyte;
typedef signed short dis_short
typedef unsigned short dis_ushort;
typedef signed int dis_int;
typedef unsigned int dis_uint;
typedef signed long dis_long;
typedef unsigned long dis_ulong;

typedef float dis_float;
typedef double dis_double;

typedef void* dis_ptr;

//for C11 add static_assert for sizeof
//e.g. static_assert(sizeof(void *) == 4, "64-bit code generation is not supported.");

#endif