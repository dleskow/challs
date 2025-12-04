#include<unistd.h>
#include<stdlib.h>
#include<stdio.h>

void beautiful_words() {
	printf("Lindas palavras, fiquei até emocionado...\nAí está sua recompensa por isso.\n");
	system("/bin/sh");
}

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
			printf(
				"                     .-.\n"
				"                    /  a\\_\n"
				"                    \\  _.-`\n"
				"                   .'  \\\n"
				"                  //    |\n"
				"                 //   ; |\n"
				"                /{   / /\n"
				"               /;\\.-'.`___\\/\n"
				"              ///-'`\\     |\n"
				"             //'  __/___\n"
				"            /`      `-.\n"
				);
			break;
		case 6:
			return 0;
		default:
			printf("Nossa, não consigo achar esse pássaro, acho que ele fugiu... Sinto muito.\n");
			return 1;
	}
	printf("Deseja falar algo para o pássaro?\n");
	char words[256];
	scanf("%256s", words);
	words[255] = 0;
	if (bird == 3)
		printf(words);
	return 1;
}

int main() {
	setbuf(stdout, NULL);
	char suggestion[72];
	printf("Bem-vindo ao aviário do ICMC!\nAqui possuímos diversas aves dispostas para exibição. Sinta-se à vontade para conhecê-las\n");
		int bird;
	do {
		print_menu();
		scanf("%16d", &bird);
	} while (get_bird(bird));
	printf("Espero que tenha gostado daqui.\nDeseja deixar alguma sugestão para nosso aviário?\n");
	read(0, suggestion, 256);
	printf("Humm... boa ideia. Será considerado para as próximas vezes.\nAdeus!\n");
}
