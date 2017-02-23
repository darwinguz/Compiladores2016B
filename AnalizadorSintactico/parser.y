%{	
	#include <stdio.h>
	#include "tablasimbolos.h"
	extern int errors, lines, chars;
	// tabla simbolos
	#define TABLE_FILE "resultados.txt"
	// mensajes
	#define ERROR 0
	#define WARNING 1
	#define NOTE 2
	// clave de la tabla de simbolos
	#define KEY_TYPE -100
	FILE *yyin;
	char *filename;
	int yylex();
	void yyerror();
	int install(const char *lexeme, int type);
	void install_keywords(char* keywords[], int n);
	void install_id(char *name, int type);
	void print_table(table_t table);
	char *strbuild(int option, const char *str1, const char *str2);
	void print_cursor();
	void get_line(char *line);
	#define YYDEBUG 1
%}

%token MAIN
%token IF ELSE DO WHILE FOR BREAK PRINT RETURN
%token INT_TYPE FLOAT_TYPE LETRA_TYPE STRING_TYPE BOOL_TYPE
%token CHAR STRING INTEGER FLOTANTE BOOLEANO
%token ID
%token MATH_INC MATH_DEC
%token EQL MENOR_QUE MAYOR_QUE AND OR NOT
%token KEYOP KEYCL ParetOP ParetCL BracketOP BracketCL
%token IGUAL

%union {
	char *lexeme;
	char *string;
	char *letra;
	int integer;
	float flotante;
	float booleano;
}

%type<lexeme> ID
%type<integer> INTEGER l_expr l_factor
%type<flotante> FLOTANTE g_expr g_term g_factor 
%type<string> STRING t_expr 
%type<letra> CHAR c_expr 
%left KEYOP
%right KEYCL
%left ParetOP
%right ParetCL
%left BracketOP
%right BracketCL
%token ASIGNACION
%left  COMA
%right FinCommand
%left '+' '-'
%left '*' '/'
%left MATH_INC MATH_DEC
%left EQL MENOR_QUE MAYOR_QUE AND OR
%right IGUAL
%right NOT

%glr-parser
%%

/*CUERPO DEL PROGRAMA*/
program:
	MAIN ParetOP ParetCL  KEYOP comandos KEYCL metodo
	|MAIN ParetOP declaration ParetCL KEYOP comandos KEYCL metodo
	|MAIN ParetOP ParetCL KEYOP comandos metodo comandos KEYCL metodo
	|MAIN ParetOP declaration ParetCL KEYOP comandos metodo comandos KEYCL metodo
        | error {yyerror("ERROR: Formato del metodo 'main' invalido", ERROR);} 
	;

metodo: 
	 %empty
	| lista_tipo ID ParetOP ParetCL KEYOP comandos KEYCL metodo
	| lista_tipo ID ParetOP ParetCL KEYOP comandos metodo comandos KEYCL metodo
	| lista_tipo ID ParetOP declaration ParetCL KEYOP comandos KEYCL metodo
	| error {yyerror("ERORR: Formato del metodo invalido", ERROR);}
	;

lista_tipo:
	INT_TYPE 
	|FLOAT_TYPE 
	|STRING_TYPE 
	|LETRA_TYPE 
	|BOOL_TYPE
	;

/*COMANDOS*/
comandos: 
	command_list
	;

command_list: 
	KEYOP command_list KEYCL
	| command  command_list
        | %empty
        ;

command:
	comando_simple FinCommand
        | bucle
        | error { yyerror("ERROR: Instruccion erronea o falta un ';'", ERROR); }
        ;
	
bucle: 
	controlF
	| controlFor
        | controlWhile 
        | controlDo
        ;

comando_simple: 
	PRINT STRING
        | RETURN
        | attrib
        | declaration
        ;

/*IF ELSE*/
controlF: 
	IF ParetOP l_expr ParetCL KEYOP comandos KEYCL controlElse
	;

controlElse: 
	%empty
        | ELSE KEYOP comandos KEYCL
	;

/*FOR*/
controlFor: 
	FOR ParetOP ffirst FinCommand l_expr FinCommand fthird ParetCL KEYOP comandos KEYCL
	;

ffirst: 
	%empty
	| attrib_list
	;

fthird: 
	%empty
        | comando_simple COMA fthird
        | comando_simple
	;

