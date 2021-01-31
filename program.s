;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date				 31/01/2021
;
;@PROJECT GROUP
;@groupno 37
;@member1 Ali Kerem Yildiz
;@member2 Yekta Can Tursun
;@member3 Elaa Jamazi
;@member4 Lal Verda Cakir
;@member5 Khayal Huseynov
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
					EXPORT SysTick_Handler
					PUSH{LR, R4-R7}
					LDR R0, =TICK_COUNT				; get TICK_COUNT's address
					LDR R1, [R0]					; get TICK_COUNT's value
					ADDS R1, R1, #1					; increment TICK_COUNT
					STR R1, [R0]					; store incremented TICK_COUNT
					LDR R4, =INDEX_INPUT_DS			; get INDEX_INPUT_DS's address
					LDR R5, [R4]					; get INDEX_INPUT_DS's value
					LDR R0, =IN_DATA				; get IN_DATA address
					LDR R1, =IN_DATA_FLAG			; get IN_DATA_FLAG address
					MOVS R2, #4						; array element size
					MULS R2, R5, R2					; multiply index by array element size
					LDR R6,	[R0, R2]				; get data
					LDR R7, [R1, R2]				; get operation
					CMP R7, #0						; if op is remove
					BEQ Handler_remove				; go to Handler remove
					CMP R7, #1						; if op is insert
					BEQ Handler_insert				; go to Handler insert
					CMP R7, #2						; if op is linkedlist2array
					BEQ Handler_ll2a				; go to Handler linkedlist2array
					MOVS R0, #6						; write no operation
Handler_writeError	CMP R0, #0						; if there is no error
					BEQ Handler_return				; don't write to LOG_MEM
					MOVS R1, R0						; move error code to R1 as argument
					MOVS R0, R5						; get INDEX_INPUT_DS's value as argument
					MOVS R2, R7						; get operation as argument
					MOVS R3, R6						; get input data as argument
					BL WriteErrorLog				; WriteErrorLog(Index, ErrorCode, Operation, Data)
Handler_return		ADDS R5, R5, #1					; INDEX_INPUT_DS's value ++
					STR R5, [R4]					; store incremented INDEX_INPUT_DS
					MOVS R3, #4						; array element size
					MULS R3, R5, R3					; get offset
					LDR R0, =IN_DATA				; get IN_DATA address
					ADDS R3, R3, R0					; get actual address
					LDR R2, =END_IN_DATA			; get end of input dataset array
					CMP R3, R2						; check if we reached end
					BEQ Handler_End					; if so, branch here
					POP{R7, R6, R5, R4, PC}			; return from SysTick
				
Handler_remove		MOVS R0, R6						; get data as argument (R0)
					BL Remove						; Remove(data)
					B Handler_writeError			; go to error writing portion
Handler_insert		MOVS R0, R6						; get data as argument (R0)
					BL Insert						; Insert(data)
					B Handler_writeError			; go to error writing portion
Handler_ll2a		BL LinkedList2Arr				; LinkedList2Arr()
					B Handler_writeError			; go to error writing portion
