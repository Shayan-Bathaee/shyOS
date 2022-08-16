ORG 0x7C00  ; our bootloader gets loaded into this address by BIOS, so this is the address we want to originate from
BITS 16     ; tell the assembler we are using a 16 bit architecture (because we are in real mode)

start:
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

times 510-($ - $$) db 0     ; pad unused data with 0s
dw 0xAA55                   ; write the boot signature (written backwards due to little endianness)