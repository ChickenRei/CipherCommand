IDEAL
MODEL small
STACK 100h
p186 ; For pusha and popa
p386 ; For using 32 bits registers
DATASEG
    headline db '   ____ _       _                                  ', 10, 13
             db '  / ___(_)_ __ | |__   ___ _ __                    ', 10, 13
             db ' | |   | | ''_ \| ''_ \ / _ \ ''__|                   ', 10, 13
             db ' | |___| | |_) | | | |  __/ |                      ', 10, 13
             db '  \____|_| .__/|_| |_|\___|_|                    _ ', 10, 13
             db '  / ___|_|_| _ __ ___  _ __ ___   __ _ _ __   __| |', 10, 13
             db ' | |   / _ \| ''_ ` _ \| ''_ ` _ \ / _` | ''_ \ / _` |', 10, 13
             db ' | |__| (_) | | | | | | | | | | | (_| | | | | (_| |', 10, 13
             db '  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|', 10, 13
             db 10, 13, '  Welcome to Ciphar Command! (v1.0.0)', 10, 13
             db '  Copyright (C) 2024 Daniel Reiman. All rights reserved.', 10, 13
             db ''
             db '$'

    menu db 10, 13, '  Please type the desired option number (1, 2 or 3): ', 10, 13
         db '  (1) TEA Encryption', 10, 13
         db '  (2) TEA Decryption', 10, 13
         db '  (3) Quit', 10, 13
         db '$'

    yourChoice db 10, 13, '  Your choice: ', '$'
    errorOptionMessage db 10, 13 , '  Invalid option selected. Please choose either option number 1, 2 or 3.', 10, 13, '$'
    returnMenuPrompt db 13, 10, 10, "  Press any key to go back to the menu... ", 10, 13, '$'

    encryptPlainTextPrompt db 10, 13 ,'  Please enter the message you want to encrypt: ', '$'
    encryptKeyPrompt db 10, 13, '  Please enter a key (do not share this key with anyone): ', '$'
    
    encryptingLoading db 10, 13, 10, 13, '  [System] Encrypting message...', 10, 13, '$'
    encryptingDone db 10, 13, '  [System] Encryption complete!', 10, 13, '$'
    encryptMessage db '  Encrypted Message: ', '$'

    decryptPlaintextPrompt db 10, 13, '  Please enter the message you want to decrypt: ', '$'
    decryptKeyPrompt db 10, 13, '  Please enter a key (use the same key used for encryption): ', '$'

    decryptingLoading db 10, 13, 10, 13, '  [System] Decrypting message...', 10, 13, '$'
    decryptingDone db 10, 13, '  [System] Decryption complete!', 10, 13, '$'
    decryptMessage db '  Decrypted Message: ', '$'

    sepeartor db 10, 13, '  ---------------------------------', 10, 13, '$'
    space db '  $'
    tab db ' ', '$'

    delta dd 9e3779b9h ; 79b9h for 16 bits, 9e3779b9h for 32 bits

    sum dd 0

    plaintextBuffer db 9 dup(0)
    plaintextBufferSize dw plaintextBufferSize - plaintextBuffer - 1

    keyBuffer db 17 dup(0)
    keyBufferSize dw keyBufferSize - keyBuffer - 1
         
	k0  dd 0
	k1  dd 0
	k2  dd 0
	k3  dd 0

    p1 dd 0
	p2 dd 0
; --------------------------
CODESEG

proc clearScreen
    pusha
    mov ah, 00h
    mov al, 03h
    int 10h 
    popa
    ret
endp clearScreen

macro print value
    pusha
    mov ah, 09h
    mov dx, offset value
    int 21h
    popa
endm print

macro printLetter letter
    pusha
    mov dl, letter
    mov ah, 2h
    int 21h
    popa
endm printLetter

proc printLine
    mov dl, 0ah
    mov ah, 2h
    int 21h
    ret
endp printLine

proc inputNumber
    mov ah, 01h
    int 21h
    sub al, 30h ; Input is stored in al

    ret
endp inputNumber

proc waitSeconds
    mov dx, 0
    mov ah, 86h    
    int 15h 
    ret
endp waitSeconds

proc checkUserInput
    checkNumberStart:
    cmp al, 01h
    JE encryptionMode
    
    cmp al, 02h
    JE decryptionMode

    cmp al, 03h
    JE sof

    print errorOptionMessage
    print yourChoice
    call inputNumber
    jmp checkNumberStart
    
    encryptionMode:
        call encryptionSelection
        jmp sof
    decryptionMode:
        call decryptionSelection
    sof:

    ret 
