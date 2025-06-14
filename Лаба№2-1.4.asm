org 100h

jmp start
;Уже вирішив не ложити все в кучу а поділити на нормальні сегменти і через jmp і call викликати те що треба          
start:
    ; Показзуємо те дефолтне з початку
    mov dx, offset msgn1
    mov ah, 9
    int 21h

    ; 
    mov dx, offset num1
    mov ah, 0Ah
    int 21h

    ; оператор
    mov ah, 1
    int 21h
    mov operator, al

    ; Читтаєм
    mov dx, offset num2
    mov ah, 0Ah
    int 21h

    ; Число num1 зі стрінга в числ
    mov dx, offset num1
    call str_to_num
    mov bx, ax    ; store num1 in BX

    ; Те ж саме для нум2
    mov dx, offset num2
    call str_to_num
    mov cx, ax    ; store num2 in CX

    ; Визначення шо за оппператор, писав діп сік але воркає(не поняв як, буду вдячний якщо поясните)
    mov al, operator
    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub
    jmp invalid_operator

do_add:     ; Саме додавання та віднімання
    mov ax, bx
    add ax, cx
    jmp show_result

do_sub:
    mov ax, bx
    sub ax, cx
    jmp show_result

invalid_operator: ; на випадок якщо юзер даун, не перевіряв чи працює
    mov dx, offset err_msg
    mov ah, 9
    int 21h
    jmp exit

;======================
; Виведеня всього і переведення назад в стрінги для цього
;======================
show_result:
    ; Костиль для введення = перед виводом фінальним
    ;mov si, offset msg_eq + 1
    mov si, offset result + 1
    mov byte ptr [si], '='
    inc si

    ; Переводимо АХ в стрінги
    cmp ax, 0
    jge convert_digits
    mov byte ptr [si], '-'     ; Зберігаємо мінус як знак
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

    mov byte ptr [si], '$'     ; видалення стрінга

    ; Print result
    mov dx, offset result+1
    mov ah, 9
    int 21h

exit:
    ret


;======================
; Оскільки ми все отримуємо в стрінгах то надо перевести в числа. Цей кусок коду був вами ще даний на парі 
;======================
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

;======================
; тут як ви мені ще на парі показали має лежати типу дата яку ми юзаємо
;======================
msgn1       db "Enter num1, operator (+/-), num2. Press Enter after each:$"
err_msg     db 13, 10, "Invalid operator!", '$'
msg_eq      db " = :$"	; костиль для виведення =

num1        db 3, 0, 3 dup(?)     
num2        db 3, 0, 3 dup(?)     
operator    db ?                 
result      db 7 dup(0)