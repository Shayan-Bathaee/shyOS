ORG 0x7c00
BITS 16                 ; tell the assembler we are using a 16 bit architecture (because we are in real mode)


CODE_SEG equ gdt_code - gdt_start   ; get the offset for protected mode code seg and data seg
DATA_SEG equ gdt_data - gdt_start


_start:
    jmp short start
    nop


times 33 db 0           ; allocate space for Bios Parameter Block and fill it with 0s


start:
    jmp 0:begin_process


begin_process:
    cli                 ; clear & disable interrupts
    ; set segment registers how we want them instead of letting BIOS do it
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax          ; set the stack segment to 0
    mov sp, 0x7c00      ; set the stack pointer to 0
    sti                 ; enable interrupts


load_protected: 
    cli
    lgdt[gdt_descriptor]    ; load global descriptor table
    mov eax, cr0            ; set control register to 1
    or eax, 0x01
    mov cr0, eax
    jmp CODE_SEG:load32     ; switch to code selector and jummp to code segment


; GDT
gdt_start:

gdt_null:
    dd 0
    dd 0

; offset 0x08
gdt_code:       ; CS should point to this. This is our 32 bit protected mode code segment
    dw 0xffff   ; segment limit first 0-15 bits
    dw 0        ; base first 0-15 bits
    db 0        ; base 16-23 bits
    db 0x9a     ; access byte (set bit fields)
    db 0b11001111 ; high and low 4 bit flags
    db 0        ; base 24-31 bits

; offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS should point to this. This is our 32 bit protected mode data segment
    dw 0xffff   ; segment limit first 0-15 bits
    dw 0        ; base first 0-15 bits
    db 0        ; base 16-23 bits
    db 0x92     ; access byte (set bit fields)
    db 0b11001111 ; high and low 4 bit flags
    db 0        ; base 24-31 bits

gdt_end: 


gdt_descriptor:       ; size and offset of the global descriptor table
    dw gdt_end - gdt_start - 1
    dd gdt_start


[BITS 32]   ; code below this is 32 bits
load32: 
    mov ax, DATA_SEG    ; set data registers to 32 bit data segement
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x200000   ; set base pointer
    mov esp, ebp        ; set the stack pointer to the base pointer
    
    jmp $   ; infinite jump



times 510-($ - $$) db 0         ; pad unused data with 0s
dw 0xAA55                       ; write the boot signature (written backwards due to little endianness)


buffer: 