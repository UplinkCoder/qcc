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
	immutable string s2 = `
#include "stdio.h"
("Hello World");
`;

	writeln(s2);
	writeln("Tokenized Output : ");
	writeln(Lexer().lex(source));

	// Lets the user press <Return> before program returns
	stdin.readln();
}