endp checkUserInput

proc userInputPlaintext
    pusha
    ; di = buffer offset
    lea di, [plaintextBuffer]
    ; si = buffer size
    mov si, [plaintextBufferSize]
    mov bx, 00h

    newPlaintextChar:
        mov ah, 01h
        int 21h

        cmp al, 08h ; Check if backspace is pressed
        je handleBackspacePlaintext
        cmp al, 0Dh ; Check if enter is pressed
        je endPlaintextInputBuffer

        mov [di + bx], al

        inc bx

        cmp bx, si
        je endPlaintextInputBuffer

        jmp newPlaintextChar

    handleBackspacePlaintext:
        cmp bx, 00h
        je newPlaintextChar ; If buffer is empty ignore backspace

        mov al, 00h
        mov [di + bx], al ; Clear the character at the current position

        dec bx

        ; Print a space to "erase" character
        mov ah, 02h
        mov dl, ' '
        int 21h
        
        ; Move cursor back
        mov ah, 02h
        mov dl, 08h
        int 21h

        jmp newPlaintextChar

    endPlaintextInputBuffer:

        ; Separate the plaintext into two parts: p1, p2
        xor eax, eax
        mov eax, [di] ; EAX size is 32 bits (4 byte), [di] is the start of the first half and it fill it until eax is full (so it takes the first 4 bytes of the input plaintex)
        mov [p1], eax

        add di, 4 ; Move the second half of the plaintext
        xor eax, eax

        mov eax, [di]
        mov [p2], eax
    popa
    ret
endp userInputPlaintext

proc userInputKey
    pusha
    ; di = buffer offset
    lea di, [keyBuffer]
    ; si = buffer size
    mov si, [keyBufferSize]
    mov bx, 00h

    newKeyChar:
        mov ah, 01h
        int 21h

        cmp al, 08h ; Check if backspace is pressed
        je handleBackspaceKey

        cmp al, 0Dh ; Check if enter is pressed
        je endKeyInputBuffer

        mov [di + bx], al

        inc bx

        cmp bx, si
        je endKeyInputBuffer

        jmp newKeyChar

    handleBackspaceKey:
        cmp bx, 00h
        je newKeyChar ; If buffer is empty ignore backspace
        
        mov al, 00h
        mov [di + bx], al ; Clear the character at the current position

        dec bx

        ; Print a space to "erase" character
        mov ah, 02h
        mov dl, ' '
        int 21h
        
        ; Move cursor back
        mov ah, 02h
        mov dl, 08h
        int 21h

        jmp newKeyChar

        endKeyInputBuffer:

        ; Sepearte the key to four parts: k0, k1, k2, k3
        xor eax, eax
        mov eax, [di] ; EAX size is 32 bits (4 byte), [di] is the start of the first quarter and it fill it until eax is full (so it takes the first 4 bytes of the input key)
        mov [k0], eax

        add di, 4  ; Move the second quarter of the key
        xor eax, eax
        mov eax, [di]
        mov [k1], eax

        add di, 4  ; Move the third quarter of the key
        xor eax, eax
        mov eax, [di]
        mov [k2], eax

        add di, 4  ; Move the fourth quarter of the key
        xor eax, eax
        mov eax, [di]
        mov [k3], eax
    popa
    ret
endp userInputKey

proc encryptionSelection
    print encryptPlainTextPrompt

    call userInputPlaintext

	print encryptKeyPrompt

    call userInputKey

    call encrypt

    print encryptingLoading
    print space
    mov cx, 49 ; Wait 7 seconds
    call waitSeconds

    print encryptingDone
    print space
    mov cx, 9 ; Wait 3 seconds
    call waitSeconds

    print sepeartor
    print encryptMessage
    mov cx, 4
    lea bx, [p1]
    printEncryptP1Loop:
        mov al, [bx]

        printLetter al

        inc bx
    loop printEncryptP1Loop

    mov cx, 4
    lea bx, [p2]
    printEncryptP2Loop:
        mov al, [bx]

        printLetter al

        inc bx
    loop printEncryptP2Loop
    print sepeartor

    ; Reset the values
    mov [sum], 00h
    mov [p1], 00h
    mov [p2], 00h
    mov [k0], 00h
    mov [k1], 00h
    mov [k2], 00h
    mov [k3], 00h

    print returnMenuPrompt

    mov ah, 00h
    int 16h

    call printLine
    call showMenu

    ret
endp encryptionSelection

