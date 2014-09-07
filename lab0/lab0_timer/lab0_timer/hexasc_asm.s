        # stub for lab 1, task 2.4
        
        .global hexasc          # makes label "hexasc" globally known
        
        .data                   # area for data - not needed here!

        .text                   # area for instructions

hexasc: andi r4,r4,0xF			# mask out higher bits
		movi r5,0xA
		blt  r4,r5,number		# check for number or character
		
		addi r2,r4,'A'-0xA		# Ascii for 0xA-0xF
		br fin
		
number:
		addi r2,r4,'0'			# Ascii for 0x0-0x9
				
fin:	ret
#        .end                   # The assembler will stop here
