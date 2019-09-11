;Assemble this patch file with Flat Assembler (FASM), available at http://flatassembler.net/

use32

format binary as 'exe'

include 'patchmacros.inc'

;*** The EXE Header***
;In this part of the patch, you write down the original EXE header (use "objdump -h file.exe"), and copy down the sections list.
;objdump comes with GCC

; Black Bunny (for reference)
;Idx Name          Size      VMA       LMA       File off  Algn
;  0 .text         0006dd71  00401000  00401000  00000400  2**2
;  1 .rdata        00013b76  0046f000  0046f000  0006e200  2**2
;  2 .data         00007400  00483000  00483000  00081e00  2**2
;  3 .rsrc         000325a8  0048c000  0048c000  00089200  2**2
;Look at output of "objdump -x file.exe", and write down some values:

;Wizard Climber
; 0 .text         0004f63e  00401000  00401000  00001000  2**2
; 1 .rdata        0000bc4c  00451000  00451000  00051000  2**2
; 2 .data         00003000  0045d000  0045d000  0005d000  2**2
; 3 .rsrc         0000043c  00461000  00461000  00060000  2**2

IMAGE_BASE = 0x00400000		;ImageBase from objdump output

;physical offsets of the sections
text_physical_offset  = 0x00001000
rdata_physical_offset = 0x00051000
data_physical_offset  = 0x0005d000
rsrc_physical_offset  = 0x00060000
patch_physical_offset = rsrc_physical_offset + 0x1000

;physical sizes of the offsets
text_physical_size	= rdata_physical_offset - text_physical_offset
rdata_physical_size	= data_physical_offset - rdata_physical_offset
data_physical_size	= rsrc_physical_offset - data_physical_offset
rsrc_physical_size	= patch_physical_offset - rsrc_physical_offset
;patch_physical_size defined later

;VMAs of the sections
TEXT_VMA	= 0x00401000
RDATA_VMA	= 0x00451000
DATA_VMA	= 0x0045d000
RSRC_VMA	= 0x00461000
PATCH_VMA	= 0x00462000

;RVA = VMA - IMAGE_BASE
TEXT_RVA = TEXT_VMA - IMAGE_BASE
RDATA_RVA = RDATA_VMA - IMAGE_BASE
DATA_RVA = DATA_VMA - IMAGE_BASE
RSRC_RVA = RSRC_VMA - IMAGE_BASE
PATCH_RVA = PATCH_VMA - IMAGE_BASE

;Virtual sizes of the sections
TEXT_VIRTUAL_SIZE	= RDATA_VMA - TEXT_VMA
RDATA_VIRTUAL_SIZE	= DATA_VMA - RDATA_VMA
DATA_VIRTUAL_SIZE	= RSRC_VMA - DATA_VMA
RSRC_VIRTUAL_SIZE	= PATCH_VMA - RSRC_VMA
PATCH_VIRTUAL_SIZE	= (patch_physical_size + 0xFFF) / 0x1000 * 0x1000

;Conversions between memory addresses and EXE file addresses
TEXT_ORG   = TEXT_VMA - text_physical_offset
RDATA_ORG  = RDATA_VMA - rdata_physical_offset
DATA_ORG   = DATA_VMA - data_physical_offset
RSRC_ORG   = RSRC_VMA - rsrc_physical_offset
PATCH_ORG  = PATCH_VMA - patch_physical_offset

;Image size
IMAGE_SIZE = PATCH_VMA + PATCH_VIRTUAL_SIZE - IMAGE_BASE

PE_LOCATION = 0x100   ;Use a hex editor, and look for the text "PE" to see where it is.

; === Patching! ===

patchfile 'ins\\wizard.exe'

patchsection IMAGE_BASE ; === PE header ===

patchat PE_LOCATION + 6 ; Increase number of sections
  dw 5

patchat PE_LOCATION + 50h ; Increase size of image
  dd IMAGE_SIZE

patchat PE_LOCATION + 0xF8 + 0x28 * 4  ;Add .patch section
  dd '.pat','ch'		; Name
  dd PATCH_VIRTUAL_SIZE	; Virtual size
  dd PATCH_RVA			; RVA
  dd patch_physical_size	; Physical size
  dd patch_physical_offset	; Physical offset
  dd 0,0,0			; Unused
  dd 0E00000E0h		; Attributes

; ##################################################

;==========================
;  Patching .text section
;==========================
patchsection TEXT_ORG ; === .text section start ===


; ##################################################

;==========================
;  Patching .data section
;==========================
patchsection DATA_ORG ; === .data section start ===

;nothing to patch in the Data section

;=============
;  Variables
;=============


;Black Bunny
;functions
;FreeLibrary	= 0x0046F478
;GetProcAddress	= 0x0046F480
;LoadLibraryW	= 0x0046F47C
;GetLastError	= 0x0046F4EC
;MessageBoxW	= 0x004886E8 ;not here, need to load it up

;Wizard Climber
;functions
FreeLibrary		= 0x004513C0
GetProcAddress	= 0x004513C4
LoadLibraryW	= 0x004513C8 ; This is actually LoadLibraryA...
GetLastError	= 0x004513FC
;MessageBoxW	= 0x004886E8 ;not here, need to load it up

;declare variables here

