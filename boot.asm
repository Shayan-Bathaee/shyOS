ORG 0
BITS 16                 ; tell the assembler we are using a 16 bit architecture (because we are in real mode)

_start:
    jmp short start
    nop

times 33 db 0           ; allocate space for Bios Parameter Block and fill it with 0s

start:
    jmp 0x7c0:begin_process

handle_zero:
    mov ah, 0x0e
    mov al, 'A'
    mov bx, 0
    int 0x10
    iret


begin_process:
    cli                 ; clear & disable interrupts
    ; set segment registers how we want them instead of letting BIOS do it
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0
    mov ss, ax          ; set the stack segment to 0
    mov sp, 0x7c00      ; set the stack pointer to 0
    sti                 ; enable interrupts

    mov word [ss:0], handle_zero    ; move handle_zero (offset) into first byte of ram using stack segment register (ss = 0, offset = 0)
    mov word [ss:0x02], 0x7c0       ; move the data segment (instruction location) into memory
    int 0                           ; call the interrupt



    mov si, message     ; move the address of the label 'message' into the si register
    call print
    jmp $

print:
    mov ah, 0x0e        ; set us up for printing bios routine
.loop_string:
    lodsb               ; load the next character into al
    cmp al, 0           ; check if the character = 0
    je .done            ; jump on equal to done
    call print_char     ; print char if it is not 0
    jmp .loop_string    ; jump back to get the next character
.done:
    ret


print_char:
    int 0x10            ; call bios routine to output the character and move cursor
    ret

message: db 'Hello World!', 0   ; store the string at the memeory location of 'message'

times 510-($ - $$) db 0         ; pad unused data with 0s
dw 0xAA55                       ; write the boot signature (written backwards due to little endianness)