#include<stdlib.h>
#include<unistd.h>
#include<stdio.h>

void calculate_flag() {
	system("/bin/sh");
}

int read_number() {
	char input[11];
	read(0, input, 11);
	input[11] = 0;
	return atoi(input);
}

void operate (int op, int* storage) {
	int x[2], result;
	int choice, i, read = 0;
insert:
	while (read < 2) {
		if (read == 1)
			printf("x = %d\n", x[0]);
		printf("1. Pegar número do armazenamento\n2. Inserir número\n> ");
		choice =  read_number();
		if (choice == 1) {
			printf("Insira qual posição você quer usar? Lembrando que temos 32 slots, acessados de 0-31\n> ");
			i = read_number();
			if (i >= 32) {
				printf("Só temos 32 slots, insira novamente\n");
				goto insert;
			}
			x[read] = storage[i];
		} else if (choice == 2) {
			printf("Insira seu número\n> ");
			x[read] = read_number();
			if ((x[read] > 10 && x[read] <= 0) || (x[read] >= 0 && x[read] < 10)) {
				printf("Você realmente pegou uma calculadora para colocar um número que não tem nem 2 dígitos!?\nInsira outro número ou faça de cabeça.\n");
				goto insert;
			}
		} else {
			printf("Opção não reconhecida, insira novamente\n");
			goto insert;
		}
		read++;
	}
	
	printf("x = %d\ny = %d\nx", x[0], x[1]);
	switch(op) {
	case 1:
		result = x[0] + x[1];
		printf(" + ");
		break;
	case 2:
		result = x[0] - x[1];
		printf(" - ");
		break;
	case 3:
		result = x[0] * x[1];
		printf(" * ");
		break;
	default:
		if (x[1] == 0) {
			printf(" / y = inf\nLol\n");
			return;
		}
		result = x[0] / x[1];
		printf(" / ");
		break;
	}
	printf("y = %d\n", result);
choice:
	printf("Deseja guardar o resultado em algum slot?\n1. Sim\n2. Não\n> ");
	choice = read_number();
	if (choice == 2)
		return;
	if (choice == 1) {
store:
		printf("Insira em qual posição você quer guardar? Lembrando que temos 32 slots, acessados de 0-31\n> ");
		i = read_number();
		if (i >= 32) {
			printf("Só temos 32 slots, insira novamente\n");
			goto store;
		}
		storage[i] = result;
		return;
	}
	printf("Opção não reconhecida, insira novamente\n");
	goto choice;
}

void insert_storage(int* storage) {
	int x;
	int choice, i;
insert:
	printf("Insira a posição em que você quer inserir. Lembrando que temos 32 slots, acessados de 0-31\n> ");
	i = read_number();
	if (i >= 32) {
		printf("Só temos 32 slots, insira novamente\n");
		goto insert;
	}
	printf("Insira seu número\n> ");
	x = read_number();
	if ((x > 10 && x <= 0) || (x >= 0 && x < 10)) {
		printf("Você realmente pegou uma calculadora para colocar um número que não tem nem 2 dígitos!?\nInsira outro número ou faça de cabeça.\n");
		goto insert;
	}
	storage[i] = x;
choice:
	printf("1. Guardar outro número\n2. Menu de operações\n> ");
	choice = read_number();
	if (choice == 1)
		goto insert;
	if (choice == 2)
		return;
	printf("Opção não reconhecida, insira novamente\n");
	goto choice;
}

int main() {
	setbuf(stdout, NULL);
	int storage[32];
	for (int i = 0; i < 32; i++)
		storage[i] = 0;
	int op;
	printf("Bem-vindo à \e[1mCalculadora\e[0m\nPensada para ser uma calculadora rápida e de fácil acesso para contas grandes demais para fazer de cabeça\nTemos um armazenamento interno de 32 números, caso queira usar.\n\n\e[1mDisclaimer:\e[0m\nSó trabalhamos com inteiros que cabem em \e[1mint\e[0m.\n\n");
	while (1) {
		printf("Escolha uma operação:\n0. Sair\n1. Soma\n2. Subtração\n3. Multiplicação\n4. Divisão\n5. Guardar números\n> ");
		op = read_number();
		if (op <= 0)
			break;
		if (op < 5)
			operate(op, storage);
		else if (op == 5)
			insert_storage(storage);
		else {
			printf("Opção indisponível, sinto muito\n\n");
			continue;
		}
	}
}
