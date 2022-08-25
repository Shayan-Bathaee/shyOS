[BITS 32]   ; code below this is 32 bits
global _start ; export the symbol
extern kernel_main  ; reference function in kernel.c

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start: 
    mov ax, DATA_SEG    ; set data registers to 32 bit data segement
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x200000   ; set base pointer
    mov esp, ebp        ; set the stack pointer to the base pointer

    in al, 0x92         ; enable the A20 Line
    or al, 2
    out 0x92, al

    call kernel_main    ; call function in kernel.c
    jmp $   ; infinite jump

times 512-($ - $$) db 0 ; align