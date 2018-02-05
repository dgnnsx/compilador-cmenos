/****************************************************/
/* File: cminus.y                                   */
/* Gramática da Linguagem C-                        */
/* Diego Wendel de Oliveira Ferreira                */
/****************************************************/

%{
    #define YYPARSER /* distinguishes Yacc output from other code files */

    #include "globals.h"
    #include "util.h"
    #include "scan.h"
    #include "parse.h"

    #define YYSTYPE TreeNode *
    static char * savedName; /* for use in assignments */
    static int savedLineNo;  /* ditto */
    static TreeNode * savedTree; /* stores syntax tree for later return */
    static int yylex(void);
    static int yyerror(char * message);
    static TreeNode * createInsert();
    static TreeNode * createOutput();
    static TreeNode * createLoadDisk();
    static TreeNode * createStoreDisk();
    static TreeNode * createLoadInstMem();
    static TreeNode * createStoreInstMem();
    static TreeNode * createCheckHardDisk();
    static TreeNode * createCheckInstMem();
    static TreeNode * createCheckDataMem();
    static TreeNode * createExec();
    static TreeNode * createAddProgramStart();
    static TreeNode * createReadProgramStart();
    static TreeNode * createMMULower();
    static TreeNode * createMMUUpper();
%}

%token IF ELSE WHILE RETURN
%token ID NUM
%token MAIOR MAIORIGUAL MENOR MENORIGUAL IGUAL DIFERENTE MAIS MENOS VEZES DIVISAO MODULO
%token SHIFT_LEFT SHIFT_RIGHT AND OR XOR NOT LOGICAL_AND LOGICAL_OR
%token ATRIBUICAO ATRIB_MAIS ATRIB_MENOS ATRIB_VEZES ATRIB_DIVISAO ATRIB_MODULO
%token ATRIB_AND ATRIB_OR ATRIB_XOR ATRIB_SHIFT_LEFT ATRIB_SHIFT_RIGHT
%token LPAREN RPAREN SEMI LBRACKET RBRACKET COMMA LKEY RKEY QUESTION COLON
%token ERROR
%token INT VOID
%nonassoc RPAREN
%nonassoc ELSE

%% /* Gramática C- */

program
    : declarationList
        {
            savedTree = createInsert();
            savedTree->sibling = createOutput();
            savedTree->sibling->sibling = createLoadDisk();
            savedTree->sibling->sibling->sibling = createStoreDisk();
            savedTree->sibling->sibling->sibling->sibling = createLoadInstMem();
            savedTree->sibling->sibling->sibling->sibling->sibling = createStoreInstMem();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling = createCheckHardDisk();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createCheckInstMem();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createCheckDataMem();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createExec();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createAddProgramStart();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createReadProgramStart();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createMMULower();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = createMMUUpper();
            savedTree->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling->sibling = $1;
        }
    ;

declarationList
    : declarationList declaration
        {
            YYSTYPE t = $1;
            if (t != NULL) {
                while (t->sibling != NULL) {
                    t = t->sibling;
                }
                t->sibling = $2;
                $$ = $1;
            } else {
                $$ = $2;
            }
        }
    | declaration { $$ = $1; }
    ;

declaration
    : varDeclaration { $$ = $1; }
    | funDeclaration { $$ = $1; }
    ;

varDeclaration
    : typeSpecifier id SEMI
        {
            $$ = $1;
            $$->child[0] = $2;
            $$->child[0]->type = $$->type;
            $$->child[0]->kind.var.mem = LOCALK;
        }
    | typeSpecifier id LBRACKET num RBRACKET SEMI
        {
            $$ = $1;
            $$->child[0] = $2;
            $$->child[0]->type = $$->type;
            $$->child[0]->kind.var.mem = LOCALK;
            $$->child[0]->kind.var.varKind = VECTORK;
            $$->child[0]->child[0] = $4;
            $$->child[0]->child[0]->type = INTEGER_TYPE;
        }
    ;

typeSpecifier
    : INT
        {
            $$ = newStmtNode(INTEGERK);
            $$->type = INTEGER_TYPE;
            $$->op = INT;
        }
    | VOID
        {
            $$ = newStmtNode(VOIDK);
            $$->type = VOID_TYPE;
            $$->op = VOID;
        }
    ;

funDeclaration
    : typeSpecifier id LPAREN params RPAREN compoundStmt
        {
            $$ = $1;
            $$->child[0] = $2;
            $$->child[0]->type = $$->type;
            $$->child[0]->kind.var.varKind = FUNCTIONK;
            $$->child[0]->kind.var.mem = FUNCTION_MEM;
            $$->child[0]->child[0] = $4;
            $$->child[0]->child[1] = $6;
        }
    ;

