
#define SEGAWRITE_LONG(x)	( *((volatile unsigned long*)(x)) )
#define SEGAWRITE_WORD(x)	( *((volatile unsigned short*)(x)) )
#define SEGAWRITE_BYTE(x)	( *((volatile unsigned char*)(x)) )

#define SEGAREAD_LONG(x)	( *((volatile const unsigned long*)(x)) )
#define SEGAREAD_WORD(x)	( *((volatile const unsigned short*)(x)) )
#define SEGAREAD_BYTE(x)	( *((volatile const unsigned char*)(x)) )

