<<<<<<< Updated upstream
module qcc.parser;
=======
﻿module qcc.parser;


import qcc.token;
import qcc.ast;
import qcc.lexer;

import visitor;
/*
		Type : PP_INCLUDE Val : 0 Line: 1 Colum :0 #include
		Type : STRING_LITERAL Val : 2 Line: 1 Colum :9 "stdio.h"
		
		Type : IDENTIFIER Val : 3 Line: 2 Colum :0 int
		Type : IDENTIFIER Val : 4 Line: 2 Colum :4 main
		Type : PAREN_OPEN Val : 0 Line: 2 Colum :8 (
		Type : IDENTIFIER Val : 3 Line: 2 Colum :9 int
		Type : IDENTIFIER Val : 5 Line: 2 Colum :13 argc 
		Type : COMMA Val : 0 Line: 2 Colum :17 ,
		Type : IDENTIFIER Val : 6 Line: 2 Colum :19 char
		Type : STAR Val : 0 Line: 2 Colum :24 *
		Type : IDENTIFIER Val : 7 Line: 2 Colum :25 argv
		Type : BRACKET_OPEN Val : 0 Line: 2 Colum :29 [
		Type : BRACKET_CLOSE Val : 0 Line: 2 Colum :30 ]
		Type : PAREN_CLOSE Val : 0 Line: 2 Colum :31 )
		Type : CURLY_BRACE_OPEN Val : 0 Line: 2 Colum :33 {
		Type : IDENTIFIER Val : 8 Line: 3 Colum :1 printf
		Type : PAREN_OPEN Val : 0 Line: 3 Colum :7 (
		Type : STRING_LITERAL Val : 9 Line: 3 Colum :8 "Hello World"
		Type : PAREN_CLOSE Val : 0 Line: 3 Colum :21 )
		Type : SEMICOLON Val : 0 Line: 3 Colum :22 ;
		Type : IDENTIFIER Val : 10 Line: 4 Colum :1 return
		Type : INTEGER_LITERAL Val : 0 Line: 4 Colum :9 0
		Type : SEMICOLON Val : 0 Line: 4 Colum :9 ;
		Type : CURLY_BRACE_CLOSE Val : 0 Line: 5 Colum :0 }
		Type : EOF Val : 0 Line: 6 Colum :1 
*/

struct Parser
{
	uint pos;
	Token[] tokens;

	Token pop () {
		return tokens[pos++];
	}

	Token peek (ubyte n=0) {
		return tokens[pos+n];
	}

	auto parse(Token[] tokens) {
		this.tokens=tokens;
		while (peek() != TokenType.EOF) with (TokenType) {

			if(peek().type == PP_INCLUDE) {
				pop();
				assert(pop().type == STRING_LITERAL);
				//TODO use #include not skip it
			}

			if(peek(0).type == IDENTIFIER && peek(1).type == IDENTIFIER && peek(2).type == PAREN_OPEN) {
				// most likely a function declaratopn
				// now we need todo lookahead and other stuff
			}

		}
	}

}
>>>>>>> Stashed changes

struct Parser {

}