ORG 0
BITS 16                 ; tell the assembler we are using a 16 bit architecture (because we are in real mode)


_start:
    jmp short start
    nop


times 33 db 0           ; allocate space for Bios Parameter Block and fill it with 0s


start:
    jmp 0x7c0:begin_process


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

    ; we are going to try to call a disk read interrupt to read the text message
    mov ah, 0x02    ; read sector command
    mov al, 0x01    ; reading 1 sector
    mov ch, 0x00    ; set the cylinder number to 0
    mov cl, 0x02    ; we want to read sector 2 (sectors start at 1)
    mov bx, buffer  ; bx is our message
    int 0x13        ; call interrupt now that parameters are set

    jc error        ; if the error flag is set, jump to error
    mov si, buffer  ; print our buffer
    call print
    jmp $           ; infinite jump


error:
    mov si, error_message
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


error_message: db 'Failed to load sector', 0


times 510-($ - $$) db 0         ; pad unused data with 0s
dw 0xAA55                       ; write the boot signature (written backwards due to little endianness)


buffer: 