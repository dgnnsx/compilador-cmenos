/**
	GERENCIAMENTO DE MEMORIA (Memoria de instruções)

	- Pensando em implementar paginação
	- Gerenciamento de memória com partições de tamanho fixo
		São 32 partições de tamanho 32 cada.
*/

// falta testar
/*void excluirPrograma(int programa) {
	int aux;
	addProgramStart(500, programa);
}

// falta testar
void renomearPrograma(int antigo, int novo) {
	int aux;
	aux = readProgramStart(antigo);
	addProgramStart(0, antigo);
	addProgramStart(aux, novo);
}*/

void carregarPrograma(int inicioDisco, int fimDisco) {
	int QTD_PARTICOES;		// Quantidade total de partições
	int TAM_PARTICAO;		// Tamanho da partição
	int index; 				// Usado para iterar nas posições do disco
	int fimParticao; 		// Endereço de fim da partição em memória
	int i;					// Iterador de partições
	int j;					// Iterador de endereços dentro de uma partição
	int instrucao;			// Instrução lida do disco
	int inicioMemoria;
	
	QTD_PARTICOES = 32;
	TAM_PARTICAO = 32;

	/*i = 4; // Três primeiras partições são reservadas ao SO
	index = inicioDisco; // Recebe o endereço para iterar no disco
	inicioMemoria = TAM_PARTICAO * 4;
	//while (i < QTD_PARTICOES) {
		//if (index <= fimDisco) {
			j = TAM_PARTICAO * i;
			//if (particoes[i] == 0) { // Partição livre
				//fimParticao = TAM_PARTICAO * 5;
				
				//while (j < fimParticao) {
				while (index <= 130) {
					instrucao = ldk(index);
					sim(instrucao, j);
					output(index, 2);
					index += 1;
					j += 1;
					output(j, 2);
				}
			//}
		//}
		//i += 1;
	//}*/


	index = inicioDisco;
	i = index;
	addProgramStart(i, 0);
	while (index <= fimDisco) {
		instrucao = ldk(index);
		sim(instrucao, i);
		index += 1;
		i += 1;
	}
}

void main(void) {
	int particoes[32];
	// Variavel que representa o programa em execução
	int programa;

	int MAIOR_ELEMENTO_INICIO;
	int MAIOR_ELEMENTO_FIM;

	MAIOR_ELEMENTO_INICIO = 400;
	MAIOR_ELEMENTO_FIM = 475;

	// Adiciona endereços dos programas
	carregarPrograma(MAIOR_ELEMENTO_INICIO, MAIOR_ELEMENTO_FIM);

	// Seleciona um programa para executar
	programa = readProgramStart(0);
	exec(programa);
}

/**
 * addProgramStart(start, address);
 * - start [endereço de início do programa na memória de instruções]
 * - address [endereço na memória de dados]
 */

/**
 * exec(program)
 *
 * Executa o programa 'program' alocado na memória
 * obs: só funciona com variáveis, pois é um JUMPR
 */
