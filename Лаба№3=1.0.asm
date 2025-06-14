org 100h

jmp start

start:
    mov dx, offset msgn1
    mov ah, 9
    int 21h

    mov dx, offset num1
    mov ah, 0Ah
    int 21h

    mov ah, 1
    int 21h
    mov operator, al

    mov dx, offset num2
    mov ah, 0Ah
    int 21h

    mov dx, offset num1
    call str_to_num
    mov bx, ax

    mov dx, offset num2
    call str_to_num
    mov cx, ax

    mov al, operator
    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub
    cmp al, '*'
    je do_mul
    cmp al, '/'
    je do_div
    jmp invalid_operator

do_add:
    mov ax, bx
    add ax, cx
    jmp show_result

do_sub:
    mov ax, bx
    sub ax, cx
    jmp show_result

do_mul:
    mov ax, bx
    mul cx
    jmp show_result

do_div:
    cmp cx, 0
    je div_by_zero
    mov ax, bx
    xor dx, dx 
    div cx
    jmp show_result

invalid_operator:
    mov dx, offset err_msg
    mov ah, 9
    int 21h
    jmp exit

div_by_zero:
    mov dx, offset err_div
    mov ah, 9
    int 21h
    jmp exit

show_result:
    mov si, offset result + 1
    mov byte ptr [si], '='
    inc si

    cmp ax, 0
    jge convert_digits
    mov byte ptr [si], '-'
    inc si
    neg ax

convert_digits:
    mov bx, 10
    xor cx, cx

conv_loop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz conv_loop

pop_digits:
    pop dx
    mov [si], dl
    inc si
    loop pop_digits

    mov byte ptr [si], '$'

    mov dx, offset result+1
    mov ah, 9
    int 21h

exit:
    ret

str_to_num:
    push bx
    push cx
    push dx
    push si
    push di

    mov si, dx
    xor ax, ax
    xor cx, cx
    mov cl, [si+1]
    xor ch, ch
    xor di, di

next_digit:
    cmp di, cx
    je convert_done

    mov bx, si
    add bx, di
    add bx, 2
    mov dl, [bx]
    sub dl, '0'
    cmp dl, 9
    ja convert_done

    mov bl, 10
    mul bl
    add al, dl
    adc ah, 0
    inc di
    jmp next_digit

convert_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

msgn1       db "Enter num1, operator (+ - * /), num2. Press Enter after each:$"
err_msg     db 13, 10, "Invalid operator!", '$'
err_div     db 13, 10, "Cannot divide by zero!", '$'
msg_eq      db " = :$"

num1        db 3, 0, 3 dup(?)
num2        db 3, 0, 3 dup(?)
operator    db ?
result      db 7 dup(0)
