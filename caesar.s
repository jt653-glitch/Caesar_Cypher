.data
    PromptForPlaintext:
        .asciz  "Please enter the plaintext: "
        lenPromptForPlaintext = .-PromptForPlaintext

    PromptForShiftValue:
        .asciz  "Please enter the shift value: "
        lenPromptForShiftValue = .-PromptForShiftValue

    Newline:
        .asciz  "\n"

    ShiftValue:
        .int    0
.bss
    .comm   buffer, 102     # Buffer to read in plaintext/output ciphertext
    .comm   intBuffer, 4    # Buffer to read in shift value
                            # (assumes value is 3 digits or less)

.text

    .globl _start

    .type PrintFunction, @function
    .type ReadFromStdin, @function
    .type GetStringLength, @function
    .type AtoI, @function
    .type CaesarCipher, @function


    PrintFunction:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Write syscall
        movl $4, %eax           # syscall number for write()
        movl $1, %ebx           # file descriptor for stdout
        movl 8(%ebp), %ecx      # Address of string to write
        movl 12(%ebp), %edx     # number of bytes to write
        int $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return

    ReadFromStdin:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Read syscall
        movl $3, %eax
        movl $0, %ebx
        movl 8(%ebp), %ecx      # address of buffer to write input to
        movl 12(%ebp), %edx     # number of bytes to write
        int  $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    GetStringLength:

        # Strings which are read through stdin will end with a newline character. (0xa)
        # So look through the string until we find the newline and keep a count
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        movl 8(%ebp), %esi      # Store the address of the source string in esi
        xor %edx, %edx          # edx = 0

        Count:
			inc %edx            # increment edx
            lodsb               # load the first character into eax
            cmp $0xa, %eax  	# compare the newline character vs eax
            jnz Count           # If eax != newline, loop back

        dec %edx                # the loop adds an extra one onto edx
        movl %edx, %eax          # return value

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    
    AtoI:
    
    #
    # Input is always read in as a string. 
    # This function should convert a string to an integer.
    #

        pushl %ebp # save the caller's base pointer
        movl %esp, %ebp # setup this function's stack frame
        pushl %ebx # save EBX (Use as a scratch register)
        pushl %esi #save ESI (Use as a string pointer)

        movl 8(%ebp), %esi # ESI is the address of the digit string (first argument)
        xorl %eax, %eax # EAX = 0, running total starts at zero
        xorl %ebx, %ebx # EBX = 0, clear upper bits so we can add it to EAX

    AtoILoop:
        movb (%esi), %bl # BL is the current character of the string
        cmpb $'0', %bl # compare character against '0'
        jb AtoIDone # below '0' = not a digit (maybe a newline or null character), stop
        cmpb $'9', %bl # compare character against '9'
        ja AtoIDone # above '9' = not a digit, stop
        subb $'0', %bl # convert ASCII digit to its value from 0-9
        imull $10, %eax # total = total * 10 (Shift previous digits left)
        addl $ebx, %eax # total = total + current digit
        incl %esi # move to the next character
        jmp AtoILoop # repeat for the next character

    AtoIDone:
        popl %esi # restore the caller's ESI
        popl %ebx # restore the caller's EBX
        movl %ebp, %esp # restore the old value of ESP
        popl %ebp # restore the old value of EBP
        ret # return with the integer in EAX



    CaesarCipher:

    #
    # Fill in code for CaesarCipher Function here
    #


    _start:

        # Print prompt for plaintext
        pushl   $lenPromptForPlaintext
        pushl   $PromptForPlaintext
        call    PrintFunction
        addl    $8, %esp

        # Read the plaintext from stdin
        pushl   $102
        pushl   $buffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp


        # Get input string and adjust the stack pointer back after
        pushl   $lenPromptForShiftValue
        pushl   $PromptForShiftValue
        call    PrintFunction
        addl    $8, %esp

        # Read the shift value from stdin
        pushl   $4
        pushl   $intBuffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp

        # Convert the shift value from a string to an integer.
        pushl   $intBuffer      # argument: address of the shift value string
        call    AtoI            # convert it and result comes back in EAX  
        addl    $4, %esp        # remove the argument from the stack
        movl    %eax, ShiftValue 


        # Perform the caesar cipheR
        # FILL IN HERE


        # Get the size of the ciphertext
        # The ciphertext must be referenced by the 'buffer' label
        pushl   $buffer
        call    GetStringLength
        addl    $4, %esp

        # Print the ciphertext
        pushl   %eax
        pushl   $buffer
        call    PrintFunction
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp

        # Exit the program
        Exit:
            movl    $1, %eax
            movl    $0, %ebx
            int     $0x80