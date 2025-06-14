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

;do_div:
;    cmp cx, 0
;    je div_by_zero
;    mov ax, bx
;    xor dx, dx 
;    div cx
;    jmp show_result

do_div:
    cmp cx, 0
    je div_by_zero

    mov ax, bx
    xor dx, dx
    div cx                ; AX = результат (ціла частина), DX = остача
    mov si, offset result + 1
    mov byte ptr [si], '='
    inc si

    cmp ax, 0
    jge show_int_part
    mov byte ptr [si], '-'
    inc si
    neg ax

show_int_part:
    ; виведення цілої частини
    push dx              ; зберігаємо остачу
    call print_number
    pop dx               ; відновлюємо остачу

    ; додати крапку
    mov byte ptr [si], '.'
    inc si

    ; дробова частина: (остача * 100) / cx
    mov ax, dx
    mov dx, 0
    mov bx, 100
    mul bx               ; AX = остача * 100
    xchg cx, bx          
    div bx               ; AX = дробова частина
    xchg cx, bx          

    ; вивести два цифри з дробової частини
    mov bx, 10
    xor cx, cx
    xor dx, dx

    mov dx, ax
    mov ax, dx
    xor dx, dx
    div bx               ; AX = десятки, DX = одиниці
    add al, '0'
    mov [si], al
    inc si
    add dl, '0'
    mov [si], dl
    inc si

    mov byte ptr [si], '$'
    mov dx, offset result + 1
    mov ah, 9
    int 21h
    jmp exit


; кінець нового коду
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
    
;Весь новий код


print_number:
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

.conv_loop_int:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .conv_loop_int

.pop_digits_int:
    pop dx
    mov [si], dl
    inc si
    loop .pop_digits_int

    pop dx
    pop cx
    pop bx
    pop ax
    ret


msgn1       db "Enter num1, operator (+ - * /), num2. Press Enter after each:$"
err_msg     db 13, 10, "Invalid operator!", '$'
err_div     db 13, 10, "Cannot divide by zero!", '$'
msg_eq      db " = :$"

num1        db 3, 0, 3 dup(?)
num2        db 3, 0, 3 dup(?)
operator    db ?
result      db 7 dup(0)
