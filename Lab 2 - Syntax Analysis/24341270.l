%option noyywrap

%{

#include"symbol_info.h"

#define YYSTYPE symbol_info*

#include "y.tab.h"

extern YYSTYPE yylval;
//The extern keyword is used to declare a variable that is defined in another file or in another part of the code
//yylval is a global variable used by the Bison parser and Flex scanner to hold the semantic value of tokens. When the scanner (generated by Flex) finds a token, it can store a value (like a number, identifier, or more complex data structure) in yylval. The parser (generated by Bison) then uses yylval to access these values as it builds the parse tree.

void yyerror(char *);

string loglist;

extern int lines;

extern ofstream outlog;
//outlog is the name of the ofstream object. This variable is intended to be used for writing log information to a file.
%}

delim	 [ \t\v\r\f]
newline  \r?\n
ws		 {delim}+
letter_	 [A-Za-z_]
digit	 [0-9]
id		 {letter_}({letter_}|{digit})*
integers {digit}+
floats	 {digit}*(\.{digit}+)|{digit}*(\.{digit}+)?((E|e)[-]?{digit}+)

%%

{ws}		{ /* ignore whitespace */ }
{newline}	{ lines++; }

if          { return IF; }
else		{ return ELSE; }
for         { return FOR; }
while       { return WHILE; }
do          { return DO; }
break       { return BREAK; }
continue    { return CONTINUE; }
return      { return RETURN; }
int         { return INT; }
float       { return FLOAT; }
char        { return CHAR; }
void        { return VOID; }
double      { return DOUBLE; }
switch      { return SWITCH; }
case        { return CASE; }
default     { return DEFAULT; }
printf      { return PRINTLN; }

"+"|"-"	    {
                symbol_info *s = new symbol_info((string)yytext,"ADDOP");
                //yytext is a global variable in Flex that contains the text of the current token that has been matched. Whenever Flex matches a pattern, yytext holds the string of characters that matched the pattern.
                yylval = (YYSTYPE)s;
                return ADDOP;
                //A new symbol_info object is created with the text from the input (stored in yytext) and the type "ADDOP", and a pointer to this object is assigned to s.
                The yylval variable, which holds semantic values, is set to point to this new symbol_info object.
                The function returns the token type ADDOP to indicate that an addition operator has been recognized.
		    }
"*"|"/"|"%"    {
                symbol_info *s = new symbol_info((string)yytext,"MULOP");
                yylval = (YYSTYPE)s;
                return MULOP;
            }
"++"        { return INCOP; }
"--"        { return DECOP; }
"<"|">"|"<="|">="|"=="|"!=" {
                symbol_info *s = new symbol_info((string)yytext,"RELOP");
                yylval = (YYSTYPE)s;
                return RELOP;
            }

"="         { return ASSIGNOP; }
"&&"|"||"   {
		   	symbol_info *s = new symbol_info((string)yytext,"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
		    }

"!"        { return NOT; }
"("        { return LPAREN; }
")"        { return RPAREN; }
"{"        { return LCURL; }
"}"        { return RCURL; }
"["        { return LTHIRD; }
"]"        { return RTHIRD; }
";"        { return SEMICOLON; }
","        { return COMMA; }

{id}       {
                symbol_info *s = new symbol_info((string)yytext,"ID");
                yylval = (YYSTYPE)s;
                return ID;
            }
{integers} {
                symbol_info *s = new symbol_info((string)yytext,"INT");
                yylval = (YYSTYPE)s;
                return CONST_INT;
            }
{floats}   {
                symbol_info *s = new symbol_info((string)yytext,"FLOAT");
                yylval = (YYSTYPE)s;
                return CONST_FLOAT;
            }