/*WHILE*/
controlWhile: 
	WHILE ParetOP l_expr ParetCL KEYOP comandos KEYCL
	;

/*DO WHILE*/
controlDo: 
	DO KEYOP comandos KEYCL WHILE ParetOP l_expr ParetCL FinCommand
	;

/*DECLARACIONES*/
declaration: 
	INT_TYPE ASIGNACION ID {install_id($3, INT_TYPE);}
	|FLOAT_TYPE ASIGNACION ID {install_id($3, FLOAT_TYPE);}
	|STRING_TYPE ASIGNACION ID {install_id($3, STRING_TYPE);}
	|LETRA_TYPE ASIGNACION ID {install_id($3, LETRA_TYPE);}	
	|BOOL_TYPE ASIGNACION ID {install_id($3, BOOL_TYPE);}
	;

/*ATRIBUCIONES*/
attrib_list: 
	attrib ',' attrib_list 
        | attrib
        ;

attrib:
	i_attrib
	| ID MATH_INC {if(get_entry($1)){set_value($1, get_value($1)+1);}
		      else{char *str=(char *)strbuild(1,"ERROR: No se ha declarado '%s'", $1);yyerror(str, ERROR);}}
	| ID MATH_DEC {if(get_entry($1)){set_value($1, get_value($1)-1);}
		      else{char *str=(char *)strbuild(1,"ERROR: No se ha declarado '%s'", $1);yyerror(str, ERROR);}}                      
	| ID '=' ID {char *str;if(get_entry($1)!=NULL) {
			//si hay una entrada entonces entonces asigna el valor
			if(get_entry($3)!=NULL){if(get_type($1)==get_type($3)){set_value($1, get_value($3));}
			else{str=(char *)strbuild(0,(char *)strbuild(1, "ERROR: Tipos de datos incompatibles en '%s' ", $1),
			(char *)strbuild(1, "y '%s'", $3));}}
		        else{str=(char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);yyerror(str, ERROR);}}
			else{str=(char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);yyerror(str, ERROR);}}
	| error { yyerror("ERROR: Formato de atributo invalido", ERROR); }
	;	

i_attrib: 
	ID '=' g_expr {if(get_entry($1)) {
			if(get_type($1) == INT_TYPE) {
			set_value($1,(int) $3);}
			else if(get_type($1) == FLOAT_TYPE) {
			set_value($1,(float) $3);}
			else if(get_type($1) == BOOL_TYPE) {		
			if($3>0&&$3<1){set_value($1,0);}
			else if($3>1&&$3<2){set_value($1,1);};}
			else {yyerror("ERROR: Tipos de datos incompatibles", WARNING);}}
			else {char *str = (char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);
			yyerror(str, ERROR);}}
	|ID '=' t_expr {if(get_entry($1)) {
			if(get_type($1)==STRING_TYPE) {
			set_value($1,(char)($3));}
			else {yyerror("ERROR: Tipos de datos incompatibles", WARNING);}}
			else {char *str = (char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);
			yyerror(str, ERROR);}}
	|ID '=' c_expr {if(get_entry($1)) {
			if(get_type($1)==LETRA_TYPE) {
			set_value($1, (char)($3));}
			else {yyerror("ERROR: Tipos de datos incompatibles", WARNING);}}
			else {char *str = (char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);
			yyerror(str, ERROR);}}
	;

/*EXPRESIONES LOGICAS Y MATEMATICAS*/
t_expr:
	STRING	{$$=$1;}
	;

c_expr:
	CHAR 	{$$=$1;}
	;

l_expr: 
	l_expr EQL l_factor { $$=$1==$3; }
      | l_expr AND l_factor { $$=$1&&$3; }
      | l_expr OR l_factor { $$=$1||$3; }
      | l_expr MAYOR_QUE l_factor { $$=$1>$3; }
      | l_expr MENOR_QUE l_factor { $$=$1<$3; }
      | NOT l_expr { $$ = !$2; }
      | l_factor
      ;

l_factor: 
	ParetOP l_expr ParetOP { $$ = $2; }
	| INTEGER { $$ = $1; }
	| FLOTANTE { $$ = $1; }
	| ID 	{
		//si hay un input entonces guarda su valor
		if(get_entry($1)) {$$ = (int) get_value($1);}
		else {char *str = (char *)strbuild(1, "ERROR: No se ha declarado '%s'", $1);
		yyerror(str, ERROR);}}
	;

