ENTRY(_start)           /* program entry point */
OUTPUT_FORMAT(binary)   /* keep things simple for now, output as binary */
SECTIONS
{
    . = 1M;             /* our kernel must be loaded into 1 megabyte of memory */
    
    .text : ALIGN(4096)
    {
        *(.text)
    }

    .rodata : ALIGN(4096)
    {
        *(.rodata)
    }

    .data : ALIGN(4096)
    {
        *(.data)
    }

    .bss : ALIGN(4096)
    {
        *(COMMON)
        *(.bss)
    }

    .asm : ALIGN(4096)
    {
        *(.asm)
    }

}