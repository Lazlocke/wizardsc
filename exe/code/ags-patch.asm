;Assemble this patch file with Flat Assembler (FASM), available at http://flatassembler.net/

use32

format binary as 'dll'

include 'patchmacros.inc'

;*** The EXE Header***
;In this part of the patch, you write down the original EXE header (use "objdump -h file.exe"), and copy down the sections list.
;objdump comes with GCC

;Look at output of "objdump -x file.exe", and write down some values:
;Bunny
;Idx Name          Size      VMA       LMA       File off
;  0 .text         0003d483  10001000  10001000  00000400
;  1 .rdata        0000be0c  1003f000  1003f000  0003da00
;  2 .data         00001400  1004b000  1004b000  00049a00
;  3 .rsrc         00002da0  1004e000  1004e000  0004ae00
;  4 .reloc        00003908  10051000  10051000  0004dc00

;Wizard
;Idx Name          Size      VMA       LMA       File off  Algn
;  0 .text         00028d7e  10001000  10001000  00001000  2**2
;  1 .rdata        0000719d  1002a000  1002a000  0002a000  2**2
;  2 .data         00002000  10032000  10032000  00032000  2**2
;  3 .rsrc         00002cd0  10036000  10036000  00034000  2**2
;  4 .reloc        00002eec  10039000  10039000  00037000  2**2

IMAGE_BASE = 0x10000000		;ImageBase from objdump output

;physical offsets of the sections
text_physical_offset  = 0x00001000
rdata_physical_offset = 0x0002a000
data_physical_offset  = 0x00032000
rsrc_physical_offset  = 0x00034000
reloc_physical_offset = 0x00037000
;patch_physical_offset = reloc_physical_offset + 0x4000

;physical sizes of the offsets
text_physical_size	= rdata_physical_offset - text_physical_offset
rdata_physical_size	= data_physical_offset - rdata_physical_offset
data_physical_size	= rsrc_physical_offset - data_physical_offset
rsrc_physical_size	= reloc_physical_offset - rsrc_physical_offset
;reloc_pysical_size = patch_physical_offset - reloc_physical_offset
;patch_physical_size defined later

;VMAs of the sections
TEXT_VMA	= 0x10001000
RDATA_VMA	= 0x1002a000
DATA_VMA	= 0x10032000
RSRC_VMA	= 0x10036000
RELOC_VMA   = 0x10039000
;PATCH_VMA	= 0x10055000

;RVA = VMA - IMAGE_BASE
TEXT_RVA = TEXT_VMA - IMAGE_BASE
RDATA_RVA = RDATA_VMA - IMAGE_BASE
DATA_RVA = DATA_VMA - IMAGE_BASE
RSRC_RVA = RSRC_VMA - IMAGE_BASE
RELOC_RVA = RELOC_VMA - IMAGE_BASE
;PATCH_RVA = PATCH_VMA - IMAGE_BASE

;Virtual sizes of the sections
TEXT_VIRTUAL_SIZE	= RDATA_VMA - TEXT_VMA
RDATA_VIRTUAL_SIZE	= DATA_VMA - RDATA_VMA
DATA_VIRTUAL_SIZE	= RSRC_VMA - DATA_VMA
RSRC_VIRTUAL_SIZE	= RELOC_VMA - RSRC_VMA
;RELOC_VIRTUAL_SIZE  = PATCH_VMA - RELOC_VMA
;PATCH_VIRTUAL_SIZE	= (patch_physical_size + 0xFFF) / 0x1000 * 0x1000

;Conversions between memory addresses and EXE file addresses
TEXT_ORG   = TEXT_VMA - text_physical_offset
RDATA_ORG  = RDATA_VMA - rdata_physical_offset
DATA_ORG   = DATA_VMA - data_physical_offset
;PATCH_ORG  = PATCH_VMA - patch_physical_offset

;Image size
;IMAGE_SIZE = PATCH_VMA + PATCH_VIRTUAL_SIZE - IMAGE_BASE

PE_LOCATION = 0108h   ;Use a hex editor, and look for the text "PE" to see where it is.

; === Patching! ===

patchfile 'ins\\Ags.dll'

patchsection IMAGE_BASE ; === PE header ===

;patchat PE_LOCATION + 6 ; Increase number of sections
;  dw 5
;
;patchat PE_LOCATION + 50h ; Increase size of image
;  dd IMAGE_SIZE
;
;patchat PE_LOCATION + 0xF8 + 0x28 * 4  ;Add .patch section
;  dd '.pat','ch'		; Name
;  dd PATCH_VIRTUAL_SIZE	; Virtual size
;  dd PATCH_RVA			; RVA
;  dd patch_physical_size	; Physical size
;  dd patch_physical_offset	; Physical offset
;  dd 0,0,0			; Unused
;  dd 0E00000E0h		; Attributes

; ##################################################

;==========================
;  Patching .text section
;==========================
patchsection TEXT_ORG ; === .text section start ===

;patch for _AgsSpriteCreateText
;original code:

;replace this block with a call to 0x0x00462000
;00A213D0      8B4C24 04     MOV ECX,DWORD PTR SS:[ESP+4]
;00A213D4      33C0          XOR EAX,EAX
;00A213D6      3801          CMP BYTE PTR DS:[ECX],AL
;00A213D8      56            PUSH ESI



;patch it so it instead calls some code that we'll add to bunny2.exe, so we don't need to add any sections to a DLL file and worry about relocations

;Black Bunny
;patchat (0x100247C4 - TEXT_ORG)
;Wizard
patchat (0x100113D0 - TEXT_ORG)
mov ecx, 0x00462000
call ecx
patchtill (0x100113D8 - TEXT_ORG)


;Stop it from converting halfwidth to fullwidth characters, and displaying fullwidth spacing around halfwidth characters.
;This skips _AoiString1to2Byte call
patchat (0x10018175 - TEXT_ORG)
JMP SHORT 0x10018186
patchtill (0x10018177 - TEXT_ORG)


; ##################################################

;==========================
;  Patching .rdata section
;==========================
patchsection RDATA_ORG ; === .rdata section start ===

;need to redo these
;patchat (0x1002BFBC - RDATA_ORG)
;db "Restart the game",0,0,0,0
;db "Restart the game to accept changes?",0x0D,0x0A
;db "Otherwise, settings will change back.",0,0,0,0,0,0
;db "Exit the game",0,0,0
;db "Do you want to quit?",0,0,0,0
;db "Do you want to restart?",0,0,0,0,0
;patchtill (0x1002C064 - RDATA_ORG)

;patchat (0x1002C080 - RDATA_ORG)
;db "SystemAoi System Settings (F10)",0
;db "SystemAoi System Restart  (F9)",0,0,0,0,0,0
;db "[%s] Failed to read file.",0,0,0
;patchtill (0x1002C0E0 - RDATA_ORG)

;==========================
;  Patching .data section
;==========================
patchsection DATA_ORG ; === .data section start ===

;nothing to patch in the Data section

;=============
;  Variables
;=============

;declare variables here

;stack variables:  [ESP + xxxx + 4]  ;4 is the stack offset, this increases as you call or push more stuff

;==================
;  Patch section!
;==================

;patchsection PATCH_ORG
;patchat PATCH_VMA - PATCH_ORG
;
;patch_section_start:
;
;patch_section_end:
;patch_physical_size = patch_section_end - patch_section_start

patchend

; vim: ft=fasm
