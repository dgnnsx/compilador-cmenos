/****************************************************/
/* Arquivo: target.h                                */
/* Gerador de código objeto                         */
/* Diego Wendel de Oliveira Ferreira		        */
/****************************************************/

#ifndef _TARGET_H_
#define _TARGET_H_

#include "cgen.h"

typedef enum opcode {
    _ADDI, _SUBI, _MULI, _DIVI, _MODI,
    _ANDI, _ORI, _XORI, _NOT, _LANDI, _LORI,
    _SLLI, _SRLI,
    _MOV, _LW, _LI, _LA, _SW,
    _IN, _OUT,
    _JF,
    _J, _JAL, _HALT,
    _BGN_PGRM, _END_PGRM,
    _RTYPE
} Opcode;

typedef enum function {
    _ADD, _SUB, _MUL, _DIV, _MOD,
    _AND, _OR, _XOR, _LAND, _LOR,
    _SLL, _SRL,
    _EQ, _NE, _LT, _LET, _GT, _GET,
    _JR,
    _DONT_CARE
} Function;

typedef enum type {
    TYPE_R, TYPE_I, TYPE_J
} Type;

typedef enum registerName {
    $rz, $v0, $v1, $out, $inv, $gp, $a0, $a1,
    $a2, $a3, $s0, $s1, $s2, $s3, $s4, $s5,
    $s6, $s7, $s8, $s9, $t0, $t1, $t2, $t3,
    $t4, $t5, $t6, $t7, $t8, $t9, $sp, $ra
} RegisterName;

typedef enum addressingType {
    IMEDIATO, REGISTRADOR, INDEXADO, LABEL
} AddressingType;

typedef struct targetOperand {
    union {
        int imediato;
        RegisterName registrador;
        struct {
            RegisterName registrador;
            int offset;
        } indexado;
        char * label;
    } enderecamento;
    AddressingType tipoEnderecamento;
} * TargetOperand;

typedef struct escopo {
    int argRegCount;
    int savedRegCount;
    int tempRegCount;
    int quantidadeParametros;
    int quantidadeVariaveis;
    int tamanhoBlocoMemoria;
    const char * nome;
    int registradoresEmUso[10];
    struct escopo * next;
} * Escopo;

typedef struct registrador {
    Operand op;
    RegisterName regName;
    TargetOperand targetOp;
    int isAddress;
} Registrador;

typedef struct objeto {
    Opcode opcode;
    Function func;
    Type type;
    TargetOperand op1;
    TargetOperand op2;
    TargetOperand op3;
    struct objeto * next;
} * Objeto;

typedef struct label {
    char * nome;
    int linha;
    struct label * next;
} * Label;

void geraCodigoObjeto(Quadruple q);

void printCode(Objeto instrucao);

Escopo createEscopo(const char * nome);

void pushEscopo(Escopo e);

TargetOperand getTargetOpByName(char * name);

TargetOperand getAndUpdateTargetOperand(Registrador reg, Operand op);

void removeOperand(TargetOperand opTarget);

void removeAllSavedOperands(void);

void saveRegistradores(int stackLocationRegAux);

void recuperaRegistradores(int stackLocationRegAux);

Objeto createObjInstTypeR(Opcode opcode, Function func, Type type, TargetOperand op1, TargetOperand op2, TargetOperand op3);

Objeto createObjInst(Opcode opcode, Type type, TargetOperand op1, TargetOperand op2, TargetOperand op3);

Objeto insertObjInst(Objeto obj);

TargetOperand getImediato(int val);

TargetOperand getOperandLabel(char * name);

Label createLabel(char * nome, int linha);

void insertLabel(char * nome, int linha);

int getLinhaLabel(char * nome);

void prepararRegistradores(void);

void prepararOperandosEspeciais(void);

Objeto getCodigoObjeto(void);

#endif
