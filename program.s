;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date
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
				ADDS R0, #1
				BX LR
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------
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
				LDR R2, =0xFFFFFFFE					; intermediate value
				ANDS R1, R1, R2						; clear the least significant 3 bits of SYST_CSR
				STR R1, [R0]						; Store back the value to SYST_CSR
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
						MOVS R0, #0					; use as iterator, set it to 0
						LDR R1, =AT_SIZE			; get AT_SIZE value
						LDR R2, =AT_MEM				; get address of AT_MEM
						CMP R0, R1					; compare R1 and R2
						BEQ return_malloc_error		; return error

						LDR R3, [R2, R0]			; load next element's allocation value
malloc_compare			CMP R3, #0					; check if node is empty
						BEQ return_malloc_address	; if it is return its address
						ADDS R0, R0, #4				; iterator++
						B	malloc_compare			; check next location

return_malloc_address	MOVS R3, #1					; value to be written
						STR R3, [R2, R0]			; write 1 to newly allocated space at allocation table
						LSLS R0, #1					; multiply by 2
						LDR R3, =DATA_MEM			; get the first element's address
						ADDS R0, R0, R3				; add that to offset (R0)
						BX LR						; return R0

return_malloc_error		MOVS R0, #0					; return R0 as 0
						BX LR						; return 0
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
						LDR R1, =DATA_MEM					; get address of DATA_MEM
						MOVS R2, #0							; use R2 as allocation table traverser, set it to 0
free_loop				CMP R1, R0							; check addresses
						BNE free_next_check					; go to next address

						; if equal, address is found
						LSLS R2, #2							; multiply by 4
						MOVS R1, #0							; value to be stored
						LDR R3, =AT_MEM						; get address of AT_MEM
						STR R1, [R3, R2]					; allocation table write 0
						BX LR								; return after freeing address

free_next_check			ADDS R2, R2, #1						; increment allocation table traverser
						ADDS R1, R1, #8						; increment DATA_MEM iterator
						B free_loop							; return to loop condition check
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															

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
				
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				
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