g_expr: 
	g_expr '+' g_term { $$ = $1 + $3; }
      | g_expr '-' g_term { $$ = $1 - $3; } 
      | g_term { $$ = $1; }
      ;

g_term: 
	g_term '*' g_factor { $$ = $1 * $3; } 
      | g_term '/' g_factor { $$ = $1 / $3; } 
      | g_factor { $$ = $1; }
      ;

g_factor: 
	ParetOP g_expr ParetOP { $$ = $2; }
        | INTEGER { $$ = $1; }
	| FLOTANTE { $$ = $1; }
        ;

%%

//imprime la tabla de simbolos en un archivo
void imprimir_tabla(table_t table) {
	int i;
	entry_t *cur;
	
	printf("TABLA DE SÍMBOLOS\n"
		"%d entries\n\n", table.t_size);

	printf("--------------------------------------------------\n"); 
	printf("|   N   |  TIPO   |        TOKEN = VALOR         |\n");
	printf("--------------------------------------------------\n"); 

	for(i = 1, cur = table.t_head;
	    cur != NULL;
	    cur = cur->next, i++) {
		if(cur->type == INT_TYPE) {
			printf("| %-5d |ENTERO  |  %s = %d\n", i, cur->lexeme, (int) cur->value);
		} 
		else if(cur->type == FLOAT_TYPE) {
			printf("| %-5d |FLOTANTE|  %s = %f\n", i, cur->lexeme, (float) cur->value);
		}
		else if(cur->type == LETRA_TYPE) {
			printf("| %-5d |CHAR    |  %s = %f\n", i, cur->lexeme, cur->value);
		}		
		else if(cur->type==BOOL_TYPE) {
			printf("| %-5d |BOOLEANO|  %s = %f\n", i, cur->lexeme,  cur->value);
		} 
		
		else if(cur->type == STRING_TYPE) {
			printf("| %-5d |STRING  |  %s = %f\n", i, cur->lexeme, cur->value);	
		} 
		else if(cur->type == KEY_TYPE) {
			printf("| %-5d |PALABRA |  %s\n", i, cur->lexeme);
		}
	}
	printf("--------------------------------------------------\n"); 
}


int main( int argc, char **argv )
{
	char* keywords[] = {"main", "if", "else", "do", "while", "for", "break", "print",
						"return", "int", "float"};
	//verifica si hat mas archivos para leer
	++argv, --argc;
	
	char nombreArchivo[50];
        printf("Ruta del Archivo: ");
        gets(nombreArchivo);
	filename = nombreArchivo;
	yyin = fopen( filename, "r" );
	
	/*
	// archivo input
	filename = strdup("input.txt");
	yyin = fopen( "input.txt", "r" );
	*/

	//inicializa la tabla de simbolos	
	init_table();

	//intallo las palabras claves a la primera entrada de la tabla de simbolos	
	install_keywords(keywords, 11);

	//ejecutar el parser
	yyparse();
 	if(yyin==NULL){        
		printf("\nERROR: No se puede leer el archivo");

	}else{

	if(errors==0) {
		printf("EXITO: Se ha compilado correctamente!\n");
	}
	else {
		printf("ERROR: Se han encontrado %d errores\n", errors);
	}

	}

	//imprimir la tabla de simbolos generada
	print_table(table);
	imprimir_tabla(table);

	return 0;
}

//inserta una entrada en el fin de la tabla de simbolos y si esta declarado retorna 0
int install(const char *lexeme, int type) {
int success = 1;
	entry_t *e;

	e = (entry_t *)get_entry(lexeme);
	if(e == 0) {
		put_entry((entry_t *)create_entry(type, lexeme, 0));
	}
	else {
		success = 0;
	}
	return success;
}

//inserta todas las palabras clave en el inicio de la talba de simbolos
void install_keywords(char* keywords[], int n) {
	int i;
	for(i = 0; i < n; i++) {
		install(keywords[i], KEY_TYPE);
	}
}

