.data
POCZATEK_LICZB = 0x30
POCZATEK_LICZBINC = 0x31
PODSTAWA_DEC = 10
SPRAWDZENIE_JEDEN = 1

DWA = 2
.bss
.comm bufor, 512
.comm bufor_out, 20
.comm kolejne_pierwsze, 40
.comm potega_dwa,4
.comm wartosc_d, 4
.comm nasza_liczba, 4
.comm dokladnosc, 4
.comm sprawdzanie, 4
.comm przechowanie, 32
.comm przechowanie2, 32
.comm przechowaniepoprzednie, 32
.comm przechowaniepoprzednie2, 32
.comm poczatkowa1, 32
.comm poczatkowa2, 32
.comm obejscia1, 4
.comm pomoc123, 4

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
mov $512, %edx		
int $0x80 				

mov %eax, %esi		# rozmiar wciagnietego ciagu w esi

mov $0,%edi
mov $0,%ecx

dec %esi
	
			
start_loop:				# petla przepisywania liczby z buffora do rejestru

cmp $10,%edi
jge end_loop

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

sub $10, %esi   # liczba pozostalych znakow  np 3

mov $0, %edi
mov %ecx, nasza_liczba(,%edi,1)   # pierwsze 32 znaki
mov %esi, %edi   # w edi pozostala liczba znakow
mov %ecx, %esi   # przepisanie liczby do innego rejestru

mov $0, %edx   # reszta z dzielenia
mov $0, %ebx
mov %ebx, potega_dwa

mov %esi, poczatkowa1
petla_rozkladu:
mov $DWA, %ecx
mov $0, %edx
mov %esi, %eax
div %ecx
mov %edi, %ecx

mov $10, %ebx
mov %eax, przechowanie

mov %edx, %eax
mov %edi, %ecx
dopisanie_znakow:
mov $10, %ebx
mul %ebx
mov %eax, %ebx
mov $0, %eax
add $10, %edi
sub %ecx, %edi
mov bufor(,%edi,1), %al
add %ecx, %edi
sub $10, %edi
sub $0x30, %al
add %eax, %ebx
mov %ebx, %eax

loop dopisanie_znakow


przerwa9:
sub $1, %eax
mov %eax, poczatkowa2
mov $2, %ebx
mov $0, %edx
div %ebx
mov %edx, %esi
inc %esi
mov %esi, potega_dwa
mov %eax, przechowanie2


obliczanie_dalej:
mov $0, %eax
mov (przechowanie), %eax
mov %eax, przechowaniepoprzednie
mov $2, %ebx
mov $0, %edx
div %ebx
mov %eax, przechowanie
mov $0, %eax


mov %edx, %eax
mov (przechowanie2), %ebx
mov %ebx, przechowaniepoprzednie2
cmp $0, %edx
je bez_skali

skalowanie:
mov $10, %ecx
mul %ecx
cmp %ebx, %eax
jl skalowanie
bez_skali:
add %ebx, %eax
mov $2, %ebx
mov $0, %edx
div %ebx
mov %eax, przechowanie2

cmp $0, %edx
je jest
jmp opuszczam

jest:
inc %esi
mov %esi, potega_dwa

jmp obliczanie_dalej
opuszczam:






rozklad_end:


mov $0, %edi


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



add $POCZATEK_LICZB, %esi
mov %esi, bufor_out(, %edi,1)

mov $4, %eax
mov $1, %ebx
mov $bufor_out, %ecx
mov $20, %edx
int $0x80



 # w poczatkowa1, poczatkowa2 mamy nasza n-1
 # w przechowaniepoprzednie, przechowaniepoprzednie2 mamy d
 # w potega_dwa mamy s



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
mov (poczatkowa2), %esi    # w esi jest n
petla_dokladnosci:

mov $10, %ebx
mov $1, %eax
mov (przechowaniepoprzednie2), %ecx				# ecx i esi w tej petli zajete
obejscia:
mul %ebx
cmp %eax, %ecx
jg obejscia
mov %eax, obejscia1
mov kolejne_pierwsze(, %edi,4), %ebx
mov (przechowaniepoprzednie2), %ecx
mov $1, %eax


potegowanie:

mul %ebx
mov $0, %edx
div %esi
mov %edx, %eax
loop potegowanie

mov (przechowaniepoprzednie), %ecx
dec %ecx
potegowanie2:
mov %ecx, pomoc123
mov $0, %ecx
potegowanie3:
mul %ebx
mov $0, %edx
div %esi
mov %edx, %eax
inc %ecx
cmp (obejscia1), %ecx
jge potegowanie3

mov (pomoc123), %ecx
loop potegowanie2





test123:
mov %eax, %ebx # przepisanie a do D mod n do ebx


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




