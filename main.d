module qcc.driver;

import qcc.lexer;
import qcc.parsetree;
import qcc.parser;
import std.stdio;

void main(string[] args)
{
	writeln("Welcome to the QCC Compiler");

	immutable string test_source = `
#include "stdio.h"

struct s {
	int x;
	int y;
	struct s2 {
		int x2;
		int y2;
	} ;
} ;

int main() {
	int a;
	a = (4+4)*8;
	printf("Hello World"); 
	return 1234;
}

int b;
	`;
	import std.file;
	auto source = (args.length>1) ? cast(immutable(char[])) read(args[1]) : test_source;
	writeln(source);
	writeln("Tokenized Output : ");
	auto lexer = Lexer();
	auto tokens = lexer.lex(source);
	foreach(token;tokens) {
		writeln(token);
	}
	writeln(lexer.intrmap);
	auto ptree = Parser().parseCompilationUnit(tokens);
	foreach(decl;ptree.declarations) { 
		writeln (decl); 
	}
	foreach(stmt;(cast(FunctionDefinition)(ptree.declarations[1])).function_body.statements) {
		writeln(stmt);
	}

	// Lets the user press <Return> before program returns
	stdin.readln();
}

