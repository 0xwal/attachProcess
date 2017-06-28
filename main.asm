.386

.model flat, stdcall
option casemap : none




include kernel32.inc
include user32.inc
include windows.inc



.data
lpCaption db "Error", 0
lpText db "Error! cannot Connect", 0
lpTextAttachedError db "Error! cannot Attach make sure your are in a game", 0
ps3Lib db "C:\\Program Files (x86)\\SN Systems\\PS3\\bin\ps3tmapi.dll", 0
initTarget db "SNPS3InitTargetComms", 0;
connectTarget db "SNPS3Connect", 0;
attachProc db "SNPS3ProcessAttach", 0
processList db "SNPS3ProcessList", 0
procContinue db  "SNPS3ProcessContinue", 0
processFunc dword 0
hInstance dword 0
puCount dword 0
puBuffer dword 12 dup(0)
puId dword 0


.code
	getFuncAddr proc
		push ebp
		mov ebp, esp
		push [ebp+8]
		push hInstance
		call GetProcAddress
		mov esp, ebp
		pop ebp
		ret
	getFuncAddr endp
WinMainCRTStartu proc
	push ebp
	mov ebp, esp

	call FreeConsole

	push OFFSET ps3Lib
    call LoadLibrary
	cmp eax, 0
	je endFailure

	mov hInstance, eax
	
	push OFFSET initTarget
	call getFuncAddr
	cmp eax, 0
	je endFailure
	call eax
	cmp eax, 0
	jne endFailure

	push OFFSET connectTarget
	call getFuncAddr
	cmp eax, 0
	je endFailure
	push 0
	push 0
	call eax
	cmp eax, 6
	je connAlready
	cmp eax, 0
	jne endFailure

	connAlready:
	push OFFSET processList
	call getFuncAddr
	cmp eax, 0
	je endFailure
	mov processFunc, eax
	push 0
	push OFFSET puCount
	push 0
	call processFunc
	cmp eax, 0
	jne endFailure
	imul eax , puCount, 4
	push OFFSET puBuffer
	push OFFSET puCount
	push 0
	call processFunc
	cmp eax, 0
	jne endFailure

	mov ebx, puBuffer
	mov puId, ebx
	
	push OFFSET attachProc
	call getFuncAddr
	cmp eax, 0
	je endFailure
	push puId
	push 0
	push 0
	call eax ;Attach
	cmp eax, 0
	jne endAttachProc

	push OFFSET procContinue
	call getFuncAddr
	cmp eax, 0
	je endFailure
	push puId
	push 0
	call eax ;Continue
	cmp eax, 0
	jne endFailure

	endSuccess:
	push 37
	push 500
	call Beep
	jmp endfunc
	
	endAttachProc:
	push MB_ICONERROR
	push OFFSET lpCaption
	push OFFSET lpTextAttachedError
	push 0
	call MessageBox
	jmp endfunc
	endFailure:
	push MB_ICONERROR
	push OFFSET lpCaption
	push OFFSET lpText
	push 0
	call MessageBox
	endfunc:
	push 0
	call ExitProcess
	mov esp, ebp
	pop ebp
	ret
    
WinMainCRTStartu endp

end WinMainCRTStartu