params
    : paramList { $$ = $1; }
    | VOID { $$ = NULL; }
    ;

paramList
    : paramList COMMA param
        {
            YYSTYPE t = $1;
            if (t != NULL) {
            	while (t->sibling != NULL) {
            		t = t->sibling;
            	}
            	t->sibling = $3;
            	$$ = $1;
            } else {
            	$$ = $3;
            }
        }
    | param { $$ = $1; }
    ;

param
    : typeSpecifier id
        {
            $$ = $1;
            $$->child[0] = $2;
            $$->child[0]->kind.var.mem = PARAMK;
        }
    | typeSpecifier id LBRACKET RBRACKET
        {
            $$ = $1;
            $$->child[0] = $2;
            $$->child[0]->kind.var.mem = PARAMK;
            $$->child[0]->kind.var.varKind = VECTORK;
        }
    ;

compoundStmt
    : LKEY localDeclarations statementList RKEY
        {
            $$ = newStmtNode(COMPK);
            $$->child[0] = $2;
            $$->child[1] = $3;
            $$->op = COMPK;
        }
    ;

localDeclarations
    : localDeclarations varDeclaration
        {
        	YYSTYPE t = $1;
        	if (t != NULL) {
        		while (t->sibling != NULL) {
        			t = t->sibling;
        		}
        		t->sibling = $2;
        		$$ = $1;
        	} else {
        		$$ = $2;
        	}
        }
    | vazio { $$ = $1; }
    ;

statementList
    : statementList statement
        {
        	YYSTYPE t = $1;
        	if (t != NULL) {
        		while (t->sibling != NULL) {
        			t = t->sibling;
        		}
        		t->sibling = $2;
        		$$ = $1;
        	} else {
        		$$ = $2;
        	}
        }
    | vazio { $$ = $1; }
    ;

statement
    : expressionStmt { $$ = $1; }
    | compoundStmt { $$ = $1; }
    | selectionStmt { $$ = $1; }
    | iterationStmt { $$ = $1; }
    | returnStmt { $$ = $1; }
    ;

expressionStmt
    : expression SEMI { $$ = $1; }
    | SEMI { $$ = NULL; }
    ;

selectionStmt
    : IF LPAREN expression RPAREN statement
        {
            $$ = newStmtNode(IFK);
            $$->child[0] = $3;
            $$->child[1] = $5;
            $$->op = IFK;
        }
    | IF LPAREN expression RPAREN statement ELSE statement
        {
            $$ = newStmtNode(IFK);
            $$->child[0] = $3;
            $$->child[1] = $5;
            $$->child[2] = $7;
            $$->op = IFK;
        }
    ;

iterationStmt
    : WHILE LPAREN expression RPAREN statement
        {
        	$$ = newStmtNode(WHILEK);
        	$$->child[0] = $3;
        	$$->child[1] = $5;
            $$->op = WHILEK;
        }
    ;

returnStmt
    : RETURN SEMI
        {
        	$$ = newStmtNode(RETURNK);
            $$->op = RETURNK;
        }
    | RETURN expression SEMI
        {
        	$$ = newStmtNode(RETURNK);
        	$$->child[0] = $2;
            $$->op = RETURNK;
        }
    ;

expression
    : var assigmentOperator expression
        {
            $$ = $2;
            $$->child[0] = $1;
        	$$->child[1] = $3;
        }
    | conditionalExpression { $$ = $1; }
    ;

assigmentOperator
    : ATRIBUICAO
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIBUICAO;
        }
    | ATRIB_MAIS
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_MAIS;
        }
    | ATRIB_MENOS
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_MENOS;
        }
    | ATRIB_VEZES
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_VEZES;
        }
    | ATRIB_DIVISAO
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_DIVISAO;
        }
    | ATRIB_MODULO
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_MODULO;
        }
    | ATRIB_AND
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_AND;
        }
    | ATRIB_OR
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_OR;
        }
    | ATRIB_XOR
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_XOR;
        }
    | ATRIB_SHIFT_LEFT
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_SHIFT_LEFT;
        }
    | ATRIB_SHIFT_RIGHT
        {
        	$$ = newExpNode(ATRIBK);
        	$$->op = ATRIB_SHIFT_RIGHT;
        }
    ;

