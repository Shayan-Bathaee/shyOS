ENTRY(_start)           /* program entry point */
OUTPUT_FORMAT(binary)   /* keep things simple for now, output as binary */
SECTIONS
{
    . = 1M;             /* our kernel must be loaded into 1 megabyte of memory */
    .text : 
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }

}