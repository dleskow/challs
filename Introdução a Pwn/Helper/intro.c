#include<stdio.h>
#include<stdlib.h>

void random_useless_function_lol () {
	return;
}

int main() {
	setbuf(stdout, NULL);
	printf(
		"Olá!\n"
		"Esse chall busca ser nada além de uma introdução às ferramentas à sua disposição para serem usadas em pwn\n"
		"Se você não tem o código-fonte do programa e nem a paciência para ler Assebmly, existem decompiladores que tentam reverter do Assembly para C\n"
		"\tSugestão: IDA Free / Ghidra\n"
		"Para uma análise de toda a memória do programa durante sua execução, sugere-se o GBD, mais especificamente, sua extensão voltada para pwning, pwndbg (procure no github)\n"
		"E, por fim, caso você não saiba escrever algo além de ASCII com seu teclado, existe a biblioteca pwntools para Python, que permite sua interação com o programa e o envio de bytes não ASCII\n"
		"O como usar cada um fica a cargo do leitor\n"
		"E um spoiler dos challs de pwn: muitos envolvem chamar uma shell. Boa sorte!\n\n"
		"Insira a resposta para merecer a flag: \n"
		);
	long long unsigned int function = (long long unsigned int)(void*)random_useless_function_lol;
	long long unsigned int main = function + 7;
	char addrs[16];
	for (int i = 0; i < 8; i++, function /= 256)
		addrs[i] = (char)function % 256;
	for (int i = 8; i < 16; i++, main /= 256)
		addrs[i] = (char)main % 256;

	char input[16];
	fgets(input, 16, stdin);
	for (int i = 0; i < 16; i++)
		if (addrs[i] != input[i])
			return 0;
	printf("\nWell done!\nI'm too lazy to compile twice with different flags, so here is a shell for you!\n");
	system("/bin/sh");
}