Handler_End			BL SysTick_Stop					; call SysTick_Stop()
					POP{R7, R6, R5, R4, PC}			; return from SysTick
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------
				;CPU Clock Frequency: 4 MHz (4 * 10^6 Hz)
				;Period Of the System Tick Timer Interrupt: 985 µs (0.000985 sec) (985 * 10^-3 sec)
				;ReloadValue + 1 = Freq * Period
				;ReloadValue + 1 = 4 * 10^6 Hz * 0.000985 sec
				;ReloadValue + 1 = 3940
				;ReloadValue = 3939
				;3939 decimal = F63 in hexadecimal
				;initializes System Tick Timer registers
				LDR R0, =0xE000E010					; Get the address of SYST_CSR
				LDR R1, =0xF63						; Calculated Reload Value (3939 decimal)
				STR R1, [R0, #4]					; write Reload Value to SYST_RVR
				;start the timer
				LDR R1, [R0, #0]					; Get the value of SYST_CSR
				LDR R2, =0x7						; CLKSOURCE TICKINT ENABLE should be 1 (0b111)
				ORRS R2, R1, R2						; Make these values 1
				STR R2, [R0, #0]					; Write changed value of SYST_CSR back
				;update the program status register
				LDR R0, =PROGRAM_STATUS				; Get the address of PROGRAM_STATUS variable
				MOVS R1, #1							; store value 1 in R1
				STR R1, [R0, #0]					; set PROGRAM_STATUS as 1
				
				BX LR								; return from function
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				; turn off timer
				LDR R0, =0xE000E010					; Get the address of SYST_CSR
				LDR R1, [R0]						; Get value of SYST_CSR
				LDR R2, =0xFFFFFFFC					; Disable TICKINT and ENABLE bits
				ANDS R1, R1, R2						; clear the least significant 2 bits of SYST_CSR
				STR R1, [R0]						; Store back the value to SYST_CSR
				; clear the interrupt flag
				LDR R0, =0xE000ED04					; load address of ICSR
				LDR R2, [R0]						; get value of ICSR
				LDR R1, =0x02000000					; set PENDSTCLR bit of ICSR to 1
				ORRS R2, R2, R1						; combine value and R1
				STR R2, [R0]						; store cleared flag back
				;update the program status register
				LDR R0, =PROGRAM_STATUS				; Get the address of PROGRAM_STATUS variable
				MOVS R1, #2							; store value 2 in R1
				STR R1, [R0, #0]					; set PROGRAM_STATUS as 2
				BX LR								; return back
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
							LDR R0, =AT_SIZE					; Get value of allocation table size
							MOVS R3, #0							; Use R3 as iterator
							LDR R1, =AT_MEM						; Get address of AT_MEM
							MOVS R2, #0							; get value to be stored

clear_alloc_loop			CMP R0, R3				; compare R0 with R3 (iterator)
							BEQ return_clear_alloc	; return back if equal
							
							STR R2, [R1, R3]		; write 0 to R1 + R3
							ADDS R3, R3, #4			; i++
							B clear_alloc_loop		; go back to condition check
							
return_clear_alloc			BX LR					; return back
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------		
							
							LDR R0, =LOG_ARRAY_SIZE				; Get value of LOG_ARRAY_SIZE
							MOVS R3, #0							; Use R3 as iterator
							LDR R1, =LOG_MEM					; Get address of LOG_MEM
							MOVS R2, #0							; get value to be stored

clear_error_loop			CMP R0, R3				; compare R0 with R3 (iterator)
							BEQ return_error_alloc	; return back if equal
							
							STR R2, [R1, R3]		; write 0 to R1 + R3
							ADDS R3, R3, #4			; i++
							B clear_error_loop		; go back to condition check
							
return_error_alloc			BX LR					; return back
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				MOVS R0, #0					; value to be stored
				LDR R1, =TICK_COUNT			; get address of TICK_COUNT
				STR R0, [R1]				; write 0 to TICK_COUNT
				LDR R1, =FIRST_ELEMENT		; get address of FIRST_ELEMENT
				STR R0, [R1]				; write 0 to FIRST_ELEMENT
				LDR R1, =INDEX_INPUT_DS		; get address of INDEX_INPUT_DS
				STR R0, [R1]				; write 0 to INDEX_INPUT_DS
				LDR R1, =INDEX_ERROR_LOG	; get address of INDEX_ERROR_LOG
				STR R0, [R1]				; write 0 to INDEX_ERROR_LOG
				LDR R1, =PROGRAM_STATUS		; get address of PROGRAM_STATUS
				STR R0, [R1]				; write 0 to PROGRAM_STATUS
				BX LR						; return back
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
						PUSH{R4-R7}					; preserve R4-R7
						MOVS R0, #0					; use as word iterator, set it to 0 (0->AT_SIZE)
						MOVS R6, #0					; use as bit accumulator	(0->AT_SIZE)
						LDR R1, =AT_SIZE			; get AT_SIZE value
						LDR R2, =AT_MEM				; get address of AT_MEM
malloc_loop1			CMP R0, R1					; check if we reached end of AT
						BEQ return_malloc_error		; return error code (0)
						
						LDR R3, [R2, R0]			; get a word of AT
						MOVS R5, #0					; use as temporary bit iterator, set it to 0 (0->32)
						MOVS R4, #1					; value to be ANDed by
malloc_loop2			CMP R5, #32					; if equal to 32
						BEQ return_exit_loop2		; return from the second for loop
						
						MOVS R7, R4
						ANDS R7, R3, R7				; get a bit of word
						CMP R7, #0					; if node is empty
						BEQ return_malloc_address	; return the address of it
						ADDS R5, R5, #1				; increment bit iterator
						ADDS R6, R6, #1				; increment bit accumulator
						LSLS R4, #1					; do bitwise left shift
						B malloc_loop2				; go to next iteration of second for loop
						
return_exit_loop2		ADDS R0, R0, #4				; go to next word
						B malloc_loop1				; go to next iteration of first for loop
						
return_malloc_address	ORRS R3, R3, R4				; found area marked as 1 because this field going to used
						STR R3, [R2, R0]			; allocation table updated
						LDR R0, =DATA_MEM			; R0 gets DATA_MEM's address
						MOVS R1, #8					; Each cell has 2 word and each word is 4 byte.
						MULS R6, R1, R6				; R6 contains the information that how many iteration that we did and by multiplying it by R1 gives kind of offset
						ADDS R0, R6, R0				; by adding R6 to R0, R0 has new allocable areas address
						POP{R7, R6, R5, R4}			; pop preserved registers R4-R7
						BX LR					
						
return_malloc_error		MOVS R0, #0						; it cannot allocate any area, so return 0 as asked.
						BX LR
						
						

;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
						PUSH{R4}							; preserve registers that will be used inside function
						LDR R1, =DATA_MEM					; get address of DATA_MEM
						MOVS R2, #0							; use R2 as allocation table traverser, set it to 0
						LDR R3, =AT_MEM						; get address of AT_MEM
						MOVS R4, #1							; value to be negated
free_loop				CMP R1, R0							; check addresses
						BNE free_next_check					; go to next address
						
						; if equal, address is found
						LDR R1, [R3, R2]					; get the word
						BICS R1, R1, R4						; negate R4
						STR R1, [R3, R2]					; allocation table write 0
						POP{R4}								; get back the preserved registers from stack
						BX LR								; return after freeing address

free_next_check			LSLS R4, #1							; shift left by 1 bit
						CMP R4, #0							; ensure circular rotation
						BNE free_next						; if value overflowed
						MOVS R4, #1							; reset it (if not skip this line)
						ADDS R2, R2, #4						; increment allocation table traverser
free_next				ADDS R1, R1, #8						; increment DATA_MEM iterator
						B free_loop							; return to loop condition check
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
						PUSH{LR, R4}					; preserve R4 and LR
						MOVS R1, R0						; move function argument to R1
						PUSH{R1}						; preserve R1
						BL Malloc						; allocate space for new node assign it to R0
						POP{R1}							; get preserved R1
						CMP R0, #0						; check if allocation table is full
						BEQ insert_error_full			; go to here if full
						
						STR R1, [R0]					; write value data to new location (newnode->data = data)
						MOVS R3, #0						; set R3 to 0 (use this register as tail)
						STR R3, [R0, #4]				; newnode->next = null
						LDR R2, =FIRST_ELEMENT			; get FIRST_ELEMENT address to R2
						LDR R2, [R2]					; get FIRST_ELEMENT value which holds to head address
						
						CMP R2, #0						; if(head == NULL)
						BEQ insert_head					; go to here if NULL
						LDR R4, [R2]					; R4 = head->data
						CMP R1, R4						; if (value < head->data)
						BLO insert_head					; if value is smaller than head data go here
						
insert_loop				CMP R2, #0						; if (traverse == NULL)
						BEQ insert_middle				; go to here if NULL
						LDR R4, [R2]					; temp_data = traverse->data
						CMP R1, R4						; if (value < temp_data)
						BLO insert_middle				; if value is smaller go here
						BEQ error_duplicate				; if (value == temp_data) go here
						MOVS R3, R2						; copy traverse->data's address
						LDR R2, [R2, #4]				; R2 = traverse->next
						B insert_loop					; go back to start of the loop
						
insert_head				STR R2, [R0, #4]				; newnode->next = head
						LDR R2, =FIRST_ELEMENT			; get FIRST_ELEMENT address to R2
						STR R0, [R2]					; head = newnode (update FIRST_ELEMENT)
						MOVS R0, #0						; load success message
						POP{R4, PC}						; return success message

insert_middle			STR R0, [R3, #4]				; prev->next = R0 (newnode's address)
						STR R2, [R0, #4]				; newnode->next = traverse
						MOVS R0, #0						; load success message
						POP{R4, PC}						; return success message

insert_error_full		MOVS R0, #1						; load error message (AT is full)
						POP{R4, PC}						; return error message

error_duplicate			BL Free							; deallocate memory since it was not used
						MOVS R0, #2						; load error message (value is duplicate)
						POP{R4, PC}						; return error message
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
						PUSH{LR, R4}					; preserve LR
						MOVS R1, R0						; copy value to R1
						LDR R0, =FIRST_ELEMENT			; get FIRST_ELEMENT's address
						LDR R0, [R0]					; get FIRST_ELEMENT's value which is head address
						CMP R0, #0						; if(head == NULL)
						BEQ remove_error_empty			; if list is empty go here
						
						LDR R3, [R0]					; R3 = head->data
						CMP R3, R1						; if (head->data == value)
						BEQ remove_head					; if value is head's data go here
						
						MOVS R2, #0						; prev = NULL
remove_loop				CMP R0, #0						; if (traverse == NULL)
						BEQ remove_error_notfound		; go here if data is not found
						
						LDR R3, [R0]					; temp_data = traverse->data
						CMP R1, R3						; if (value == temp_data)
						BEQ remove_free_node			; if found remove it
						
						MOVS R2, R0						; prev = traverse
						LDR R0, [R0, #4]				; traverse = traverse->next
						B remove_loop					; go to loop
						
remove_head				LDR R4, =FIRST_ELEMENT			; get FIRST_ELEMENT's address
						LDR R3, [R0, #4]				; get head->next
						STR R3, [R4]					; store new head to FIRST_ELEMENT 
						BL Free							; free old head
						MOVS R0, #0						; get success code
						POP{R4, PC}						; pop preserved LR to PC
						
remove_free_node		LDR R3, [R0, #4]				; R3 = traverse->next
						STR R3, [R2, #4]				; prev->next = R3
						BL Free							; free address
						MOVS R0, #0						; get success code
						POP{R4, PC}						; pop preserved LR to PC
						
remove_error_notfound	MOVS R0, #4						; get error code
						POP{R4, PC}						; return error code
						
remove_error_empty		MOVS R0, #3						; get error code
						POP{R4, PC}						; return error code
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
							LDR R0, =ARRAY_MEM			; get Array's first element's address
							LDR R1, =ARRAY_SIZE			; get size of array
							MOVS R2, #0					; iterator
							MOVS R3, #0					; value to be written
clear_arrmem				CMP R2, R1					; if (iterator == ARRAY_SIZE)
							BEQ write_toarray			; if end is reached go here
							
							STR R3, [R0, R2]			; write 0 to array element
							ADDS R2, R2, #4				; iterator++
							B	clear_arrmem			; go to next loop iteration

write_toarray				LDR R1, =FIRST_ELEMENT		; get FIRST_ELEMENT's address
							LDR R1, [R1]				; get FIRST_ELEMENT's value which points to head
							CMP R1, #0					; if(head == NULL)
							BEQ toarray_exit_empty		; if null go here
							
							MOVS R2, #0					; use as array iterator
toarray_loop				CMP R1, #0					; if(traverse == NULL)
							BEQ toarray_exit_success	; if end is reached go here
							
							LDR R3, [R1]				; R3 = traverse->data
							STR R3, [R0, R2]			; arr[R2] = R3
							ADDS R2, R2, #4				; go to next array element
							LDR R1, [R1, #4]			; get traverse->next
							B toarray_loop
							
toarray_exit_empty			MOVS R0, #5					; get error code
							BX LR						; return error code

toarray_exit_success		MOVS R0, #0					; get success code
							BX LR						; return success code

;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
							; don't forget to push R (LR)
							PUSH{LR, R4-R6}					; preserve registers to stack
							LDR R4, =__LOG_END				; get end of LOG_MEM
							LDR R5, =INDEX_ERROR_LOG		; get INDEX_ERROR_LOG's address
							LDR R6, [R5]					; get INDEX_ERROR_LOG's value which holds an address
							CMP R6, #0						; if INDEX_ERROR_LOG is not set
							BEQ set_error_index				; go here
							CMP R4, R6						; if INDEX_ERROR_LOG == End of the Log array
							BEQ writeLog_return				; if log array is full exit function
							
writeLog_write				LSLS R0, #16					; shift index to left by 16 bits
							LSLS R1, #8						; shift error code to left by 8 bits
							ORRS R0, R0, R1					; OR index and error code
							ORRS R0, R0, R2					; OR R0 and operation
							STR R0, [R6]					; store first word
							STR R3, [R6, #4]				; store second word (data)
							BL GetNow						; get current time
							STR R0, [R6, #8]				; store third word (timestamp)
							ADDS R6, R6, #12				; increment index
							STR R6, [R5]					; store incremented index to INDEX_ERROR_LOG
writeLog_return				POP{R6, R5, R4, PC}				; get preserved registers and return

set_error_index				LDR R6, =LOG_MEM				; get LOG_MEM's start
							STR R6, [R5]					; store LOG_MEM's start to INDEX_ERROR_LOG
							B writeLog_write				; go to writing operation
							
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				LDR R0, =0xE000E010					; Get the address of SYST_CSR
				LDR R1, [R0, #4]					; Get the value of SYST_RVR
				LDR R2, =TICK_COUNT					; Get the address of TICK_COUNT
				LDR R2, [R2]						; Get the value from TICK_COUNT
				MULS R2, R1, R2						; multiply SYST_RVR with TICK_COUNT
				LDR R3, [R0, #8]					; Get the value of SYST_CVR
				SUBS R1, R1, R3						; reload - current value
				MOVS R0, #0							; reset R0
				ADDS R0, R1, R2						; add (reload - current value) to calculated value
				LSRS R0, #2							; divide R0 by 4 because our CPU Clock Frequency is 4 Mhz
				BX LR								; return time passed
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

