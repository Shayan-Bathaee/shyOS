#include "kernel.h"
#include "idt/idt.h"
#include <stdint.h>
#include <stddef.h>
#include <io/io.h>

// global variables
uint16_t* video_mem = 0;     // for VGA text mode addressing
uint16_t terminal_row = 0;      // cursor variables to keep track of where we are writing
uint16_t terminal_col = 0; 

// return the 16 bit value depicting a color and a character to be outputted in VGA text mode 
uint16_t terminal_make_char(char c, char color) {
    return (color << 8) | c; // returning 0x[two bye color][two byte character], backwards because of endianness, 0th byte is at the end
}


// place a colored character in the VGA at a specific position
void terminal_put_char(int x, int y, char c, char color) {
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
    return;
}


// print a string in the VGA, and incrememnt the cursor variables (defined in globals)
void terminal_write_char(char c, char color) {
    if (c == '\n') {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }
    terminal_put_char(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if (terminal_col >= VGA_WIDTH) { // move to the next row if we are finished with this one
        terminal_col = 0;
        terminal_row +=  1;
    }
}


// loop through the VGA and clear it. reset the cursor variables
void terminal_initialize() {
    video_mem = (uint16_t*)(0xB8000);     // point to the colored text mode address
    terminal_row = 0;
    terminal_col = 0;

    for (int y = 0; y < VGA_HEIGHT; y++) { // for every character in the VGA
        for (int x = 0; x < VGA_WIDTH; x++) {
            terminal_put_char(x, y, ' ', 0); // set the character to a black space
        }
    }
    return;
}


// get the length of a string
size_t strlen(const char* str) {
    size_t len = 0;
    
    while (str[len] != '\0') {
        len += 1;
    }

    return len;
}


// print a string to the terminal in white
void print(const char* str) {
    size_t len = strlen(str);
    for (int i = 0; i < len; i++) {
        terminal_write_char(str[i], 15);
    }
}




void kernel_main() {
    terminal_initialize();
    print("Hello World!\nThis is a new line");

    // initialize the interrupt descriptor table
    idt_init();

    outb(0x60, 0xff);
    return;
}