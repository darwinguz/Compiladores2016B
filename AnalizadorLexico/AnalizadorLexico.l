/*
		"Escuela Politécnica Nacional"
Materia: Compiladores y Lenguajes 2016-B
Integrantes:
	-Darwin Guzmán
	-Jonathan Caiza
Fecha: Quito, 13 de Diciembre del 2016
*/
/*definiciones*/
%{
#include <math.h>
#include <stdio.h>
#include <string.h>
int linea=1;
%}

/*declaraciones*/
delim		" "|\t
digito		[0-9]
letra		[a-zA-Z]
booleano 	"true"|"false"
identificador	{letra}*{digito}*?
string		"\""[^}\n]*"\""
caracter	'[^}\n]'

/*reglas de traduccion*/
%%
{delim}+			{/*no hacer nada*/}	
"int"|"Int"|"INT"		{validarInt();}
"float"|"Float"|"FLOAT"		{validarFloat();}
"bool"|"Bool"|"BOOL"		{validarBool();}
"char"|"Char"|"CHAR"		{validarChar();}
"string"|"String"|"STRING"	{validarString();}
"if"|"If"|"IF"			{validarIf();}
"then"|"Then"|"THEN"		{validarThen();}
"else"|"Else"|"ELSE"		{validarElse();}
"while"|"While"|"WHILE"		{validarWhile();}
"do"|"Do"|"DO"			{validarDo();}
"input"|"Input"|"INPUT"		{validarInput();}
"output"|"Output"|"OUTPUT"	{validarOutput();}
"return"|"Return"|"RETURN"	{validarReturn();}
","		{printf("\t\tCaracter Especial: %s\n",yytext);}
";"		{printf("\t\tCaracter Especial: %s\n",yytext);}
":"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"("		{printf("\t\tCaracter Especial: %s\n",yytext);}
")"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"["		{printf("\t\tCaracter Especial: %s\n",yytext);}
"]"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"{"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"}"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"+"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"-"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"*"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"/"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"<"		{printf("\t\tCaracter Especial: %s\n",yytext);}
">"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"="		{printf("\t\tCaracter Especial: %s\n",yytext);}
"!"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"&"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"$"		{printf("\t\tCaracter Especial: %s\n",yytext);}
"<="		{printf("\t\tOperador Compuesto: %s\n",yytext);}
">="		{printf("\t\tOperador Compuesto: %s\n",yytext);}
"=="		{printf("\t\tOperador Compuesto: %s\n",yytext);}
"!="		{printf("\t\tOperador Compuesto: %s\n",yytext);}
"&&"		{printf("\t\tOperador Compuesto: %s\n",yytext);}
"||"		{printf("\t\tOperador Compuesto: %s\n",yytext);}
{booleano}	 	{printf("\t\tBooleano: %s\n", yytext);}
{digito}+		{printf("\t\tNumero Entero: %d\n",atoi(yytext) );}
{digito}"."{digito}*	{printf("\t\tNumero Real: %g\n",atof(yytext) );}
{caracter}		{printf("\t\tCaracter: %s\n",yytext);}
{string}		{printf("\t\tCadena de Caracteres o String: %s\n",yytext);}
{identificador}		{printf("\t\tIdentificador: %s\n",yytext);}
"/*"[^}\n]*"*/" 	{/*printf("\t\tComentario de Multiple Linea: %s\n",yytext);*/}
"/*"[^}\n]*		{/*printf("\t\tComentario de Una Linea: %s\n",yytext);*/}	
{digito}*{letra}*	{printf("\t\tERROR... en la linea %d! CARACTER: (%s) NO DEFINIDO!\n",linea, yytext);}
.			{printf("\t\tERROR... en la linea %d! CARACTER: (%s) NO DEFINIDO!\n",linea, yytext);}
"!:"|":!"|"<:"|":<"|":>"|">:"|"<>"|"<<"|">>"|"::"|"=<"|"=>"|"&|"|"|&"	{printf("\t\tERROR... en la linea %d! TOKEN: (%s) NO DEFINIDO!\n",linea, yytext);}
"+-"|"-+"		{printf("\t\tERROR... en la linea %d! TOKEN: (%s) NO DEFINIDO!\n",linea, yytext);}
\n			{linea++; printf("%d ",linea);}				

%%

/*funciones auxiliares*/
validarInt()
{	   
	if(strcmp("int",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un int y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarFloat()
{	   
	if(strcmp("float",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un float y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarBool()
{	   
	if(strcmp("bool",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un bool y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarChar()
{	   
	if(strcmp("char",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un char y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarString()
{	   
	if(strcmp("string",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un string y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarIf()
{	   
	if(strcmp("if",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un if y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarThen()
{	   
	if(strcmp("then",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un then y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarElse()
{	   
	if(strcmp("if",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un else y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarWhile()
{	   
	if(strcmp("while",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un while y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

validarDo()
{	   
	if(strcmp("do",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un do y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}
validarInput()
{	   
	if(strcmp("input",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un input y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}
validarOutput()
{	   
	if(strcmp("output",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un output y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}
validarReturn()
{	   
	if(strcmp("return",yytext)!=0)
	{
	printf("\t\tERROR en la linea %d, se esperaba un return y no un %s\n",linea, yytext);
	}
	else
	{
	printf("\t\tPalabra Reservada: %s\n",yytext);
	}
}

void main()
{
    printf("%d ",linea);
    yylex();
}