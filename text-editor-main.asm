; Text Editor in Assembly
org 100h        ; COM file format starts at offset 100h

section .data
    posX      db 0        ; dh = posX -> controls row
    posY      db 0        ; dl = posY -> controls column
    matrix    times 2000 db ' '  ; 25 lines of 80 chars each
    curr_line dw 0
    curr_char dw 0
    color     db 47       ; 2*16+15

    filename  db "output.txt",0
    handler   dw 0
    length    dw 0
    save_msg  db 'File saved successfully!$'
    error_msg db 'Error saving file!$'

    start_menu_str db '                ====================================================',13,10
                   db '               ||       *     Assembly Text Editor      *          ||',13,10
                   db '               ||        Type in what you want, press ESC          ||',13,10
                   db '               ||               To exit the program.               ||',13,10
                   db '               ||            Press Enter to start                  ||',13,10
                   db '               ||            Press F5 to save file                 ||',13,10
                   db '                ====================================================',13,10,'$'

section .text
    global _start

_start:
    ; Initialize DS register - for COM files
    push cs
    pop ds
    
    ; Display main menu
    call main_menu
    
    ; Main program loop
program_loop:
    call read_char
    jmp program_loop

; Procedures
clear_screen:
    push ax
    mov ax, 0003h    ; Text mode 80x25
    int 10h
    pop ax
    ret

main_menu:
    push ax
    push dx
    mov ah, 09h
    mov dx, start_menu_str
    int 21h
    
wait_key:
    mov ah, 00h
    int 16h
    cmp al, 27      ; ESC
    je exit_program
    cmp al, 13      ; Enter
    je start_editor
    jmp wait_key
    
start_editor:
    call clear_screen
    pop dx
    pop ax
    ret

read_char:
    mov ah, 00h
    int 16h
    
    cmp al, 27          ; ESC
    je exit_program
    cmp ah, 3Fh         ; F5
    je save_file
    cmp ah, 48h         ; Up arrow
    je move_up
    cmp ah, 4Bh         ; Left arrow
    je move_left
    cmp ah, 4Dh         ; Right arrow
    je move_right
    cmp ah, 50h         ; Down arrow
    je move_down
    cmp al, 13          ; Enter
    je new_line
    cmp ah, 47h         ; Home
    je move_home
    
    ; Regular character
    call display_char
    ret

display_char:
    push ax
    push bx
    push si

    ; Display the character
    mov ah, 09h
    mov bh, 0
    mov bl, [color]
    mov cx, 1
    int 10h
    
    ; Store character in buffer
    mov si, matrix      ; Get buffer base address
    add si, [curr_line] ; Add current line offset
    add si, [curr_char] ; Add current character position
    mov [si], al       ; Store the character
    inc word [length]  ; Increment total length
    
    call move_right
    pop si
    pop bx
    pop ax
    ret

move_up:
    mov ah, 03h         ; Get cursor position
    mov bh, 0
    int 10h
    cmp dh, 0          ; At top?
    je cursor_update
    dec dh             ; Move up
    sub word [curr_line], 80
    jmp cursor_update

move_down:
    mov ah, 03h
    mov bh, 0
    int 10h
    cmp dh, 24         ; At bottom?
    je cursor_update
    inc dh             ; Move down
    add word [curr_line], 80
    jmp cursor_update

move_left:
    mov ah, 03h
    mov bh, 0
    int 10h
    cmp dl, 0          ; At left margin?
    je cursor_update
    dec dl             ; Move left
    dec word [curr_char]
    jmp cursor_update

move_right:
    mov ah, 03h
    mov bh, 0
    int 10h
    cmp dl, 79         ; At right margin?
    je cursor_update
    inc dl             ; Move right
    inc word [curr_char]
    jmp cursor_update

move_home:
    mov ah, 03h
    mov bh, 0
    int 10h
    mov dl, 0          ; Move to start of line
    mov word [curr_char], 0
    jmp cursor_update

new_line:
    mov ah, 03h
    mov bh, 0
    int 10h
    inc dh             ; Next line
    mov dl, 0          ; Start of line
    add word [curr_line], 80
    mov word [curr_char], 0
    jmp cursor_update
    
cursor_update:
    mov ah, 02h        ; Set cursor position
    int 10h
    ret

save_file:
    push ax
    push bx
    push cx
    push dx

    ; Create file
    mov ah, 3Ch
    xor cx, cx         ; Normal file attribute
    mov dx, filename
    int 21h
    jc save_error
    
    mov [handler], ax  ; Save file handle
    
    ; Write to file
    mov ah, 40h
    mov bx, [handler]
    mov cx, [length]   ; Number of bytes to write
    mov dx, matrix     ; Buffer to write from
    int 21h
    jc save_error
    
    ; Close file
    mov ah, 3Eh
    mov bx, [handler]
    int 21h
    
    ; Display success message
    mov ah, 09h
    mov dx, save_msg
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

save_error:
    mov ah, 09h
    mov dx, error_msg
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

exit_program:
    mov ah, 4Ch
    int 21h

section .bss
    buffer resb 1024