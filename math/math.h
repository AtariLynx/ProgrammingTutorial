#define MATHAB 0xfc54
#define MATHCD 0xfc52
#define MATHNP 0xfc56
#define MATHEF 0xfc62
#define MATHGH 0xfc60
#define MATHJK 0xfc6e
#define MATHLM 0xfc6c
#define MATHEFGH 0xfc60
#define MATHABCD 0xfc52
#define MATHJKLM 0xfc6c

#define SPRSYS 0xfc92

#define SPRSYS_signed_math 0x80
#define SPRSYS_accumulate 0x40
#define SPRSYS_clear_unsafe_access 0x04
#define SPRSYS_math_error 0x40
#define SPRSYS_unsafe_access 0x04

#define WAITMATH asm("notready: bit $fc92"); asm("  bmi notready");
#define PEEKL(a) (*(long *)(a))
#define POKEL(a,b) (*(long *)(a))=(b)

#define MATHERROR (PEEK(SPRSYS) & SPRSYS_math_error) != 0

long divide(long quotient, unsigned short divisor) 
{
	POKEW(MATHNP, divisor);
	POKEL(MATHEFGH, quotient);
	WAITMATH;
	return PEEKL(MATHABCD);
}

long multiply(unsigned short a, unsigned short b)
{
	POKEW(MATHCD, b);
	POKEW(MATHAB, a);
	WAITMATH;
	return PEEKL(MATHEFGH);
}