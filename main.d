module qcc.driver;

import qcc.lexer;

import std.stdio;

void main(string[] args)
{
	writeln("Welcome to the QCC Compiler");

	immutable string source = `
#include "stdio.h"
int main(int argc, char *argv[]) {
	int a = (4+4)*8;
	printf("Hello World"); 
	return 42;
}
	`;

	writeln(source);
	writeln("Tokenized Output : ");
	auto lexer = Lexer();
	auto tokens = lexer.lex(source);
	foreach(token;tokens) {
		writeln(token);
	}
	writeln(lexer.intrmap);
//	auto ptree = Parser().parse(tokens);
	

	// Lets the user press <Return> before program returns
	stdin.readln();
}

