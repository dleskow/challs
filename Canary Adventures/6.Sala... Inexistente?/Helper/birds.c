#include<unistd.h>
#include<stdlib.h>
#include<stdio.h>

void print_menu() {
	printf("\n\n\nEsses são nossos pássaros:\n1. Dragão\n2. Morcego\n3. Arara\n4. Pato\n5. Canário\n6. Sair\n");
}

int get_bird(int bird) {
	switch (bird) {
		case 1:
			printf(
				"      \\                    / \\  //\\\n"
				"       \\    |\\___/|      /   \\\\//  \\\\\n"
				"            /0  0  \\__  /    //  | \\ \\    \n"
				"           /     /  \\/_/    //   |  \\  \\  \n"
				"           @_^_@'/   \\/_   //    |   \\   \\ \n"
				"           //_^_/     \\/_ //     |    \\    \\\n"
				"        ( //) |        \\///      |     \\     \\\n"
				"      ( / /) _|_ /   )  //       |      \\     _\\\n"
				"    ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.\n"
				"  (( / / )) ,-{        _      `-.|.-~-.           .~         `.\n"
				" (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \\\n"
				" (( /// ))      `.   {            }                   /      \\  \\\n"
				"  (( / ))     .----~-\\.        \\-'                 .~         \\  `. \\^-.\n"
				"             ///.----..>        \\             _ -~             `.  ^-`  ^-_\n"
				"               ///-._ _ _ _ _ _ _}^ - - - - ~                     ~-- ,.-~\n"
				"                                                                  /.-~\n"
			      );
			break;
		case 2:
			printf(
				"    =/\\                 /\\=\n"
				"    / \\'._   (\\_/)   _.'/ \\\n"
				"   / .''._'--(o.o)--'_.''. \\\n"
				"  /.' _/ |`'=/ \" \\='`| \\_ `.\\\n"
				" /` .' `\\;-,'\\___/',-;/` '. '\\\n"
				"/.-'       `\\(-V-)/`       `-.\\\n"
				"`            \"   \"            `\n"
				);
			break;
		case 3:
			printf(
				"                           .\n"
				"                          | \\/|\n"
				"  (\\   _                  ) )|/|\n"
				"      (/            _----. /.'.'\n"
				".-._________..      .' @ _\\  .'   \n"
				"'.._______.   '.   /    (_| .')\n"
				"  '._____.  /   '-/      | _.' \n"
				"   '.______ (         ) ) \\\n"
				"     '..____ '._       )  )\n"
				"        .' __.--\\  , ,  // ((\n"
				"        '.'     |  \\/   (_. '(  \n"
				"                '   \\ .' \n"
				"                 \\   (\n"
				"                  \\   '.\n"
				"                   \\ \\ '.)\n"
				"                    '-'-'\n"
				);
			break;
		case 4:
			printf(
				"      _.-.\n"
				" __.-' ,  \\\n"
				"'--'-'._   \\\n"
				"        '.  \\\n"
				"         )-- \\ __.--._\n"
				"        /   .'        '--.\n"
				"       .               _/-._\n"
				"       :       ____._/   _-'\n"
				"        '._          _.'-'\n"
				"           '-._    _.'\n"
				"               \\_|/\n"
				"              __|||\n"
				"              >__/'\n"
				);
			break;
		case 5:
			printf("O canário está desaparecido atualmente; boa sorte o encontrando...\n");
			return 1;
		case 6:
			return 0;
		default:
			printf("Nossa, não consigo achar esse pássaro, acho que ele fugiu... Sinto muito.\n");
			return 1;
	}
	printf("Deseja falar algo para o pássaro?\n");
	char words[256];
	read(0, words, 256);
	words[255] = 0;
	if (bird == 3)
		printf(words);
	return 1;
}

int main() {
	setbuf(stdout, NULL);
	char suggestion[64];
	printf("Bem-vindo de volta ao aviário do ICMC!\nAqui possuímos diversas aves dispostas para exibição.\nUma vez que até mesmo sua tentaiva de senha foi refutada, o canário resolveu desaparecer com sua sala de segurança.\nAgora, não se sabe mais como funciona a segurança do aviário...\nUns dizem que não existe mais e a segurança atual é devido à época do canário,\noutros, que a sala está escondida nas profundezas do aviário; mas ninguém sabe ao certo.\nFato é que o canário desapareceu junto de sua sala, e ninguém o vê há muito tempo.\nBoa sorte em sua busca por ele, mas não sei se vai encontrá-lo aqui perto do aviário...\n");
	int bird;
	do {
		print_menu();
		scanf("%16d", &bird);
	} while (get_bird(bird));
	printf("Espero que tenha gostado daqui.\nDeseja deixar alguma sugestão para nosso aviário?\n");
	read(0, suggestion, 64);
	printf("Humm... boa ideia. Será considerado para as próximas vezes.\nAdeus!\n");
}