proc decryptionSelection
    print decryptPlaintextPrompt

    call userInputPlaintext

	print decryptKeyPrompt

    call userInputKey

    call decrypt

    print decryptingLoading
    print space
    mov cx, 25
    call waitSeconds

    print decryptingDone
    print space
    mov cx, 9
    call waitSeconds

    print sepeartor
    print decryptMessage

    mov cx, 4
    lea bx, [p1]
    printDecrpytP1Loop:
        mov al, [bx]

        printLetter al

        inc bx
    loop printDecrpytP1Loop

    mov cx, 4
    lea bx, [p2]
    printDecrpytP2Loop:
        mov al, [bx]

        printLetter al

        inc bx
    loop printDecrpytP2Loop

    print sepeartor

    ; Reset the values
    mov [sum], 00h
    mov [p1], 00h
    mov [p2], 00h
    mov [k0], 00h
    mov [k1], 00h
    mov [k2], 00h
    mov [k3], 00h

    print returnMenuPrompt

    mov ah, 00h
    int 16h

    call printLine
    call showMenu

    ret
endp decryptionSelection

proc encrypt
    pusha

    mov cx, 32
    encryptLoop:
        ; sum += delta
        mov eax, [delta]
        add [sum], eax

        xor eax,eax
        ; ((p2 << 4) + k0)
        mov edx, [p2]
        shl edx, 4
        add edx, [k0]

        ; (p2 + sum)
        mov ebx, [p2]
        add ebx, [sum]

        ; ((p1 << 4) + k0) ^ (p1 + sum)
        xor edx, ebx

        xor ebx, ebx

        ; ((p2 >> 5) + k1)
        mov ebx, [p2]
        shr ebx, 5
        add ebx, [k1]
        ; ((p2 << 4) + k0) ^ (p2 + sum) ^ ((p2 >> 5) + k1)
        xor edx, ebx

        add [p1], edx

        ; ((p1 << 4) + k2)
        mov edx, [p1]
        shl edx, 4
        add edx, [k2]

        ; (p1 + sum)
        mov ebx, [p1]
        add ebx, [sum]

        ; ((p0 << 4) + k2) ^ (p0 + sum)
        xor edx, ebx

        xor ebx, ebx

        ; ((p1 >> 5 ) + k3)
        mov ebx,[p1]
        shr ebx, 5
        add ebx, [k3] 
        ; ((p0 << 4) + k2) ^ (p0 + sum) ^ ((p1 >> 5 ) + k3)
        xor edx, ebx

        add [p2], edx
    loop encryptLoop

    popa
    ret
endp encrypt

proc decrypt
   pusha
    
    mov cx, 32
    fillSum:
        mov eax, [delta]
        add [sum], eax
    loop fillSum

    mov cx, 32
    decryptLoop:
        ; ((p1 << 4) + k2)
        mov edx, [p1]
        shl edx, 4
        add edx, [k2]

        ; (p1 + sum)
        mov ebx, [p1]
        add ebx, [sum]

        ; ((p0 << 4) + k2) ^ (p0 + sum)
        xor edx, ebx

        xor ebx, ebx

        ; ((p1 >> 5 ) + k3)
        mov ebx,[p1]
        shr ebx, 5
        add ebx, [k3] 
        ; ((p0 << 4) + k2) ^ (p0 + sum) ^ ((p1 >> 5 ) + k3)
        xor edx, ebx

        sub [p2], edx

        xor eax,eax
        ; ((p2 << 4) + k0)
        mov edx, [p2]
        shl edx, 4
        add edx, [k0]

        ; (p2 + sum)
        mov ebx, [p2]
        add ebx, [sum]
        
        ; ((p1 << 4) + k0) ^ (p1 + sum)
        xor edx, ebx

        xor ebx, ebx

        ; ((p2 >> 5) + k1)
        mov ebx, [p2]
        shr ebx, 5
        add ebx, [k1]
        ; ((p2 << 4) + k0) ^ (p2 + sum) ^ ((p2 >> 5) + k1)
        xor edx, ebx
        sub [p1], edx

        ; sum -= delta
        mov eax, [delta]
        sub [sum], eax
    loop decryptLoop
    popa


    ret
endp decrypt

proc showMenu
    print menu

    print yourChoice

    call inputNumber

    call checkUserInput

    ret
endp showMenu
start:
    mov ax, @data
    mov ds, ax

    call clearScreen

    print headline
    
    call showMenu
exit:
    mov ax, 4c00h
    int 21h
END start