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
    jmp CODE_SEG:load32   ; switch to code selector and jummp to code segment

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


[BITS 32]
load32: ; read our kernel using LBA and load it into memory and then jump to it
    mov eax, 1          ; starting sector we want to load from (1, because 0 is the bootloader)
    mov ecx, 100        ; total number of sectors we want to load (matches Makefile)
    mov edi, 0x0100000   ; address we want to load them into (1MB, matches linker)
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read: ; driver to read from disk (will be used to load kernel)
    mov ebx, eax,       ; backup the LBA
    
    ; send highest 8 bits of the lba to hard disk controller
    shr eax, 24         ; shift right eax 24
    or eax, 0xe0        ; select the master drive
    mov dx, 0x1F6
    out dx, al

    ; send the total sectors to the hard disk controller
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; send more bits of the LBA
    mov eax, ebx        ; restore backup lba
    mov dx, 0x1F3
    out dx, al

    ; send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx        ; restore the backup LBA
    shr eax, 8          ; shift right eax 8
    out dx, al

    ; send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx        ; restore the backup LBA
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

; checking if we need to read
.try_again:
    mov dx, 0x1f7       ; read from port 0x1f7 into the al register
    in al, dx
    test al, 8
    jz .try_again

    ; need to read 256 words at a time (512 bytes)
    mov ecx, 256
    mov dx, 0x1F0
    rep insw            ; read a word from the port dx and store it into 0x100000 256 times
    pop ecx
    loop .next_sector
    ; end of reading sectors into memory
    ret


times 510-($ - $$) db 0         ; pad unused data with 0s
dw 0xAA55                       ; write the boot signature (written backwards due to little endianness)