;stack variables:  [ESP + xxxx + 4]  ;4 is the stack offset, this increases as you call or push more stuff

;==================
;  Patch section!
;==================

patchsection PATCH_ORG
patchat PATCH_VMA - PATCH_ORG

patch_section_start:

_GetText:
	;before the call, ESP + 0x0C was pointer to text
	push eax
	push ecx
	push edx
	push ebx
	push ebp
	push esi
	push edi
	
	mov eax,[esp + 0x20 + 0x4] ; Get Text
	push eax
	call GetText2
	pop ecx
	test eax,eax
	je _DontStore
	mov [esp + 0x20 + 0x04], eax ; Reset it?
_DontStore:
	
	pop edi
	pop esi
	pop ebp
	pop ebx
	pop edx
	pop ecx
	pop eax

	MOV ecx,[esp + 8]
	xor eax,eax
	cmp [ecx],al

	;MOV [EBP-4],DWORD 0 ; This was removed from the AGS DLL stuff....
	;MOV EAX,[EBP+8]
	;MOVZX ECX,WORD [EAX]
	;TEST ECX,ECX
	
	ret

GetText2:
	;ESP + 4 = char* text
	mov eax,[getTextAddress]
	test eax,eax
	je LoadModule
	mov ecx,[esp + 4]
	push ecx
	call eax
	pop ecx
	ret
	
LoadModule:
	mov eax,[hasInit]
	test eax,eax
	jne AlreadyTried
	
	mov eax,1
	mov [hasInit],eax
	
	push _user32DllName
	call dword [LoadLibraryW]
	mov [_user32ModuleAddress],eax
	test eax,eax
	je Failed0
	push dword _messageBoxWFunctionName
	push dword [_user32ModuleAddress]
	call dword [GetProcAddress]
	mov [_MessageBoxW], eax
	test eax,eax
	je Failed0
Failed0:

	push getTextDllName
	call dword [LoadLibraryW]
	mov [moduleAddress],eax
	test eax,eax
	je Failed1
	
	push cleanupFunctionName
	push dword [moduleAddress]
	call dword [GetProcAddress]
	mov [cleanupAddress],eax
	test eax,eax
	je Failed2
	
	push getTextFunctionName
	push dword [moduleAddress]
	call dword [GetProcAddress]
	mov [getTextAddress],eax
	test eax,eax
	je Failed2
	
	jmp GetText2
Failed1:
	call dword [GetLastError]
	mov edi,loadLibraryFailedText2
	call OutputHexW
	
	mov eax,[_MessageBoxW]
	test eax,eax
	je Failed
	
	push 0x10
	push 0
	push loadLibraryFailedText
	push 0
	call eax
	jmp Failed
Failed2:
	call dword [GetLastError]
	mov edi,getProcAddressFailedText2
	call OutputHexW
	
	mov eax,[_MessageBoxW]
	test eax,eax
	je Failed
	
	push 0x10
	push 0
	push getProcAddressFailedText
	push 0
	call eax
	jmp Failed

AlreadyTried:
Failed:
	mov eax,0
	ret

OutputHexW:
	;EDI = destination, EAX = value
	mov bl,8
	add edi,0x0E
OutputHexWLoop:
	mov cl,al
	and cl,0x0F
	add cl,'0'
	cmp cl,':'
	jl OutputHexWSkip
	add cl,7
OutputHexWSkip:
	mov [edi],cl
	shrd eax, eax, 4
	dec edi
	dec edi
	dec bl
	jne OutputHexWLoop
	ret
	
CleanupAtExit:
	push eax
	push ecx
	push edx
	push ebx
	push ebp
	push esi
	push edi
	call Cleanup
	pop edi
	pop esi
	pop ebp
	pop ebx
	pop edx
	pop ecx
	pop eax
	
	MOV DWORD [EBP-0x1C],EAX
	CMP DWORD [EBP-0x20],0
	ret
	
Cleanup:
	mov eax,[cleanupAddress]
	test eax,eax
	je DontCallCleanup
	call eax

DontCallCleanup:
	mov eax,[moduleAddress]
	test eax,eax
	je DontUnloadModule
	push eax
	call dword [FreeLibrary]
	
DontUnloadModule:
	ret

hasInit:
	dd 0
moduleAddress:
	dd 0
getTextAddress:
	dd 0
cleanupAddress:
	dd 0
getTextDllName:
	db "replacetext.dll",0
getTextFunctionName:
	db "GetText",0
cleanupFunctionName:
	db "Cleanup",0
_user32DllName:
	db "user32.dll",0
_user32ModuleAddress:
	dd 0
_messageBoxWFunctionName:
	db "MessageBoxW",0
_MessageBoxW:
	dd 0

;helloWorldText:
;	du "Hello World "
;helloWorldText2:
;	du 0,0,0,0,0,0,0,0,0
loadLibraryFailedText:
	du "An error occurred while loading replacetext.dll:", 0x0D, 0x0A
loadLibraryFailedText2:
	du 0,0,0,0,0,0,0,0,0
getProcAddressFailedText:
	du "An error occurred while trying to find a function inside of replacetext.dll:", 0x0D, 0x0A
getProcAddressFailedText2:
	du 0,0,0,0,0,0,0,0,0

	
patch_section_end:
patch_physical_size = patch_section_end - patch_section_start

patchend

; vim: ft=fasm
