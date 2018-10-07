.data
POCZATEK_LICZB = 0x30
POCZATEK_LICZBINC = 0x31
PODSTAWA_DEC = 10
SPRAWDZENIE_JEDEN = 1

DWA = 2
.bss
.comm bufor, 64
.comm bufor_out, 20
.comm kolejne_pierwsze, 40
.comm potega_dwa,4
.comm wartosc_d, 4
.comm nasza_liczba, 4
.comm dokladnosc, 4
.comm sprawdzanie, 4


.align 32
.text

komunikat1: .ascii "Podaj liczbe nieparzysta\n"		
komunikat1_len = . - komunikat1	
komunikat2: .ascii "Podaj liczbe k(dokladnosc testu)\n"		
komunikat2_len = . - komunikat2	
		

.global _start			

_start:
  	
mov $4, %eax			 # pierwszy komunikat
mov $1, %ebx			
mov $komunikat1, %ecx		
mov $komunikat1_len, %edx		
int $0x80 	

mov $3, %eax			 # pobor liczby od uzytkow
mov $0, %ebx			
mov $bufor, %ecx		
mov $64, %edx		
int $0x80 				

mov %eax, %esi	

mov $0,%edi
mov $0,%ecx

dec %esi
	
			
start_loop:				# petla przepisywania liczby z buffora do rejestru

cmp %edi,%esi
jle end_loop

mov %ecx, %eax
mov $PODSTAWA_DEC, %ecx
mul %ecx
mov %eax, %ecx

mov $0, %eax
mov bufor(,%edi,1), %al
sub $0x30, %al
add %eax, %ecx

inc %edi
jmp start_loop

end_loop:

mov $0, %edi
mov %ecx, nasza_liczba(,%edi,1)

mov %ecx, %esi   # przepisanie liczby do innego rejestru
sub $1, %esi  # zrobienie z liczby n-1
mov $1, %edi   # sprawdzana potęga dwojki
mov $1, %ebx  #najwieksza potega dwojki
mov $DWA, %ecx

# mov $64, %esi   ## sprawdzeni

petla_rozkladu:
cmp %ecx, %esi
jl rozklad_end 
mov $0, %edx
mov %esi, %eax
div %ecx
cmp $0, %edx
jne nie_dzieli
mov %edi, %ebx

nie_dzieli:
inc %edi
mov $DWA, %eax
mul %ecx
mov %eax, %ecx

jmp petla_rozkladu

rozklad_end:

# w %ebx jest s
mov $0, %edi
mov %ebx, potega_dwa

mov $0, %edi
xor %eax, %eax
movb $2, %al
mov %al, kolejne_pierwsze(,%edi,4)
wpisywanie:
xor %eax, %eax
inc %edi
movb $3, %al
mov %al, kolejne_pierwsze(,%edi,4)
xor %eax, %eax
inc %edi
movb $5, %al
mov %al, kolejne_pierwsze(,%edi,4)
xor %eax, %eax
inc %edi
movb $7, %al
mov %al, kolejne_pierwsze(,%edi,4)
xor %eax, %eax
inc %edi
movb $11, %al
mov %al, kolejne_pierwsze(,%edi,4)
xor %eax, %eax
inc %edi
movb $13, %al
mov %al, kolejne_pierwsze(,%edi,4)
wpisane:
xor %eax, %eax
inc %edi
movb $17, %al
mov %al, kolejne_pierwsze(,%edi,4)



mov $0, %edi				# sprawdzenie jaka potega dwojki max



add $POCZATEK_LICZB, %ebx
mov %ebx, bufor_out(, %edi,1)

mov $4, %eax
mov $1, %ebx
mov $bufor_out, %ecx
mov $20, %edx
int $0x80



 # w esi nasze n-1
#obliczenie D
mov $0, %edi
mov bufor_out(, %edi,1), %ebx
sub $POCZATEK_LICZB, %ebx   		# w ebx nasza potega dwojki
mov $1, %eax

mov $1, %edi

petla_d:
mov $2, %ecx
mul %ecx
inc %edi
cmp %ebx,%edi
jle petla_d

petla_dkoniec:

mov $0, %edx
mov %eax, %ebx
mov %esi, %eax
div %ebx

mov %eax, wartosc_d

# w esi mamy n-1


mov $4, %eax			 # pierwszy komunikat
mov $1, %ebx			
mov $komunikat2, %ecx		
mov $komunikat2_len, %edx		
int $0x80 	

mov $3, %eax			 # pobor liczby od uzytkow
mov $0, %ebx			
mov $dokladnosc, %ecx		
mov $1, %edx		
int $0x80 

mov (dokladnosc), %ecx
przerwa12:
sub $POCZATEK_LICZB, %ecx
mov %ecx, dokladnosc
	
mov $0, %edi  # licznik dokładnosci

mov %edi, sprawdzanie
add $1, %esi    # w esi jest n
petla_dokladnosci:

mov kolejne_pierwsze(, %edi,4), %ebx

mov $1, %eax
mov (wartosc_d), %ecx				# ecx i esi w tej petli zajete

potegowanie:

mul %ebx
div %esi
mov %edx, %eax
loop potegowanie
test123:
mov %eax, %ebx # przepisanie a do D do ebx


mov $0, %edx
div %esi

cmp $SPRAWDZENIE_JEDEN, %edx
jne sprawdzanie_dalej
mov $1, %edx
mov %edx, sprawdzanie

sprawdzanie_dalej:
mov %esi, %ecx
sub $1, %ecx

cmp %ecx,%edx
jne sprawdzenie_przedmod
mov $1, %edx
mov %edx, sprawdzanie

sprawdzenie_przedmod:

mov $1, %ecx

sprawdzanie_mod:

mov %ebx, %eax
mul %ebx
mov %eax, %ebx
mov $0, %edx
div %esi
mov %edx, %ebx
mov %esi, %eax
sub $1, %eax

cmp %eax, %edx
jne pierwsza
mov $1, %edx
mov %edx, sprawdzanie

pierwsza:

inc %ecx

cmp (potega_dwa), %ecx
jl sprawdzanie_mod
check:
inc %edi					
cmp (dokladnosc), %edi				# edi, esi ebx zajeete do konca
jl petla_dokladnosci
punkt333:
mov (sprawdzanie), %ecx

add $POCZATEK_LICZB, %ecx
mov %ecx, sprawdzanie

stop3:
mov $4, %eax			 # pierwszy komunikat
mov $1, %ebx			
mov $sprawdzanie, %ecx		
mov $4, %edx		
int $0x80 

mov $1, %eax			# funkcja do wywolania - SYSEXIT
mov $0, %ebx			# kod wyjscia z programu
int $0x80			# przerywanie programowe




