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
typedef signed char dis_byte8;
typedef unsigned char dis_ubyte8;
typedef signed short dis_short16;
typedef unsigned short dis_ushort16;
typedef signed int dis_int32;
typedef unsigned int dis_uint32;
typedef signed long dis_long64;
typedef unsigned long dis_ulong64;

typedef float dis_float32;
typedef double dis_double64;

typedef void* dis_ptr;

//for C11 add static_assert for sizeof
//e.g. static_assert(sizeof(void *) == 4, "64-bit code generation is not supported.");

//map runtime types

#endif