var
    : id
        {
        	$$ = $1;
            $$->kind.var.acesso = ACCESSK;
        }
    | id LBRACKET expression RBRACKET
        {
        	$$ = $1;
        	$$->kind.var.varKind = VECTORK;
            $$->kind.var.acesso = ACCESSK;
        	$$->child[0] = $3;
        }
    ;

conditionalExpression
    : logicalOrExpression QUESTION expression COLON conditionalExpression
        {
            $$ = newStmtNode(IFK);
            $$->child[0] = $1;
            $$->child[1] = $3;
            $$->child[2] = $5;
            $$->op = IFK;
        }
    | logicalOrExpression { $$ = $1; }
    ;

logicalOrExpression
    : logicalOrExpression LOGICAL_OR logicalAndExpression
        {
            $$ = newExpNode(LOGICK);
            $$->op = LOGICAL_OR;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | logicalAndExpression { $$ = $1; }
    ;

logicalAndExpression
    : logicalAndExpression LOGICAL_AND inclusiveOrExpression
        {
            $$ = newExpNode(LOGICK);
            $$->op = LOGICAL_AND;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | inclusiveOrExpression { $$ = $1; }
    ;

inclusiveOrExpression
    : inclusiveOrExpression OR exclusiveOrExpression
        {
            $$ = newExpNode(LOGICK);
            $$->op = OR;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | exclusiveOrExpression { $$ = $1; }
    ;

exclusiveOrExpression
    : exclusiveOrExpression XOR andExpression
        {
            $$ = newExpNode(LOGICK);
            $$->op = XOR;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | andExpression { $$ = $1; }
    ;

andExpression
    : andExpression AND equalityExpression
        {
            $$ = newExpNode(LOGICK);
            $$->op = AND;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | equalityExpression { $$ = $1; }
    ;

equalityExpression
    : equalityExpression equalityOperator relationalExpression
        {
            $$ = $2;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | relationalExpression { $$ = $1; }
    ;

equalityOperator
    : IGUAL
        {
            $$ = newExpNode(RELK);
            $$->op = IGUAL;
        }
    | DIFERENTE
        {
            $$ = newExpNode(RELK);
            $$->op = DIFERENTE;
        }
    ;

relationalExpression
    : relationalExpression relationalOperator shiftExpression
        {
        	$$ = $2;
        	$$->child[0] = $1;
        	$$->child[1] = $3;
        }
    | shiftExpression { $$ = $1; }
    ;

relationalOperator
    : MENORIGUAL
		{
			$$ = newExpNode(RELK);
			$$->op = MENORIGUAL;
		}
    | MENOR
		{
			$$ = newExpNode(RELK);
			$$->op = MENOR;
		}
    | MAIOR
        {
        	$$ = newExpNode(RELK);
        	$$->op = MAIOR;
        }
    | MAIORIGUAL
        {
        	$$ = newExpNode(RELK);
        	$$->op = MAIORIGUAL;
        }
    ;

shiftExpression
    : shiftExpression shiftOperator additiveExpression
        {
            $$ = $2;
            $$->child[0] = $1;
            $$->child[1] = $3;
        }
    | additiveExpression { $$ = $1; }
    ;

shiftOperator
    : SHIFT_LEFT
        {
            $$ = newExpNode(ARITHK);
            $$->op = SHIFT_LEFT;
        }
    | SHIFT_RIGHT
        {
            $$ = newExpNode(ARITHK);
            $$->op = SHIFT_RIGHT;
        }
    ;

additiveExpression
    : additiveExpression additiveOperator multiplicativeExpression
        {
        	$$ = $2;
        	$$->child[0] = $1;
        	$$->child[1] = $3;
        }
	| multiplicativeExpression { $$ = $1; }
	;

additiveOperator
    : MAIS
        {
        	$$ = newExpNode(ARITHK);
        	$$->op = MAIS;
        }
    | MENOS
        {
        	$$ = newExpNode(ARITHK);
        	$$->op = MENOS;
        }
    ;

multiplicativeExpression
    : multiplicativeExpression multiplicativeOperator unaryExpression
        {
        	$$ = $2;
        	$$->child[0] = $1;
        	$$->child[1] = $3;
        }
    | unaryExpression { $$ = $1; }
    ;

multiplicativeOperator
    : VEZES
        {
        	$$ = newExpNode(ARITHK);
        	$$->op = VEZES;
        }
    | DIVISAO
        {
        	$$ = newExpNode(ARITHK);
        	$$->op = DIVISAO;
        }
    | MODULO
        {
            $$ = newExpNode(ARITHK);
            $$->op = MODULO;
        }
    ;

unaryExpression
    : unaryOperator unaryExpression
        {
            $$ = $1;
            $$->child[0] = $2;
        }
    | LPAREN expression RPAREN { $$ = $2; }
    | var { $$ = $1; }
    | ativacao { $$ = $1; }
    | num { $$ = $1; }
    ;

unaryOperator
    : AND
        {
            $$ = newExpNode(UNARYK);
            $$->op = AND;
        }
    | NOT
        {
            $$ = newExpNode(UNARYK);
            $$->op = NOT;
        }
    | MENOS
        {
            $$ = newExpNode(UNARYK);
            $$->op = MENOS;
        }
    ;

ativacao
    : var LPAREN args RPAREN
        {
        	$$ = $1;
        	$$->kind.var.varKind = CALLK;
        	$$->child[0] = $3;
            $$->op = CALLK;
        }
    ;

args
    : arg_lista { $$ = $1; }
    | vazio { $$ = $1; }
    ;

arg_lista
    : arg_lista COMMA expression
        {
        	YYSTYPE t = $1;
        	if (t != NULL) {
        		while (t->sibling != NULL) {
        			t = t->sibling;
        		}
        		t->sibling = $3;
        		$$ = $1;
        	} else {
        		$$ = $3;
        	}
        }
    | expression { $$ = $1; }
    ;

id
    : ID
        {
        	$$ = newVarNode(IDK);
        	$$->kind.var.attr.name = copyString(tokenString);
            $$->type = INTEGER_TYPE;
        }
    ;

num
    : NUM
		{
            $$ = newVarNode(CONSTK);
            $$->kind.var.attr.val = atoi(tokenString);
            $$->type = INTEGER_TYPE;
		}
	;

vazio
    : { $$ = NULL; }
    ;

%%

static int yyerror(char * message) {
    fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
    fprintf(listing,"Current token: ");
    printToken(yychar,tokenString);
    Error = TRUE;
    return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void) {
    return getToken();
}

TreeNode * parse(void) {
    yyparse();
    return savedTree;
}

TreeNode * getIntNode(TreeNode * childNode) {
    TreeNode * intNode = newStmtNode(INTEGERK);
    intNode->op = INT;
    intNode->type = INTEGER_TYPE;
    intNode->child[0] = childNode;
    return intNode;
}

TreeNode * getVoidNode(TreeNode * childNode) {
    TreeNode * voidNode = newStmtNode(VOIDK);
    voidNode->op = VOID;
    voidNode->type = VOID_TYPE;
    voidNode->child[0] = childNode;
    return voidNode;
}

static TreeNode * createInsert() {
    TreeNode * input = newVarNode(FUNCTIONK);
    input->lineno = 0;
    input->op = ID;
    input->type = INTEGER_TYPE;
    input->kind.var.mem = FUNCTION_MEM;
    input->kind.var.attr.name = "input";
    return getIntNode(input);
}

static TreeNode * createOutput() {
    TreeNode * output = newVarNode(FUNCTIONK);
    output->lineno = 0;
    output->op = ID;
    output->type = VOID_TYPE;
    output->kind.var.mem = FUNCTION_MEM;
    output->kind.var.attr.name = "output";
    return getVoidNode(output);
}

static TreeNode * createLoadDisk() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = INTEGER_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "ldk";
    return getIntNode(node);
}

static TreeNode * createStoreDisk() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "sdk";
    return getVoidNode(node);
}

static TreeNode * createLoadInstMem() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "lim";
    return getVoidNode(node);
}

static TreeNode * createStoreInstMem() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "sim";
    return getVoidNode(node);
}

static TreeNode * createCheckHardDisk() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "checkHD";
    return getVoidNode(node);
}

static TreeNode * createCheckInstMem() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "checkIM";
    return getVoidNode(node);
}

static TreeNode * createCheckDataMem() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "checkDM";
    return getVoidNode(node);
}

static TreeNode * createExec() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "exec";
    return getVoidNode(node);
}

static TreeNode * createAddProgramStart() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "addProgramStart";
    return getVoidNode(node);
}

static TreeNode * createReadProgramStart() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = INTEGER_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "readProgramStart";
    return getIntNode(node);
}

static TreeNode * createMMULower() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "mmuLower";
    return getVoidNode(node);
}

static TreeNode * createMMUUpper() {
    TreeNode * node = newVarNode(FUNCTIONK);
    node->lineno = 0;
    node->op = ID;
    node->type = VOID_TYPE;
    node->kind.var.mem = FUNCTION_MEM;
    node->kind.var.attr.name = "mmuUpper";
    return getVoidNode(node);
}
