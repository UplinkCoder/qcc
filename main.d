module qcc.driver;
import qcc.lexer;

import std.stdio;

void main(string[] args)
{
	writeln("Welcome to the QCC Compiler \n Test Input :");

	immutable string source = `
#include "stdio.h"
int main(int argc, char *argv[]) {
	printf("Hello World");
	return 0;
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
	

	// Lets the user press <Return> before program returns
	stdin.readln();
}

