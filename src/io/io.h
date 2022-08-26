#ifndef IO_H
#define IO_H

unsigned char insb(unsigned short port); // read one byte from the given port
unsigned short insw(unsigned short port); // read one word from the given port
void outb(unsigned short port, unsigned char val); // output a byte to a port
void outw(unsigned short port, unsigned short val); // output one word to a port


#endif