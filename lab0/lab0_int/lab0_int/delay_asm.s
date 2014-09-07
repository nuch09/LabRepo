
		# real:
        .equ    delaycount,     12497 #set right delay value here!
        					#	16665
        # sim:
        #.equ    delaycount,     54 #set right delay value here!
        
        .text                   # Instructions follow
        .global delay           # Makes "main" globally known

delay:  beq     r4,r0,fin       # exit outer loop

        movi    r8,delaycount   # delay estimation for 1ms

inner:  beq     r8,r0,outer     # exit from inner loop
						# predict correct, take not => 1 cycle on Ni2/s for delaycount times
    					# predict not correct, take => 4 cycle on Ni2/s for 1 time		

        subi    r8,r8,1         # decrement inner counter
        
        br      inner
        				# predict correct, take => 2 cycle on Ni2/s
        
outer:  subi    r4,r4,1         # decrement outer counter
        br      delay


fin:    ret