//imprime la tabla de simbolos en un archivo
void print_table(table_t table) {
	FILE *f = fopen (TABLE_FILE, "w");	
	int i;
	entry_t *cur;
	
	fprintf(f, "TABLA DE SÍMBOLOS\n"
		"%d entries\n\n", table.t_size);

	fprintf(f, "+-------+---------+------------------------------+\n"); 
	fprintf(f, "|   -   |  TIPO   |        TOKEN = VALOR         |\n");
	fprintf(f, "+------------------------------------------------+\n"); 

	for(i = 1, cur = table.t_head;
	    cur != NULL;
	    cur = cur->next, i++) {
		if(cur->type == INT_TYPE) {
			fprintf(f, "| %-5d | ENTERO  |  %s = %d\n", i, cur->lexeme, (int) cur->value);
		} 
		else if(cur->type == FLOAT_TYPE) {
			fprintf(f, "| %-5d |FLOTANTE |  %s = %f\n", i, cur->lexeme, (float) cur->value);
		}
		else if(cur->type == LETRA_TYPE) {
			fprintf(f, "| %-5d | CHAR    |  %s = %f\n", i, cur->lexeme, cur->value);
		}		
		else if(cur->type==BOOL_TYPE) {
			fprintf(f, "| %-5d |BOOLEANO |  %s = %f\n", i, cur->lexeme,  cur->value);
		} 
		
		else if(cur->type == STRING_TYPE) {
			fprintf(f, "| %-5d | STRING  |  %s = %f\n", i, cur->lexeme, cur->value);	
		} 
		else if(cur->type == KEY_TYPE) {
			fprintf(f, "| %-5d | PALABRA |  %s\n", i, cur->lexeme);
		}
	}

	fprintf(f, "+-------+---------+------------------------------+\n"); 
}

void yyerror(const char *msg, int type) {
	if(strcmp(msg, "syntax error") == 0) {
		printf("Error Sintactico\n");
	}
	else {
		switch(type) {
			case ERROR:
				printf("%s:%d:%d: ERROR: %s\n", filename, lines, chars, msg);
				break;

			case WARNING:
				printf("%s:%d:%d: ADVERTENCIA: %s\n", filename, lines, chars, msg);
				break;

			case NOTE:
				printf("%s:%d:%d: NOTA: %s\n", filename, lines, chars, msg);
				break;

			default:
				printf("%s:%d:%d: ERROR: %s\n", filename, lines, chars, msg);
		}

		errors++;
		print_cursor();
	}
}

void install_id(char *name, int type) {
	//verficia si el ID esta en la tabla de simbolos y sino entonces la verifica
	if(install(name, type)) {
		//verificacion exitosa
		printf("%s variable verificada.\n", name);
	}
	else {
		int t = get_type(name);
		char *str;
		if(t == type) {
			str = (char *)strbuild(1, "Redeclaracion de '%s'", name);
		}
		else {
			str = (char *)strbuild(1, "Tipos conflictivos para '%s'", name);
		}
		yyerror(str, NOTE);
	}
}

char *strbuild(int option, const char *str1, const char *str2) {
	char *full_str;

	if(option == 1) {
		int size;
		// allocates the size of the resulting string
		size = snprintf(NULL, 0, str1, str2);
		full_str = (char *)malloc(size+1);

		// if there's space then prints into the string
		if(full_str != NULL) {
			snprintf(full_str, size+1, str1, str2);
		}
		
		else {
			full_str = (char *)strdup(str1);
		}
	}
	else {
		// concatenates
		full_str = (char *)malloc((strlen(str1) + strlen(str2)) * sizeof(char));
                if(full_str != NULL) {
			strcat(full_str, str1);
			strcat(full_str, str2);
		}
	}

	return full_str;
}

void print_cursor() {
	int i;
	char line[256];

	get_line(line);
	printf("%s", line);

	for(i=0; i<chars-1; i++) {
		if(line[i] == '\t') {
			printf("\t");
		}
		else {
			printf(" ");
		}
	}
	printf("^^\n");
}

void get_line(char *line) {
	int i;
	fpos_t position;

	//guarda la posicion actual en el archivo*
	fgetpos(yyin, &position);

	//fseek(yyin, 0, SEEK_SET);
	rewind(yyin);
	for(i=0; i<lines; i++) {
		fgets(line, 256, yyin);
	}

	// recover position in file
	fsetpos(yyin, &position);
}
